#!/usr/bin/env bash
# Syncs EFS

if [ -z "${1}" ]; then
    echo  'usage: ./argox-efs-sync.sh <sync direction - ecs-k8s|k8s-ecs> [create-mounts]'
    exit 1
fi

which rsync >/dev/null || {
  echo  'ERR: rsync command is not installed'
  exit 1
}

SYNC_DIRECTION=${1}

export ARGOX_ECS_MOUNT_DIR=argox-efs-ecs
export ARGOX_K8S_MOUNT_DIR=argox-efs-k8s
export DRAW_ECS_MOUNT_DIR=draw-efs-ecs
export DRAW_K8S_MOUNT_DIR=draw-efs-k8s
export ARGOX_ECS_EFS_ID=fs-0bae549cc0ce5f86c
export ARGOX_K8S_EFS_ID=fs-0f010496611d43c61
export DRAW_ECS_EFS_ID=fs-09cd52071d5b8f864
export DRAW_K8S_EFS_ID=fs-00616d8d24173cb63


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
    # sudo chown -R 777 ${ARGOX_K8S_MOUNT_DIR}
    # sudo chown -R 777 ${DRAW_K8S_MOUNT_DIR}
elif [ "${SYNC_DIRECTION}" == "k8s-ecs" ]; then
    echo "Syncing ${ARGOX_K8S_MOUNT_DIR} -> ${ARGOX_ECS_MOUNT_DIR} ..."
    sudo rsync -aP ${ARGOX_K8S_MOUNT_DIR}/ ${ARGOX_ECS_MOUNT_DIR}/
    echo "Syncing ${DRAW_K8S_MOUNT_DIR} -> ${DRAW_ECS_MOUNT_DIR} ..."
    sudo rsync -aP ${DRAW_K8S_MOUNT_DIR}/ ${DRAW_ECS_MOUNT_DIR}/
    # echo "Setting permissions for  ${ARGOX_ECS_MOUNT_DIR} and ${DRAW_ECS_MOUNT_DIR} ..."
    # sudo chown -R 777 ${ARGOX_ECS_MOUNT_DIR}
    # sudo chown -R 777 ${DRAW_ECS_MOUNT_DIR}
else
    echo "ERR: Unregognized sync directon: ${SYNC_DIRECTION}. Must be 'ecs-k8s' or 'k8s-ecs'."
    exit 1
fi