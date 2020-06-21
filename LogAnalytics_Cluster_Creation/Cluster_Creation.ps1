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


# Create the cluster. This is an exmaple where the cluster name is defined as <Cluster Name> in the URI string.
# The JSON content below is required for the cluster creation. You may need to adjust location and capactiy as necessary.
# Note the method used here is PUT

$content = @{'identity' = @{'type' = 'systemAssigned'}
'sku' = @{'name' = 'capacityReservation' ; 'Capacity' = '1000'}
'properties' = @{'clusterType' = 'capacityReservation'}
'location' = 'eastus'
} | Convertto-Json

$uri = "https://management.azure.com/subscriptions/$subscriptionID/resourcegroups/$resourceGroup/providers/Microsoft.OperationalInsights/clusters/<ClusterName>?api-version=2019-08-01-preview"
$response = Invoke-RestMethod -Method PUT -Uri $URI -Headers $headers -Body $content -ContentType application/json

#View the output of the API response
Write-Host $response
