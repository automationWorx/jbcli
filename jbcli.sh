#!/bin/bash

# This script is used to perform numerous awscli tasks a bit easier

set -e

TYPE=$(gum choose "info" "tag" "create" "delete" "create temporary IAM user password")
IAMUSER=$(gum input --placeholder "IAM username")

gum spin -s meter --title "Working on it..." -- sleep 3

gum confirm "Create temporary credentials for $IAMUSER?" && export "TEMPPASS=$(curl -sL pwgen.btmn.dev/20)" && echo "Temporary password is: $TEMPPASS"  && aws iam create-login-profile --user-name "$IAMUSER" --password "$TEMPPASS" --password-reset-required
