#!/bin/bash

# This script is used to perform numerous awscli tasks a bit easier

set -e

TYPE=$(gum choose "info" "tag" "create" "delete" "IAM password" "Parameter Store")

###############################
######## Info options #########
###############################

if [ "$TYPE" == "info" ]; then
  AWSSERVICE=$(gum choose "ec2" "rds")
fi

if [ "$AWSSERVICE" == "rds" ]; then
  RDSINFO=$(gum choose "engine versions")
  if [ "$RDSINFO" == "engine versions" ]; then
    VAGOVSERVICE=$(gum choose "cms" "console-api" "console-ui" \
    "gi-bill-data-service" "grafana" "keycloak" "sentry" "vets-api")
    gum spin -s dot --title "Retrieving database info..." -- sleep 3
    for db in $(aws rds describe-db-instances | \
    jq -r '.DBInstances[].DBInstanceIdentifier' | \
    grep $VAGOVSERVICE | grep -wv appeals); do echo $db
    aws rds describe-db-instances --db-instance-identifier $db | \
    jq -r '.DBInstances[] | .Engine, .EngineVersion' && echo ""; done
  fi
fi

################################
######### Tag options ##########
################################

################################
######## Create options ########
################################

################################
######## Delete options ########
################################

################################
##### IAM password options #####
################################

if [ "$TYPE" == "IAM password" ]; then
  USERPASS=$(gum choose "create first-time login credentials" "update existing password")
fi

if [ "$USERPASS" == "create first-time login credentials" ]; then
  IAMUSER=$(gum input --placeholder "IAM username")
  gum confirm "Create temporary credentials for $IAMUSER?"
  gum spin -s dot --title "Creating credentials for $IAMUSER..." -- sleep 3
  export "TEMPPASS=$(curl -sL pwgen.btmn.dev/20)1!"
  echo "Temporary password is: $TEMPPASS"
  aws iam create-login-profile --user-name "$IAMUSER" --password "$TEMPPASS" --password-reset-required
fi

if [ "$USERPASS" == "update existing password" ]; then
  IAMUSER=$(gum input --placeholder "IAM username")
  gum confirm "Update existing password for $IAMUSER?"
  gum spin -s dot --title "Updating credentials for $IAMUSER..." -- sleep 3
  export "TEMPPASS=$(curl -sL pwgen.btmn.dev/20)1!"
  echo "Temporary password is: $TEMPPASS"
  aws iam update-login-profile --user-name "$IAMUSER" --password "$TEMPPASS" --password-reset-required
fi

################################
##### Param Store options ######
################################

if [ "$TYPE" == "Parameter Store" ]; then
  ACTION=$(gum choose "create" "update" "retrieve" "delete")
fi

if [ "$ACTION" == "create" ]; then
  VASERVICE=$(gum choose "vets-api" "vets-website")
    if [ "$VASERVICE" == "vets-api" ]; then
      ENV=$(gum choose "dev" "staging" "sandbox" "prod")
      INTSERVICE=$(gum input --placeholder "Underlying Integration Service")
      if [ "$ENV" == "dev" ]; then
        KEY=$(gum input --placeholder "Enter key / name of secret")
        SECRETVALUE=$(gum input --placeholder "Enter secret value")
        gum confirm "Create new secret with path /dsva-vagov/$VASERVICE/$ENV/$INTSERVICE/$KEY?"
        gum spin -s dot --title "Creating parameter..." -- sleep 3
        aws ssm put-parameter --name /dsva-vagov/$VASERVICE/$ENV/$INTSERVICE/$KEY \
        --type SecureString \
        --value $SECRETVALUE
      fi
      if [ "$ENV" == "staging" ]; then
        KEY=$(gum input --placeholder "Enter key / name of secret")
        SECRETVALUE=$(gum input --placeholder "Enter secret value")
        gum confirm "Create new secret with path /dsva-vagov/$VASERVICE/$ENV/$INTSERVICE/$KEY?"
        gum spin -s dot --title "Creating parameter..." -- sleep 3
        aws ssm put-parameter --name /dsva-vagov/$VASERVICE/$ENV/$INTSERVICE/$KEY \
        --type SecureString \
        --value $SECRETVALUE
      fi
      if [ "$ENV" == "sandbox" ]; then
        KEY=$(gum input --placeholder "Enter key / name of secret")
        SECRETVALUE=$(gum input --placeholder "Enter secret value")
        gum confirm "Create new secret with path /dsva-vagov/$VASERVICE/$ENV/$INTSERVICE/$KEY?"
        gum spin -s dot --title "Creating parameter..." -- sleep 3
        aws ssm put-parameter --name /dsva-vagov/$VASERVICE/$ENV/$INTSERVICE/$KEY \
        --type SecureString \
        --value $SECRETVALUE
      fi
      if [ "$ENV" == "prod" ]; then
        KEY=$(gum input --placeholder "Enter key / name of secret")
        SECRETVALUE=$(gum input --placeholder "Enter secret value")
        gum confirm "Create new secret with path /dsva-vagov/$VASERVICE/$ENV/$INTSERVICE/$KEY?"
        gum spin -s dot --title "Creating parameter..." -- sleep 3
        aws ssm put-parameter --name /dsva-vagov/$VASERVICE/$ENV/$INTSERVICE/$KEY \
        --type SecureString \
        --value $SECRETVALUE
      fi
    fi
fi

if [ "$ACTION" == "update" ]; then
  UPDATEPARAM=$(gum input --placeholder "Enter Parameter Store path to value you wish to view")
  SECRETVALUE=$(gum input --placeholder "Enter secret value")
  gum confirm "Update secret with path $UPDATEPARAM?"
  gum spin -s dot --title "Updating parameter..." -- sleep 3
  aws ssm put-parameter --name $UPDATEPARAM \
  --type SecureString \
  --value $SECRETVALUE \
  --overwrite
  echo "Parameter updated!"
fi

if [ "$ACTION" == "retrieve" ]; then
  RETRIEVEPARAM=$(gum input --placeholder "Enter Parameter Store path to value you wish to view")
  gum confirm "Retrieve secret with path $RETRIEVEPARAM?"
  gum spin -s dot --title "Retrieving parameter..." -- sleep 3
  aws ssm get-parameter --name "$RETRIEVEPARAM" \
  --with-decryption | \
  jq -r .Parameter.Value
fi

if [ "$ACTION" == "delete" ]; then
  DELETEPARAM=$(gum input --placeholder "Enter Parameter Store path to value you wish to delete")
  gum confirm "Delete secret with path $DELETEPARAM?"
  gum spin -s dot --title "Deleting parameter..." -- sleep 3
  aws ssm delete-parameter --name $DELETEPARAM
  echo "Parameter deleted!"
fi
