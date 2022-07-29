#!/bin/bash

# This script is used to perform numerous awscli tasks a bit easier

set -e

TYPE=$(gum choose "info" "tag" "create" "delete" "IAM password")

if [ "$TYPE" == "IAM password" ]; then
  USERPASS=$(gum choose "create first-time login credentials" "update existing password")
fi

if [ "$USERPASS" == "create first-time login credentials" ]; then
  IAMUSER=$(gum input --placeholder "IAM username") && \
	  gum confirm "Create temporary credentials for $IAMUSER?" && \
	  gum spin -s dot --title "Working on it..." -- sleep 3 && \
	  export "TEMPPASS=$(curl -sL pwgen.btmn.dev/20)!" && \
	  echo "Temporary password is: $TEMPPASS" && \
	  aws iam create-login-profile --user-name "$IAMUSER" --password "$TEMPPASS" --password-reset-required
fi

if [ "$USERPASS" == "update existing password" ]; then
  IAMUSER=$(gum input --placeholder "IAM username") && \
          gum confirm "Update existing password for $IAMUSER?" && \
          gum spin -s dot --title "Working on it..." -- sleep 3 && \
          export "TEMPPASS=$(curl -sL pwgen.btmn.dev/20)!" && \
          echo "Temporary password is: $TEMPPASS" && \
          aws iam update-login-profile --user-name "$IAMUSER" --password "$TEMPPASS" --password-reset-required
fi
