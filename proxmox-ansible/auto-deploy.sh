#!/usr/bin/env bash
set -e

FULL_DEPLOY="/root/proxmox-ansible/full-deploy.sh"
LAST_FILE="/root/proxmox-ansible/.last_vm_number"

if [ ! -f "$LAST_FILE" ]; then
  echo 8 > "$LAST_FILE"
fi

LAST_NUM=$(cat "$LAST_FILE")
NEXT_NUM=$((LAST_NUM + 1))

VM_NAME="debian13-auto-${NEXT_NUM}"
VMID=$((200 + NEXT_NUM))
VM_IP="192.168.30.$((160 + NEXT_NUM))"

echo "$NEXT_NUM" > "$LAST_FILE"

echo "Neue VM wird erstellt:"
echo "Name: $VM_NAME"
echo "VMID: $VMID"
echo "IP:   $VM_IP"

"$FULL_DEPLOY" "$VMID" "$VM_NAME" "$VM_IP"
