# Parameters
$tenantId = ""
$clientId = ""
$clientSecret = ""
$scope = "https://graph.microsoft.com/.default"

# Endpoint
$tokenEndpoint = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"

# Body
$body = @{
    client_id     = $clientId
    scope         = $scope
    client_secret = $clientSecret
    grant_type    = "client_credentials"
}

# Request Token
$response = Invoke-RestMethod -Method Post -Uri $tokenEndpoint -ContentType "application/x-www-form-urlencoded" -Body $body

# Output Token
$token = $response.access_token
Write-Output "Bearer Token: $token"
