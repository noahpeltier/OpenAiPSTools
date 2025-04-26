@{
    type        = "function"
    name        = "Invoke-Expression"
    description = "Invoke a powershell expression"
    parameters  = @{
        type                 = "object"
        required             = @("Command")  # <- name is now optional
        properties           = @{
            Command = @{
                type        = "string"
                description = "The powershell command or script needed in order to execute the desired action."
            }
        }
        additionalProperties = $false
    }
}