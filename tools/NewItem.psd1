@{
    type        = "function"
    name        = "New-Item"
    description = "Create a new File or Directory"
    parameters  = @{
        type                 = "object"
        required             = @("Name","ItemType","Path","Value","Force")  # <- name is now optional
        properties           = @{
            Name = @{
                type        = "string"
                description = "The name of the file or directory. if itemtype is File, Include the extension based on the needs of the user per their request"
            }
            ItemType = @{
                type        = "string"
                description = "Defines the type of item created being Directory or File"
            }
            Path = @{
                type        = "string"
                description = "The local path where to create the directory. If no path can be derived from the user's input then assume path value is `$pwd"
            }
            Value = @{
                type        = @("string","null")
                description = "The value of the content you will add to the file if item type File is selected, otherwise this parameter should not be used"
            }
        }
        additionalProperties = $false
    }
}