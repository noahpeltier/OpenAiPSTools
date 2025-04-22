@{
    type        = "function"
    name        = "Get-ADuser"
    description = "Gets data about a users and other objects from Active Directory"
    parameters  = @{
        type                 = "object"
        required             = @("Filter")  # <- name is now optional
        properties           = @{
            Filter = @{
                type        = "string"
                description = "Use logic from the users request to create a filter matching what they want from Active Directory"
            }
        }
        additionalProperties = $false
    }
}
