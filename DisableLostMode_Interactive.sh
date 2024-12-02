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
# This resolves an issue where lost mode is not able to be disabled in the 
# Jamf Pro GUI after enabling.
#
####################################################################################################

####### Adjustable Variables #######
jamfpro_url=""
jamfpro_user=""
jamfpro_password=""
doesWhat="This script sends a disable lost mode command via an API to address an issue where lost mode is not able to be disabled via the GUI. After entering the URL and Jamf Pro credentials, you will be prompted for device ID."

####################################

##### Non-Adjustable Variables #####
bearerToken=""
tokenExpirationEpoch="0"

####################################

# Function to gather and format bearer token
getBearerToken() {
    response=$(/usr/bin/curl -k -s -u "$jamfpro_user":"$jamfpro_password" "$jamfpro_url"/api/v1/auth/token -X POST)
    bearerToken=$(echo "$response" | plutil -extract token raw -)
    tokenExpiration=$(echo "$response" | plutil -extract expires raw - | awk -F . '{print $1}')
    tokenExpirationEpoch=$(date -j -f "%Y-%m-%dT%T" "$tokenExpiration" +"%s")
    echo "New bearer token generated."
    echo "Token valid until: $tokenExpiration (UTC)"
}

# Function to check token expiration
checkTokenExpiration() {
    nowEpochUTC=$(date -j -f "%Y-%m-%dT%T" "$(date -u +"%Y-%m-%dT%T")" +"%s")
    if [[ $tokenExpirationEpoch -lt $nowEpochUTC ]]; then
        echo "No valid token available, generating a new token..."
        getBearerToken
    fi
}

# Function to invalidate token
invalidateToken() {
    responseCode=$(/usr/bin/curl -k -w "%{http_code}" -H "Authorization: Bearer ${bearerToken}" $jamfpro_url/api/v1/auth/invalidate-token -X POST -s -o /dev/null)
    if [[ $responseCode == 204 ]]; then
        echo "Bearer token successfully invalidated."
    elif [[ $responseCode == 401 ]]; then
        echo "Bearer token already invalid."
    else
        echo "An unknown error occurred while invalidating the bearer token."
    fi
}

# Display warning
echo "#####################"
echo "###!!! WARNING !!!###"
echo "#####################"
echo "$doesWhat"
echo "There is no undo button."
while true; do
    read -p "Are you sure you want to continue? [y | n] " answer
    case $answer in
        [Yy]* ) break ;;
        [Nn]* ) exit ;;
        * ) echo "Please answer y | n." ;;
    esac
done

# Prompt for credentials if not set
if [[ -z "$jamfpro_url" ]]; then
    read -p "Please enter your Jamf Pro server URL: " jamfpro_url
fi

if [[ -z "$jamfpro_user" ]]; then
    read -p "Please enter your Jamf Pro user account: " jamfpro_user
fi

if [[ -z "$jamfpro_password" ]]; then
    read -sp "Please enter the password for $jamfpro_user: " jamfpro_password
    echo
fi

# Remove trailing slash if present in the Jamf Pro URL
jamfpro_url=${jamfpro_url%%/}

echo "Generating bearer token for server authentication..."
getBearerToken

# Loop for device ID input
while true; do
    echo
    read -p "Please enter a device ID to send a disable lost mode command (to exit, type done): " answer
    if [[ $answer =~ ^[Dd]one$ ]]; then
        break
    elif ! [[ "$answer" =~ ^[0-9]+$ ]]; then
        echo "Invalid input. Please enter a numeric device ID."
        continue
    fi
    curl --request POST \
        --url "${jamfpro_url}/JSSResource/mobiledevicecommands/command/DisableLostMode/id/$answer" \
        --header "Authorization: Bearer $bearerToken" \
        --header "Content-Type: application/xml"
done

# Invalidate bearer token
echo "Invalidating bearer token..."
invalidateToken
echo "Script completed successfully. Exiting."
exit 0
