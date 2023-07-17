#!/bin/bash

#input parameters

while getopts u:p:s:o: flag
do
    case "${flag}"
        in
        u)USER_NAME=${OPTARG};;
        p)PASSWORD=${OPTARG};;
        s)SERVER=${OPTARG};;
        o)ORG=${OPTARG}
    esac
done

if [ -z "$USER_NAME" ]
    then echo "User name shall be provided, please check"
    exit 0
fi

if [ -z "$PASSWORD" ]
    then echo "Password shall be provided, please check"
    exit 0
fi

if [ -z "$USER_NAME" ]
    then echo "User name shall be provided, please check"
    exit 0
fi

#constants
ROLE_NAME="Transfer-$ORG-role"
PERMISSIONS_POLICY_FILE="s3-access-policy.json"
TRUST_POLICY_FILE="transfer-trust-policy.json"

echo username: $USER_NAME / Password: $PASSWORD / Server: $SERVER / Organization: $ORG

#Check if the role exists
aws iam get-role --role-name "$ROLE_NAME" >/dev/null 2>&1

if [ $? -eq 0 ]; then
  # Role exists, retrieve and store the ARN
    ARN=$(aws iam get-role --role-name "$ROLE_NAME" --query 'Role.Arn' --output text)
    echo "The role '$ROLE_NAME' already exists with ARN: $ARN"
else
  # Role does not exist, create it and store the ARN
    OUTPUT=$(aws iam create-role \
    --role-name "$ROLE_NAME" \
    --assume-role-policy-document "file://$TRUST_POLICY_FILE" \
    --permissions-boundary "file://$PERMISSIONS_POLICY_FILE")

    if [ -z "$OUTPUT" ]
        then echo "Role not created"
        exit 0
    fi

    ARN=$(echo "$OUTPUT" | grep -oP '(?<="Arn": ")[^"]+')
    echo "The role '$ROLE_NAME' was created with ARN: $ARN"
fi

