@{
    type        = "function"
    name        = "Invoke-SafeScriptBlock"
    description = "Invoke a powershell command"
    parameters  = @{
        type                 = "object"
        required             = @("ScriptBlock")
        properties           = @{
            ScriptBlock = @{
                type        = "string"
                description = "Powershell code that you need to run goes here."
            }
        }
        additionalProperties = $false
    }
}