#!/usr/bin/env bash
set -e

VMID="$1"
VM_NAME="$2"
VM_IP="$3"

INVENTORY_FILE="/root/proxmox-ansible/inventory.ini"
CREATE_PLAYBOOK="/root/proxmox-ansible/create-vm.yml"
CONFIG_PLAYBOOK="/root/vm-konfiguration/site.yml"

echo "==> VM wird erstellt..."
ansible-playbook -i "$INVENTORY_FILE" "$CREATE_PLAYBOOK" \
  -e "vmid=$VMID vm_name=$VM_NAME vm_ip=$VM_IP"

echo "==> Inventory wird aktualisiert..."
cat <<EOF > "$INVENTORY_FILE"
[desktop_vms:vars]
ansible_user=admin
ansible_ssh_private_key_file=/root/.ssh/id_ed25519
ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[desktop_vms]
${VM_NAME} ansible_host=${VM_IP}
EOF

echo "==> Warten auf SSH..."
sleep 20

ANSIBLE_HOST_KEY_CHECKING=False ansible -i "$INVENTORY_FILE" desktop_vms \
  -m wait_for_connection -a "timeout=300 sleep=5"

echo "==> Verbindung testen..."
ANSIBLE_HOST_KEY_CHECKING=False ansible -i "$INVENTORY_FILE" desktop_vms -m ping

echo "==> Konfiguration starten..."
cd /root/vm-konfiguration
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i "$INVENTORY_FILE" "$CONFIG_PLAYBOOK"

echo "==> Fertig. VM ist bereit."
