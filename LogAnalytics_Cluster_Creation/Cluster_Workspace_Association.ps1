# Definitions
$tenantID ='' #This is the overal Azure AD tenant ID that can be found on the Azure AD blade in Azure Management Portal
$resource = "https://management.azure.com/"
$clientID = '' # This is the client ID from the Service Principal Account Created in the pre-requisites.
$clientSecret = '' # This is the client secret from the Service Principal Account Created in the pre-requisites
$subscriptionID = '' # This is the subscription ID of the Azure Subscription you wish to provision to
$resourceGroup = '' # The resource group to be used (this should already be created)

# Generate the bearer request token to be used
$RequestAccessTokenUri = "https://login.microsoftonline.com/$tenantID/oauth2/token"
$body = "grant_type=client_credentials&client_id=$clientID&client_secret=$clientSecret&resource=$resource"
$Token = Invoke-RestMethod -Method Post -Uri $RequestAccessTokenUri -Body $body -ContentType 'application/x-www-form-urlencoded'
$headers = @{}
$Headers.Add("Authorization","$($Token.token_type) "+ " " + "$($Token.access_token)")
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# This is to change the ingestion / storage of logs for new logs going into a workspace to go into a cluster resource
# Workspace in the URI is referenced by <Log Analytics Workspace>
# Cluster in the content is referenced by <Cluster Name>

$uri = "https://management.azure.com/subscriptions/$subscriptionid/resourcegroups/$resourcegroup/providers/microsoft.operationalinsights/workspaces/<Log Analytics Workspace>/linkedservices/cluster?api-version=2020-03-01-preview "
$content = @{'properties' = @{'WriteAccessResourceId' = "/subscriptions/$subscriptionID/resourcegroups/$resourceGroup/providers/microsoft.operationalinsights/clusters/<Cluster Name>"}} | Convertto-Json

$response = Invoke-RestMethod -Method PUT -Uri $URI -Headers $headers -Body $content -ContentType application/json
Write-host $response