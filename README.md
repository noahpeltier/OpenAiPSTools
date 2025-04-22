# 🔧 OpenAI PowerShell Integration (WIP)

A fully PowerShell-native class-based interface for interacting with OpenAI's `/v1/responses` API — complete with tool calling support, RESTful API integration, and multi-step function execution.

In short, it's a lightweight AI function runtime, designed to let you build AI-assisted workflows using plain PowerShell.

---

## 🚀 Features

- [x] Stateful chat using `previous_response_id`
- [x] Automatic function call detection + execution
- [x] `.psd1` and `.json` tool schema support
- [x] Token-conscious payload design (`ResetInputs`)
- [x] Safe error handling for failed function calls
---

## 📦 Requirements

- PowerShell 7.x+
- An OpenAI API key (`$env:apiKey` or pass it directly)

---

## 🧠 Usage (PowerShell)

```powershell
# Create an instance
$ai = [OpenAi]::new($env:apiKey, "gpt-4.1-mini")

# Add tool schemas (JSON or PSD1)
$ai.AddTool(".\tools\WebSearch.psd1")
$ai.AddTool(".\tools\Send-Email.json")

# Ask something
$ai.GetTextResponse("Search the web for the latest CVE on microsoft and email it to me at email@domain.com")

# Manually reset the session if needed
$ai.Forget()
```

## Tools

Defining tools is easy. Just write out a tool following OpenAi's tool schema as a psd1 file.
This is one exmaple I've found very usefull

```powershell
@{
    type        = "function"
    name        = "Invoke-mggraphRequest"
    description = "Invoke a REST request using the Graph API"
    parameters  = @{
        type                 = "object"
        required             = @("Uri","OutputType","Headers")  # <- name is now optional
        properties           = @{
            Uri = @{
                type        = "string"
                description = "Use logic from the users request to create a path for this for example https://graph.microsoft.com/beta/users"
            }
            OutputType = @{
                type        = "string"
                description = "The output type for this request. Needs to always be Json so don't change it"
            }
            Headers = @{
                type        = @("object","null")
                description = "use this when nessiary, for example when using the `$filter iun querries, Header should be a hashtable @{ConsistencyLevel = 'eventual'}"
            }
        }
        additionalProperties = $false
    }
}
```

Wich allows you to ask it to perform queries to GraphAPI

```powershell
$ai.GetTextResponse("Find me users who were created in the last 30 days")
```
