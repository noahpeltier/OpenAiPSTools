@{
    type        = "function"
    name        = "Get-EntraUserByName"
    description = "Gets data about a user from Microsoft Entra Directory"
    parameters  = @{
        type                 = "object"
        required             = @("Name")  # <- name is now optional
        properties           = @{
            Name = @{
                type        = "string"
                description = "A search string which can be the persons name or part of their name"
            }
        }
        additionalProperties = $false
    }
}
