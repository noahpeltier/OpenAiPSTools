class OpenAi {
    # Holds the web session with headers (auth, content-type)
    [object]$WebSession

    # Payload structure that gets sent to OpenAI's /responses API
    [hashtable]$Body

    # Stores the last API response so we can chain the conversation
    [object]$PreviousResponse

    # Endpoint for the OpenAI /v1/responses API
    [string]$Uri = "https://api.openai.com/v1/responses"

    # Constructor: initializes the API client with API key and model
    OpenAi([string]$ApiKey, [string]$Model) {
        $this.WebSession = $this.NewWebSession($ApiKey)
        $this.Body = $this.NewRequestBody($Model)
    }

    # Builds a new default request body with the model and empty input/tool lists
    [hashtable]
    NewRequestBody([string]$Model) {
        return @{
            previous_response_id = $null
            model                = $Model
            input                = [System.Collections.Generic.List[object]]::new()
            tools                = [System.Collections.Generic.List[object]]::new()
        }
    }

    # Builds the WebRequestSession and adds required headers
    [Microsoft.PowerShell.Commands.WebRequestSession]
    NewWebSession([string]$ApiKey) {
        $Session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
        $Session.Headers.Add("Authorization", "Bearer $ApiKey")
        $Session.Headers.Add("Content-Type", "application/json")
        return $Session
    }

    # Sends a message to OpenAI and handles response + function calling
    [string] GetTextResponse([string]$Message) {
        $this.AddMessageInput($Message)

        if ($this.PreviousResponse) {
            $this.Body.previous_response_id = $this.PreviousResponse.id
        }

        $Response = Invoke-RestMethod -Uri $this.Uri -Method Post -Body ($this.Body | ConvertTo-Json -Depth 100) -WebSession $this.WebSession
        $this.PreviousResponse = $Response

        # If a function_call is requested, handle it automatically
        if ($Response.output.type -eq "function_call") {
            return $this.InvokeFunctionIfPresent($Response)
        }

        return $this.WriteTextResponse($Response)
    }

    # Sends a request using current input/tool state, without adding a new message
    [string] GetResponse() {
        if ($this.PreviousResponse) {
            $this.Body.previous_response_id = $this.PreviousResponse.id
        }

        $Response = Invoke-RestMethod -Uri $this.Uri -Method Post -Body ($this.Body | ConvertTo-Json -Depth 20) -WebSession $this.WebSession
        $this.PreviousResponse = $Response

        if ($Response.output.type -eq "function_call") {
            return $this.InvokeFunctionIfPresent($Response)
        }

        return $this.WriteTextResponse($Response)
    }

    # Returns the final assistant text and clears the input array for the next call
    [string] WriteTextResponse($Response) {
        $this.ResetInputs()
        return $Response.output.content.text
    }

    # Empties the input array (messages or function outputs)
    [void] ResetInputs() {
        $this.Body.input = [System.Collections.Generic.List[object]]::new()
    }

    # Adds a user message to the input list
    [void] AddMessageInput([string]$Text) {
        $Object = @{
            role    = "user"
            content = $Text
        }
        $null = $this.Body.input.Add($Object)
    }

    # Loads a tool definition (.psd1 or .json) and adds it to the body
    [void] AddTool([string]$Path) {
        $item = Get-Item -Path $Path
        if ($item.Extension -eq ".psd1") {
            $Tool = Import-PowerShellDataFile -Path $Path
            $null = $this.Body.tools.Add($Tool)
        }
        elseif ($item.Extension -eq ".json") {
            $Tool = (Get-Content -Path $Path -Raw | ConvertFrom-Json -Depth 10)
            $null = $this.Body.tools.Add($Tool)
        }
    }

    # Adds a function call output object to the input array (OpenAI expects this)
    [void] AddFuncResponseInput([string]$CallId, $Output) {
        $Object = @{
            type    = "function_call_output"
            call_id = $CallId
            output  = $Output
        }
        $null = $this.Body.input.Add($Object)
    }

    # Loops through tool calls until a normal response is returned
    [string] InvokeFunctionIfPresent($Response) {
        $CurrentResponse = $Response

        while ($true) {
            $LastOutput = $CurrentResponse.output[-1]

            # If it's not a function call, return final response
            if ($LastOutput.type -ne "function_call") {
                $this.ResetInputs()
                return $this.WriteTextResponse($CurrentResponse)
            }

            $Command   = ($LastOutput.name -replace "\s+")
            $Arguments = ($LastOutput.arguments | ConvertFrom-Json -AsHashtable)
            #$Arguments.Add("ErrorAction", "Stop")  # Force errors to trigger catch
            $CallId    = $LastOutput.call_id
            
            # Execute the actual PowerShell function locally
            $ExecBlock = {
                & $using:Command @using:Arguments
            }
            $FuncCallOutput = Invoke-SafeScriptBlock -ScriptBlock $ExecBlock
            
            # Add the function_call_output to the next input
            $this.AddFuncResponseInput($CallId, $FuncCallOutput.RawOutput)

            $this.Body.previous_response_id = $CurrentResponse.id

            # Resubmit to get the assistant's response
            $CurrentResponse = Invoke-RestMethod -Uri $this.Uri -Method Post -Body ($this.Body | ConvertTo-Json -Depth 100) -WebSession $this.WebSession
            $this.PreviousResponse = $CurrentResponse
        }

        return ""
    }

    # Completely reset session: forget previous responses and input history
    [void] Forget() {
        $this.PreviousResponse = $null
        $this.ResetInputs()
        $this.Body.previous_response_id = $null
    }
}
function Invoke-SafeScriptBlock {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $ScriptBlock
    )
    if ($ScriptBlock -is "string") {
        $ScriptBlock = [scriptblock]::Create($ScriptBlock)
    }
    $output = New-Object System.Collections.Generic.List[object]
    $errors = New-Object System.Collections.Generic.List[object]
    $exceptions = New-Object System.Collections.Generic.List[object]
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    & {
        $ErrorActionPreference = 'Continue'  # Important: Don't throw, just generate error records

        $allResults = & $ScriptBlock 2>&1

        foreach ($item in $allResults) {
            if ($item -is [System.Management.Automation.ErrorRecord]) {
                $errors.Add($item)
            }
            else {
                try {
                    # Try to process normally
                    $output.Add($item)
                }
                catch {
                    $exceptions.Add($_)
                }
            }
        }
    }

    $stopwatch.Stop()

    return [PSCustomObject]@{
        Success    = if ($errors.Count -eq 0 -and $exceptions.Count -eq 0) { $true } else { $false }
        StdOut     = $output.ToArray()
        StdErr     = $errors.ToArray()
        Exceptions = $exceptions.ToArray()
        RawOutput  = ($output | Out-String) + ($errors | Out-String) + ($exceptions | Out-String)
        Duration   = $stopwatch.Elapsed
    }
}
