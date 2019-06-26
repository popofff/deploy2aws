#!/bin/bash 
display_usage() {
        echo -e "\nThis script accepts only one argument - dev|stg|prod" 
        echo -e "\nIt is sourcing variables from aws_settings file, variables from artifact file and from "Secret variables" of gitlab" 
	echo -e "\nUsage:\n get_codehash.sh dev|stg \n" 
        }
# if less than two arguments supplied, display usage 
        if [  $# -le 0 ]
        then
                display_usage
                exit 1
        fi
#Loading the CodeHash from the artifact
pwd
source ./variables;
#Loading the creds and region from file readable only from root
source /etc/deploy2aws/aws_settings;

if [ $1 == "dev" ]; 
then configscodehash=$(aws cloudformation --region $AWS_DEFAULT_REGION_DEV describe-stacks --stack-name $STACK_NAME --output=json |grep -E 'OutputKey|OutputValue' | grep -A1 -E '"ConfigsCodeHash"' | cut -d" " -f22-50 | tr -d '"|,' |sed -n 2p );
#Printing the CodeHash before updating the stack
echo "CodeHash Before Update: " && aws cloudformation --region $AWS_DEFAULT_REGION_DEV describe-stacks --stack-name $STACK_NAME --output json|grep -E 'OutputKey|OutputValue' | grep -A1 -E '"CodeHash"' | cut -d" " -f22-50 | tr -d '"|,' |sed -n 2p;
#Updating the DEV stack
aws cloudformation --region $AWS_DEFAULT_REGION_DEV update-stack --stack-name $STACK_NAME --use-previous-template --parameters ParameterKey=CodeHash,ParameterValue=$SavedCodeHash ParameterKey=ConfigsCodeHash,ParameterValue=$configscodehash --capabilities "CAPABILITY_IAM";

elif [ $1 == "stg" ];
then configscodehash=$(aws cloudformation --region $AWS_DEFAULT_REGION_STG describe-stacks --stack-name $STACK_NAME --output=json |grep -E 'OutputKey|OutputValue' | grep -A1 -E '"ConfigsCodeHash"' | cut -d" " -f22-50 | tr -d '"|,' |sed -n 2p );
#Printing the CodeHash before updating the stack
echo "CodeHash Before Update: " && aws cloudformation --region $AWS_DEFAULT_REGION_STG describe-stacks --stack-name $STACK_NAME --output json|grep -E 'OutputKey|OutputValue' | grep -A1 -E '"CodeHash"' | cut -d" " -f22-50 | tr -d '"|,' |sed -n 2p;
#Updating the STG stack
aws cloudformation --region $AWS_DEFAULT_REGION_STG update-stack --stack-name $STACK_NAME --use-previous-template --parameters ParameterKey=CodeHash,ParameterValue=$SavedCodeHash ParameterKey=ConfigsCodeHash,ParameterValue=$configscodehash --capabilities "CAPABILITY_IAM";

elif [[ "${USERS_ALLOWED_LIST[@]}" =~ "${GITLAB_USER_LOGIN}" && $1 == "prod" ]];
then
configscodehash=$(aws cloudformation --region $AWS_DEFAULT_REGION_PROD describe-stacks --stack-name $STACK_NAME --output=json |grep -E 'OutputKey|OutputValue' | grep -A1 -E '"ConfigsCodeHash"' | cut -d" " -f22-50 | tr -d '"|,' |sed -n 2p );
#Printing the CodeHash before updating the stack
echo "CodeHash Before Update: " && aws cloudformation --region $AWS_DEFAULT_REGION_PROD describe-stacks --stack-name $STACK_NAME --output json|grep -E 'OutputKey|OutputValue' | grep -A1 -E '"CodeHash"' | cut -d" " -f22-50 | tr -d '"|,' |sed -n 2p;
#Updating the PROD stack
aws cloudformation --region $AWS_DEFAULT_REGION_PROD update-stack --stack-name $STACK_NAME --use-previous-template --parameters ParameterKey=CodeHash,ParameterValue=$SavedCodeHash ParameterKey=ConfigsCodeHash,ParameterValue=$configscodehash --capabilities "CAPABILITY_IAM";
else
    echo "You are not allowed to update the PRODUCTION stack" && exit 1;
fi
