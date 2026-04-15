#!/usr/bin/env bash
set -e

VMID="$1"
VM_NAME="$2"
VM_IP="$3"

if [ -z "$VMID" ] || [ -z "$VM_NAME" ] || [ -z "$VM_IP" ]; then
  echo "Verwendung: ./full-deploy.sh <VMID> <VM_NAME> <VM_IP>"
  exit 1
fi

INVENTORY_FILE="/root/proxmox-ansible/inventory.ini"
CREATE_PLAYBOOK="/root/proxmox-ansible/create-vm.yml"
CONFIG_PLAYBOOK="/root/vm-konfiguration/site.yml"

echo "==> VM wird erstellt ..."
ansible-playbook -i "$INVENTORY_FILE" "$CREATE_PLAYBOOK" \
  -e "vmid=$VMID vm_name=$VM_NAME vm_ip=$VM_IP"

echo "==> Inventory wird aktualisiert ..."
cat << EOI > "$INVENTORY_FILE"
[desktop_vms:vars]
ansible_user=admin
ansible_ssh_private_key_file=/root/.ssh/id_ed25519
ansible_python_interpreter=/usr/bin/python3.13
ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[desktop_vms]
${VM_NAME} ansible_host=${VM_IP}
EOI

echo "==> Erste Wartezeit nach VM-Start ..."
sleep 20

echo "==> Warten auf SSH mit Ansible ..."
ANSIBLE_HOST_KEY_CHECKING=False ansible -i "$INVENTORY_FILE" desktop_vms -m wait_for_connection -a "timeout=300 sleep=5"

echo "==> Ansible-Verbindung wird getestet ..."
ANSIBLE_HOST_KEY_CHECKING=False ansible -i "$INVENTORY_FILE" desktop_vms -m ping

echo "==> Desktop-Konfiguration wird gestartet ..."
cd /root/vm-konfiguration
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i "$INVENTORY_FILE" "$CONFIG_PLAYBOOK"

echo "==> Fertig. Die VM ist bereit."
