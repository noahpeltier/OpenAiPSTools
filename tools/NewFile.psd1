@{
    type        = "function"
    name        = "New-Item"
    description = "Export any content the users asks for to a file"
    parameters  = @{
        type                 = "object"
        required             = @("Name","Value","Path")  # <- name is now optional
        properties           = @{
            Name = @{
                type        = "string"
                description = "The name of the file. Include the extension based on the needs of the user per their request"
            }
            Value = @{
                type        = "string"
                description = "The value of the content you will add to the file."
            }
            Path = @{
                type        = "string"
                description = "The local path where to save the file. If you ar not sure where to create the file, look for the Get-ChildItem function to use."
            }
        }
        additionalProperties = $false
    }
}