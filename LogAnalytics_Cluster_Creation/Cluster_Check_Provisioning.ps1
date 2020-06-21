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


# Since CMK is still in preview at the time of this creation, after you run the above command, you need to notify the Microsoft team with the output of the $response generated so they can manually create the cluster.
# After this is complete you can proceed with the next step.
# The following section is to get the status of the log analytics cluster you requested in the previous step.  This is an exmaple where the cluster name is defined as <Cluster Name> in the URI string.
# Note the method used here is a GET.

$getCluster = Invoke-RestMethod -Method GET -Uri "https://management.azure.com/subscriptions/$subscriptionID/resourceGroups/$resourceGroup/providers/Microsoft.OperationalInsights/clusters/<Cluster Name>?api-version=2020-03-01-preview" -Headers $headers
if ($getCluster.properties.provisioningState -eq "ProvisioningAccount"){Write-host "Things are still being created. Be Patient"}
if ($getCluster.properties.provisioningState -eq "Succeeded"){Write-Host "Be Happy and start doing things"}