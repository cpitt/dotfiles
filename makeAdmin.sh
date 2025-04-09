#!/usr/bin/env bash

# This script removes JAMFs temporary admin grant making the user a permanent admin

sudo echo "Unloading removeAdmin.plist"
sudo launchctl unload /Library/LaunchDaemons/removeAdmin.plist >&/dev/null || true

sudo echo "Removing files"
sudo [ -f /Library/LaunchDaemons/removeAdmin.plist ] && sudo rm /Library/LaunchDaemons/removeAdmin.plist
sudo [ -f /Library/Application\ Support/JAMF/removeAdminRights.sh ] && sudo rm /Library/Application\ Support/JAMF/removeAdminRights.sh
sudo [ -f /private/var/userToRemove/user ] && sudo rm /private/var/userToRemove/user
