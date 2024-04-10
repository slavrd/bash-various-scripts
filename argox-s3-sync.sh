#!/usr/bin/env bash
# Syncs the ArgoX S3 buckets between the ECS and K8S deployments

USAGE_MSG='usage: ./arogx-s3-sync.sh [ecs-k8s|k8s-ecs]'
if [ -z ${1} ]; then
    echo ${USAGE_MSG}
    exit 1
fi
DIRECTION=${1}

ARGOX_ECS_BUCKET='dxxue1-den-files'
ARGOX_K8S_BUCKET='d02ue1-den-files'
DRAW_ECS_BUCKET='dxxue1-den-files-drawingai'
DRAW_K8S_BUCKET='d02ue1-den-files-drawingai'

if [ "${DIRECTION}" == "ecs-k8s" ]; then
    echo "Syncing s3://${ARGOX_ECS_BUCKET} -> s3://${ARGOX_K8S_BUCKET}"
    aws s3 sync s3://${ARGOX_ECS_BUCKET} s3://${ARGOX_K8S_BUCKET}
    echo "Syncing s3://${DRAW_ECS_BUCKET} -> s3://${DRAW_K8S_BUCKET}"
    aws s3 sync s3://${DRAW_ECS_BUCKET} s3://${DRAW_K8S_BUCKET}
elif [ "${DIRECTION}" == "k8s-ecs" ]; then
    echo "Syncing s3://${ARGOX_K8S_BUCKET} -> s3://${ARGOX_ECS_BUCKET}"
    aws s3 sync s3://${ARGOX_K8S_BUCKET} s3://${ARGOX_ECS_BUCKET}
    echo "Syncing s3://${DRAW_K8S_BUCKET} -> s3://${DRAW_ECS_BUCKET}"
    aws s3 sync s3://${DRAW_K8S_BUCKET} s3://${DRAW_ECS_BUCKET}
else
    echo ${USAGE_MSG}
fi