#!/bin/bash
#
# use the command line interface to install standard actions deployed
# automatically
#
# To run this command
# ./install.sh <apihost> <authkey> <pathtowskcli>
# ./install.sh APIHOST="$EDGE_HOST" AUTH="$AUTH_KEY" WSK_CLI="$OPENWHISK_HOME/bin/wsk"
# API_HOST and AUTH_KEY are found in $HOME/.wskprops

set -e
set -x

if [ $# -eq 0 ]
then
echo "Usage: ./install.sh <apihost> <authkey> <pathtowskcli>"
fi

APIHOST="$1"
AUTH="$2"
WSK_CLI="$3"

PACKAGE_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# pushnotifications actions

echo Installing pushnotifications package.

$WSK_CLI -i --apihost "$APIHOST"  package update --auth "$AUTH"  --shared yes pushnotifications \
-a description "This package supports sending push notifications to your mobile device, using the IBM Bluemix Push Notifications service." \
-a parameters '[ {"name":"appId", "required":true, "description":"Bluemix application GUID"}, {"name":"appSecret", "required":true, "bindTime":true, "type":"password", "description":"Bluemix Push Service Secret"}]' \
-a prettyName "Push Notifications"

$WSK_CLI -i --apihost "$APIHOST" action update --auth "$AUTH" --shared yes pushnotifications/webhook "$PACKAGE_HOME/feeds/webhook.js" \
-a feed true \
-a description 'pushnotifications feed' \
-a parameters '[ {"name":"appId", "required":true, "description":"Bluemix application GUID"}, {"name":"appSecret", "required":true, "bindTime":true, "type":"password", "description":"Bluemix Push Service Secret"},{"name":"events", "required":true, "description":"Name of the event user want to subscribe"} ]' \
-a sampleInput '{"appId":"xxx-xxx-xx", "appSecret":"yyy-yyy-yyy", "events":"onDeviceRegister"}' \
-a sampleOutput '{"tagName": "tagName","eventType": "onDeviceRegister","applicationId": "xxx-xxx-xx"}'


$WSK_CLI -i --apihost "$APIHOST" action update --auth "$AUTH" --shared yes pushnotifications/sendMessage "$PACKAGE_HOME/actions/sendMessage.js" \
-a description 'Send push notification to all application users or to a specific set of devices' \
-a parameters '[ {"name":"appId", "required":true, "description":"Bluemix application GUID"}, {"name":"appSecret", "required":true, "bindTime":true, "type":"password", "description":"Bluemix Push Service Secret"}, {"name":"text", "required":true, "description":"The notification message to be shown to the user"}, {"name":"url", "required":false, "description":"An optional URL that can be sent along with the alert"}, {"name":"deviceIds", "required":false, "description":"Array of device IDs"}, {"name":"platforms", "required":false, "description":"Array of device platform"},{"name":"tagNames", "required":false, "description":"Array of tag names"},{"name":"gcmPayload", "required":false, "description":"Additional payload"},{"name":"gcmSound", "required":false, "description":"Sound file name"},{"name":"gcmCollapseKey", "required":false, "description":"This parameter identifies a group of messages"},{"name":"gcmDelayWhileIdle", "required":false, "description":"Send message when device is active"}, {"name":"gcmPriority", "required":false, "description":"Sets the priority of the message"}, {"name":"gcmTimeToLive", "required":false, "description":"Time limit for message to be delievered"}, {"name":"apnsBadge", "required":false, "description":"Value for Badge"}, {"name":"apnsCategory", "required":false, "description":"The category name"}, {"name":"apnsIosActionKey", "required":false, "description":"Title for the push notification action Key"},{"name":"apnsPayload", "required":false, "description":"Additional payload"},{"name":"apnsType", "required":false, "description":"Push notification type name"},{"name":"apnsSound", "required":false, "description":"APNS sound name"}]' \
-a sampleInput '{"appId":"xxx-xxx-xx", "appSecret":"yyy-yyy-yyy", "text":"hi there"}' \
-a sampleOutput '{"pushResponse": {"messageId":"11111s","message":{"message":{"alert":"register for tag"}}}}'
