#!/usr/bin/env bash
set -e

ANZAHL="$1"

if [ -z "$ANZAHL" ]; then
  echo "Verwendung: ./deploy-many.sh <ANZAHL>"
  exit 1
fi

START_VMID=202
START_IP=163
NAME_PREFIX="debian13-auto-"

for ((i=0; i<ANZAHL; i++)); do
  VMID=$((START_VMID + i))
  IP_END=$((START_IP + i))
  VM_IP="192.168.30.${IP_END}"
  VM_NAME="${NAME_PREFIX}$(printf "%02d" $((i+3)))"

  echo "======================================"
  echo "Neue VM wird bereitgestellt:"
  echo "VMID: ${VMID}"
  echo "Name: ${VM_NAME}"
  echo "IP:   ${VM_IP}"
  echo "======================================"

  /root/proxmox-ansible/full-deploy.sh "${VMID}" "${VM_NAME}" "${VM_IP}"
done

echo "Alle VMs wurden erstellt."
