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

# Defining all of the variables in the JSON content are required to make this succeed. Note the properties that were added. These versions can be retrieved from the Key Vault / Key that was created. Keys as of time of writing this are required to be RSA type.
# Make sure you fill in KeyVaultUri, KeyName and KeyVersion in the example below.
# Note the method used here is PUT
$uri = "https://management.azure.com/subscriptions/$subscriptionID/resourceGroups/$resourceGroup/providers/Microsoft.OperationalInsights/clusters/<Cluster Name>?api-version=2020-03-01-preview"

$content =@{'identity' = @{'type' = 'systemAssigned'}
'sku' = @{'name' = 'capacityReservation' ; 'Capacity' = '1000'}
'properties' = @{'KeyVaultProperties'= @{'KeyVaultUri' = '' ; 'KeyName' = '' ; 'KeyVersion' = ''}}
'location' = 'eastus'}| Convertto-Json

$response = Invoke-RestMethod -Method PUT -Uri $URI -Headers $headers -Body $content -ContentType application/json

#Write out the response
Write-Host $response