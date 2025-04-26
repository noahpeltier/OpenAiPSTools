@{
    type        = "function"
    name        = "Get-ChildItem"
    description = "List contents of directories"
    parameters  = @{
        type                 = "object"
        required             = @("Path")
        properties           = @{
            Path = @{
                type        = "string"
                description = "The path where to enumerate child items from."
            }
        }
        additionalProperties = $false
    }
} 