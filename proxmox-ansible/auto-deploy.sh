#!/usr/bin/env bash
set -e

FULL_DEPLOY="/root/proxmox-ansible/full-deploy.sh"

# ----- Proxmox API -----
PROXMOX_HOST="192.168.30.99"
PROXMOX_USER="root@pam"
PROXMOX_PASSWORD="********"

# ----- IP Bereich -----
START_IP=168
END_IP=199

# ----- VMID automatisch bestimmen -----
VMID=$(python3 - << 'PY'
import json, ssl, urllib.parse, urllib.request

host = "192.168.30.99"
user = "root@pam"
password = "********"

ctx = ssl._create_unverified_context()
base = f"https://{host}:8006/api2/json"

data = urllib.parse.urlencode({
    "username": user,
    "password": password
}).encode()

req = urllib.request.Request(f"{base}/access/ticket", data=data, method="POST")
with urllib.request.urlopen(req, context=ctx) as r:
    ticket_data = json.load(r)["data"]

ticket = ticket_data["ticket"]

req = urllib.request.Request(
    f"{base}/cluster/resources?type=vm",
    headers={"Cookie": f"PVEAuthCookie={ticket}"}
)

with urllib.request.urlopen(req, context=ctx) as r:
    items = json.load(r)["data"]

used_vmids = sorted(int(item["vmid"]) for item in items if "vmid" in item)

expected = 100
for vmid in used_vmids:
    if vmid != expected:
        print(expected)
        break
    expected += 1
else:
    print(expected)
PY
)

# ----- VM Name -----
VM_NAME=$(printf "vm-%02d" $((VMID % 100)))

# ----- IP automatisch bestimmen -----
VM_IP=""
for i in $(seq "$START_IP" "$END_IP"); do
  IP="192.168.30.$i"
  if ! ping -c 1 -W 1 "$IP" >/dev/null 2>&1; then
    VM_IP="$IP"
    break
  fi
done

echo "Neue VM wird erstellt:"
echo "Name: $VM_NAME"
echo "VMID: $VMID"
echo "IP:   $VM_IP"

# Alte SSH Keys entfernen
ssh-keygen -f '/root/.ssh/known_hosts' -R "$VM_IP" >/dev/null 2>&1 || true

"$FULL_DEPLOY" "$VMID" "$VM_NAME" "$VM_IP"
