@{
    type        = "function"
    name        = "Get-PSDrive"
    description = "Gets data about mounted directories and drives. If 'name' is omitted, all drives will be returned."
    parameters  = @{
        type                 = "object"
        required             = @()  # <- name is now optional
        properties           = @{
            name = @{
                type        = "string"
                description = "Optional. Name of the drive to get. Defaults to '*' (wildcard for all drives)."
            }
        }
        additionalProperties = $false
    }
}
