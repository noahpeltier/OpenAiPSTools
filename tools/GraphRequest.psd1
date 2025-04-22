@{
    type        = "function"
    name        = "Invoke-mggraphRequest"
    description = "Invoke a REST request using the Graph API"
    parameters  = @{
        type                 = "object"
        required             = @("Uri","OutputType")  # <- name is now optional
        properties           = @{
            Uri = @{
                type        = "string"
                description = "Use logic from the users request to create a path for this for example https://graph.microsoft.com/beta/users"
            }
            OutputType = @{
                type        = "string"
                description = "The output type for this request. Needs to always be Json so don't change it "
            }
        }
        additionalProperties = $false
    }
}
