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

## 🧰 Tools (Local PowerShell Function Execution)

One of the most powerful features of this framework is its ability to **execute local PowerShell functions defined as tools** — all triggered intelligently by OpenAI using its function calling capability.

You simply define a PowerShell-compatible OpenAI function schema in a `.psd1` or `.json` file, and map it to a real PowerShell function you've written.

When the AI determines that a function should be called, your actual PowerShell function is executed — locally, safely, and with structured input. The result is then returned back to OpenAI for further conversation.

---

### 🧪 Example Tool: `Invoke-MgGraphRequest`

This tool definition tells the AI how to call a function that interacts with the Microsoft Graph API.

```powershell
@{
    type        = "function"
    name        = "Invoke-MgGraphRequest"
    description = "Invokes a REST request using the Graph API"
    parameters  = @{
        type       = "object"
        required   = @("Uri", "OutputType", "Headers")
        properties = @{
            Uri = @{
                type        = "string"
                description = "Full path, e.g. https://graph.microsoft.com/v1.0/users"
            }
            OutputType = @{
                type        = "string"
                description = "Set to 'Json'."
            }
            Headers = @{
                type        = @("object", "null")
                description = "Optional headers, e.g. @{ ConsistencyLevel = 'eventual' }"
            }
        }
        additionalProperties = $false
    }
}

