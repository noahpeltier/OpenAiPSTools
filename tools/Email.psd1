@{
    type        = "function"
    name        = "Send-GraphMailmessage"
    description = "Sends an email with specified subject and body to a designated recipient"
    strict      = $true
    parameters  = @{
        type                 = "object"
        required             = @("subject", "body", "to", "bodyashtml")
        properties           = @{
            subject    = @{
                type        = "string"
                description = "The subject of the email"
            }
            body       = @{
                type        = "string"
                description = "The body content of the email"
            }
            to         = @{
                type        = "string"
                description = "The email address of the recipient"
            }
            bodyashtml = @{
                type        = "boolean"
                description = "Sends the email as HTML instead of plaintext"
            }
        }
        additionalProperties = $false
    }
}