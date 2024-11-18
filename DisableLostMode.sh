#!/bin/bash


####################################################################################################
#
# THIS SCRIPT IS NOT AN OFFICIAL PRODUCT OF JAMF SOFTWARE
# AS SUCH IT IS PROVIDED WITHOUT WARRANTY OR SUPPORT
#
# BY USING THIS SCRIPT, YOU AGREE THAT JAMF SOFTWARE
# IS UNDER NO OBLIGATION TO SUPPORT, DEBUG, OR OTHERWISE
# MAINTAIN THIS SCRIPT
#
####################################################################################################
#
# DESCRIPTION
# 
# This resolves an issue where lost mode is not able to be disabled in the 
#Jamf Pro GUI after enabling.
#
####################################################################################################

# Variables
JAMF_URL="https://your-jamf-pro-instance.jamfcloud.com" # Replace with your Jamf Pro URL
USERNAME="api-username" # Replace with your API username
PASSWORD="api-password" # Replace with your API password
DEVICE_ID="30" # Replace with the device ID
ENDPOINT="/JSSResource/mobiledevicecommands/command/DisableLostMode/id/$DEVICE_ID" # Endpoint for the POST call

# 1. Get Bearer Token
response=$(curl -su "$USERNAME:$PASSWORD" -X POST "$JAMF_URL/api/v1/auth/token" -H "Accept: application/json")
token=$(echo "$response" | jq -r '.token')

# Check if token was retrieved successfully
if [ -z "$token" ] || [ "$token" == "null" ]; then
  echo "Failed to retrieve Bearer Token. Response: $response"
  exit 1
fi

echo "Bearer Token Retrieved: $token"

# 2. Run the POST API Command to Disable Lost Mode
post_response=$(curl --request POST \
  --url "$JAMF_URL$ENDPOINT" \
  --header "Authorization: Bearer $token" \
  --header "Content-Type: application/xml")

# Output the response
echo "API Response:"
echo "$post_response"

# 3. Expire the token (optional for security)
invalidate_response=$(curl -sk -X POST "$JAMF_URL/api/v1/auth/invalidate-token" \
  -H "Authorization: Bearer $token")

echo "Bearer Token Invalidated: $invalidate_response"
