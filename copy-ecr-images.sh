#!/usr/bin/env bash
# Copies container images between ECR repos that are named the same 
# and are in different AWS accounts/regions.

SOURCE_AWS_PROFILE_NAME="dev"
SOURCE_AWS_REGION="us-east-1"
DEST_AWS_PROFILE_NAME="argox_dyn"
DEST_AWS_REGION="us-east-1"
IMAGE_TAG="latest"
NEED_REPOS_NAMES=(
"den-processor-sheet"
"den-static-file-server"
"den-processor-gltf-engine"
"den-processor-bimdb"
"den-processor-matchingdb"
"den-processor-issuedb"
"den-processor-ifc-parser"
"den-processor-filedb"
"den-reactapp"
"den-service-sheet-matching"
"den-service-sheet-stitching"
"den-gateway"
"den-service"
"den-processor-project"
"den-processor-externalbimdata"
"den-status-engine"
"dai-matching-service"
"dai-template-service"
"dai-ocr-service"
"dai-document-processor"
"dai-object-detection-service"
"dai-gateway-api"
"dai-text-processing-service"
"dai-document-service"
"dai-stitching-service"
"dai-notification-service"
"dai-page-processor")

AUTO_APPROVE='false'

for c in "aws" "jq" "docker"
do
    which $c > /dev/null || {
        echo "$c is not installed."
        exit 1
    }
done

function user_confirmation () {
    read -p "${1} To confirm type 'yes': " a
    if [ "${a}" != "yes" ]; then
        echo "Aborted by user."
        exit 0
    fi
}

echo "Seting up source AWS profile..."
export AWS_PROFILE=$SOURCE_AWS_PROFILE_NAME
export SOURCE_ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')
echo "Source account Id is ${SOURCE_ACCOUNT_ID}"
echo "Source AWS region is ${SOURCE_AWS_REGION}"

[ "${AUTO_APPROVE}" != 'true' ] && user_confirmation "Do you with to proceed with image pull?"

echo "Seting up docker credentitals for source account..."
aws ecr get-login-password --region ${SOURCE_AWS_REGION} | docker login --username AWS --password-stdin "${SOURCE_ACCOUNT_ID}.dkr.ecr.${SOURCE_AWS_REGION}.amazonaws.com"

echo "Pulling images..."
for r in ${NEED_REPOS_NAMES[@]}
do
    docker pull "${SOURCE_ACCOUNT_ID}.dkr.ecr.${SOURCE_AWS_REGION}.amazonaws.com/${r}:${IMAGE_TAG}"
done

echo "Seting up destination AWS profile..."
export AWS_PROFILE=$DEST_AWS_PROFILE_NAME
export DEST_ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')
echo "Destination account Id is ${DEST_ACCOUNT_ID}"
echo "Destination AWS region is ${DEST_AWS_REGION}"

[ "${AUTO_APPROVE}" != 'true' ] && user_confirmation "Do you with to proceed with image push?"

echo "Retaging local images..."
for r in ${NEED_REPOS_NAMES[@]}
do
    docker tag "${SOURCE_ACCOUNT_ID}.dkr.ecr.${SOURCE_AWS_REGION}.amazonaws.com/${r}:${IMAGE_TAG}" "${DEST_ACCOUNT_ID}.dkr.ecr.${DEST_AWS_REGION}.amazonaws.com/${r}:${IMAGE_TAG}"
done

echo "Seting up docker credentitals for destination account..."
aws ecr get-login-password --region ${DEST_AWS_REGION} | docker login --username AWS --password-stdin ${DEST_ACCOUNT_ID}.dkr.ecr.${DEST_AWS_REGION}.amazonaws.com

echo "Pusing images..."
for r in ${NEED_REPOS_NAMES[@]}
do
    docker push "${DEST_ACCOUNT_ID}.dkr.ecr.${DEST_AWS_REGION}.amazonaws.com/${r}:${IMAGE_TAG}"
done
