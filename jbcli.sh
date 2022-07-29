#!/bin/bash

# This script is used to perform numerous awscli tasks a bit easier

set -e

TYPE=$(gum choose "info" "tag" "create" "delete" "create temporary IAM user password")

if [ "$TYPE" == "create temporary IAM user password" ]; then
  IAMUSER=$(gum input --placeholder "IAM username") && \
	  gum confirm "Create temporary credentials for $IAMUSER?" && \
	  gum spin -s dot --title "Working on it..." -- sleep 3 && \
	  export "TEMPPASS=$(curl -sL pwgen.btmn.dev/20)" && \
	  echo "Temporary password is: $TEMPPASS" && \
	  aws iam create-login-profile --user-name "$IAMUSER" --password "$TEMPPASS" --password-reset-required
fi
