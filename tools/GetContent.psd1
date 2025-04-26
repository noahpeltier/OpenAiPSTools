@{
    type        = "function"
    name        = "Get-Content"
    description = "Read the content of a file"
    parameters  = @{
        type                 = "object"
        required             = @("Path","Raw")  # <- name is now optional
        properties           = @{
            Path = @{
                type        = "string"
                description = "The local path to the file. If no path can be derived from the user's input then assume path value is `$pwd"
            }
            Raw = @{
                type        = "string"
                description = "This ALWAYS needs to be used by the AI set to true. switch param determins if content is returned as an array of newline-delimited strings or one string."
            }
        }
        additionalProperties = $false
    }
}