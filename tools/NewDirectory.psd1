@{
    type        = "function"
    name        = "mkdir"
    description = "Create a new Directory"
    parameters  = @{
        type                 = "object"
        required             = @("Name","Path")
        properties           = @{
            Name = @{
                type        = "string"
                description = "The name of the directory."
            }
            Path = @{
                type        = "string"
                description = "The local path where to create the directory."
            }
        }
        additionalProperties = $false
    }
} 