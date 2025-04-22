class OpenAi {
    [object]$WebSession
    [hashtable]$Body
    [object]$PreviousResponse
    [string]$Uri = "https://api.openai.com/v1/responses"

    OpenAi([string]$ApiKey, [string]$Model) {
        $this.WebSession = $this.NewWebSession($ApiKey)
        $this.Body = $this.NewRequestBody($Model)
    }

    [hashtable]
    NewRequestBody([string]$Model) {
        return @{
            previous_response_id = $null
            model                = $Model
            input                = [System.Collections.Generic.List[object]]::new()
            tools                = [System.Collections.Generic.List[object]]::new()
        }
    }

    [Microsoft.PowerShell.Commands.WebRequestSession]
    NewWebSession([string]$ApiKey) {
        $Session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
        $Session.Headers.Add("Authorization", "Bearer $ApiKey")
        $Session.Headers.Add("Content-Type", "application/json")
        return $Session
    }

    [string] GetTextResponse([string]$Message) {
        $this.AddMessageInput($Message)
        if ($this.PreviousResponse) {
            $this.Body.previous_response_id = $this.PreviousResponse.id
        }

        $Response = Invoke-RestMethod -Uri $this.Uri -Method Post -Body ($this.Body | ConvertTo-Json -Depth 100) -WebSession $this.WebSession
        $this.PreviousResponse = $Response

        # Auto-handle function calls if present
        if ($Response.output.type -eq "function_call") {
            return $this.InvokeFunctionIfPresent($Response)
        }

        return $this.WriteTextResponse($Response)
    }

    [string] GetResponse() {

        if ($this.PreviousResponse) {
            $this.Body.previous_response_id = $this.PreviousResponse.id
        }

        $Response = Invoke-RestMethod -Uri $this.Uri -Method Post -Body ($this.Body | ConvertTo-Json -Depth 20) -WebSession $this.WebSession
        $this.PreviousResponse = $Response

        # Auto-handle function calls if present
        if ($Response.output.type -eq "function_call") {
            return $this.InvokeFunctionIfPresent($Response)
        }

        return $this.WriteTextResponse($Response)
    }

    [string] WriteTextResponse($Response) {
        $this.ResetInputs()
        return $Response.output.content.text
    }

    [void] ResetInputs() {
        $this.Body.input = [System.Collections.Generic.List[object]]::new()
    }

    [void] AddMessageInput([string]$Text) {
        $Object = @{
            role    = "user"
            content = $Text
        }
        $null = $this.Body.input.Add($Object)
    }

    [void] AddTool([string]$Path) {
        $item = get-item -Path $Path
        if ($item.Extension -eq ".psd1") {
            $Tool = Import-PowerShellDataFile -Path $Path
            $null = $this.Body.tools.Add($Tool)
        }
        elseif (($item.Extension -eq ".json")) {
            $Tool = (Get-Content -Path $path -Raw | ConvertFrom-Json -Depth 10)
            $null = $this.Body.tools.Add($Tool)
        }
    }

    [void] AddFuncResponseInput([string]$CallId, [object]$Output) {
        $Object = @{
            type    = "function_call_output"
            call_id = $CallId
            output  = ($Output | Out-string)
        }
        $null = $this.Body.input.Add($Object)
    }

    [string] InvokeFunctionIfPresent($Response) {
        $CurrentResponse = $Response
    
        while ($true) {
            $LastOutput = $CurrentResponse.output[-1]
    
            if ($LastOutput.type -ne "function_call") {
                $this.ResetInputs()
                return $this.WriteTextResponse($CurrentResponse)
            }
    
            $Command   = ($LastOutput.name -replace "\s+")
            $Arguments = ($LastOutput.arguments | ConvertFrom-Json -AsHashtable)
            $Arguments.Add("ErrorAction","Stop")
            $CallId    = $LastOutput.call_id
    
            try {
                $FuncCallOutput = & $Command @Arguments
            }
            catch {
                $FuncCallOutput = "⚠️ Function '$Command' failed: $($_.Exception.Message)"
            }
    
            $this.AddFuncResponseInput($CallId, $FuncCallOutput)
            $this.Body.previous_response_id = $CurrentResponse.id
    
            $CurrentResponse = Invoke-RestMethod -Uri $this.Uri -Method Post -Body ($this.Body | ConvertTo-Json -Depth 20) -WebSession $this.WebSession
            $this.PreviousResponse = $CurrentResponse
        }
    
        return ""
    }   
    
    [void] Forget() {
        $this.PreviousResponse = $null
        $this.ResetInputs()
        $this.Body.previous_response_id = $null
    }
}
