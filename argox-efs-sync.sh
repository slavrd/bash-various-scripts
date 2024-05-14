#!/usr/bin/env bash
# Syncs EFS
set -e

if [ -z "${1}" ]; then
    echo  'usage: ./argox-efs-sync.sh <sync direction - ecs-k8s|k8s-ecs> [create-mounts]'
    exit 1
fi

which rsync >/dev/null || {
  echo  'ERR: rsync command is not installed'
  exit 1
}

which aws >/dev/null || {
  echo  'ERR: rsync command is not installed'
  exit 1
}

function getEFSName() {
  [ -z "${1}" ] && {
    echo 'No EFS name provided.'
    return 1
  }
  aws efs describe-file-systems | jq -r --arg n ${1} '.FileSystems[] | select(.Name == $n).FileSystemId'
}

SYNC_DIRECTION=${1}

export ARGOX_ECS_MOUNT_DIR='argox-efs-ecs'
export ARGOX_K8S_MOUNT_DIR='argox-efs-k8s'
export DRAW_ECS_MOUNT_DIR='draw-efs-ecs'
export DRAW_K8S_MOUNT_DIR='draw-efs-k8s'

export ARGOX_ECS_EFS_NAME='/den-storage'
export ARGOX_K8S_EFS_NAME='D02UE1-ARGOX-STORAGE'
export DRAW_ECS_EFS_NAME='dai-storage'
export DRAW_K8S_EFS_NAME='D02UE1-DRAW-STORAGE'

export ARGOX_ECS_EFS_ID=$(getEFSName ${ARGOX_ECS_EFS_NAME})
export ARGOX_K8S_EFS_ID=$(getEFSName ${ARGOX_K8S_EFS_NAME})
export DRAW_ECS_EFS_ID=$(getEFSName ${DRAW_ECS_EFS_NAME})
export DRAW_K8S_EFS_ID=$(getEFSName ${DRAW_K8S_EFS_NAME})


if [ "${2}" == "create-mounts" ]; then
  echo "WARNING: Creating mounts. In case a dirctory already exists it is assumed that the EFS is also mounted in it."
  [ -d "./${ARGOX_K8S_MOUNT_DIR}" ] || { 
    mkdir ${ARGOX_K8S_MOUNT_DIR}
    sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${ARGOX_K8S_EFS_ID}.efs.us-east-1.amazonaws.com:/ ${ARGOX_K8S_MOUNT_DIR}
  }
  [ -d "./${ARGOX_ECS_MOUNT_DIR}" ] || {
    mkdir ${ARGOX_ECS_MOUNT_DIR}
    sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${ARGOX_ECS_EFS_ID}.efs.us-east-1.amazonaws.com:/ ${ARGOX_ECS_MOUNT_DIR}
  }
  [ -d "./${DRAW_K8S_MOUNT_DIR}" ] || {
    mkdir ${DRAW_K8S_MOUNT_DIR}
    sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${DRAW_K8S_EFS_ID}.efs.us-east-1.amazonaws.com:/ ${DRAW_K8S_MOUNT_DIR}
  }
  [ -d "./${DRAW_ECS_MOUNT_DIR}" ] || {
    mkdir ${DRAW_ECS_MOUNT_DIR}
    sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${DRAW_ECS_EFS_ID}.efs.us-east-1.amazonaws.com:/ ${DRAW_ECS_MOUNT_DIR}
  }
fi

if [ "${SYNC_DIRECTION}" == "ecs-k8s" ]; then
    echo "Syncing ${ARGOX_ECS_MOUNT_DIR} -> ${ARGOX_K8S_MOUNT_DIR} ..."
    sudo rsync -aP ${ARGOX_ECS_MOUNT_DIR}/ ${ARGOX_K8S_MOUNT_DIR}/
    echo "Syncing ${DRAW_ECS_MOUNT_DIR} -> ${DRAW_K8S_MOUNT_DIR} ..."
    sudo rsync -aP ${DRAW_ECS_MOUNT_DIR}/ ${DRAW_K8S_MOUNT_DIR}/
    # echo "Setting permissions for  ${ARGOX_K8S_MOUNT_DIR} and ${DRAW_K8S_MOUNT_DIR} ..."
    # sudo chmod -R 777 ${ARGOX_K8S_MOUNT_DIR}
    # sudo chmod -R 777 ${DRAW_K8S_MOUNT_DIR}
elif [ "${SYNC_DIRECTION}" == "k8s-ecs" ]; then
    echo "Syncing ${ARGOX_K8S_MOUNT_DIR} -> ${ARGOX_ECS_MOUNT_DIR} ..."
    sudo rsync -aP ${ARGOX_K8S_MOUNT_DIR}/ ${ARGOX_ECS_MOUNT_DIR}/
    echo "Syncing ${DRAW_K8S_MOUNT_DIR} -> ${DRAW_ECS_MOUNT_DIR} ..."
    sudo rsync -aP ${DRAW_K8S_MOUNT_DIR}/ ${DRAW_ECS_MOUNT_DIR}/
    # echo "Setting permissions for  ${ARGOX_ECS_MOUNT_DIR} and ${DRAW_ECS_MOUNT_DIR} ..."
    # sudo chmod -R 777 ${ARGOX_ECS_MOUNT_DIR}
    # sudo chmod -R 777 ${DRAW_ECS_MOUNT_DIR}
else
    echo "ERR: Unregognized sync directon: ${SYNC_DIRECTION}. Must be 'ecs-k8s' or 'k8s-ecs'."
    exit 1
fi
