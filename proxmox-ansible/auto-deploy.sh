#!/usr/bin/env bash
set -e

FULL_DEPLOY="/root/proxmox-ansible/full-deploy.sh"

# ----- Proxmox API -----
PROXMOX_HOST="192.168.30.99"
PROXMOX_USER="root@pam"
PROXMOX_PASSWORD="12345678"

# ----- IP-Bereich -----
START_IP=100
END_IP=199

# Trouver le plus petit VMID libre à partir des vrais VMIDs Proxmox
VMID=$(python3 - << 'PY'
import json
import ssl
import urllib.parse
import urllib.request

host = "192.168.30.99"
user = "root@pam"
password = "12345678"

ctx = ssl._create_unverified_context()
base = f"https://{host}:8006/api2/json"

data = urllib.parse.urlencode({
    "username": user,
    "password": password
}).encode()

req = urllib.request.Request(f"{base}/access/ticket", data=data, method="POST")
with urllib.request.urlopen(req, context=ctx, timeout=30) as r:
    ticket_data = json.load(r)["data"]

ticket = ticket_data["ticket"]

req = urllib.request.Request(
    f"{base}/cluster/resources?type=vm",
    headers={"Cookie": f"PVEAuthCookie={ticket}"}
)
with urllib.request.urlopen(req, context=ctx, timeout=30) as r:
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

if [ -z "$VMID" ]; then
  echo "FEHLER: Kein freier VMID gefunden."
  exit 1
fi

# Nom cohérent avec le VMID
VM_NAME=$(printf "vm-%02d" $((VMID % 100)))

# Trouver la plus petite IP libre
VM_IP=""
for i in $(seq "$START_IP" "$END_IP"); do
  IP="192.168.30.$i"
  if ! ping -c 1 -W 1 "$IP" >/dev/null 2>&1; then
    VM_IP="$IP"
    break
  fi
done

if [ -z "$VM_IP" ]; then
  echo "FEHLER: Keine freie IP gefunden."
  exit 1
fi

echo "Neue VM wird erstellt:"
echo "Name: $VM_NAME"
echo "VMID: $VMID"
echo "IP:   $VM_IP"

# ancienne host key éventuelle
ssh-keygen -f '/root/.ssh/known_hosts' -R "$VM_IP" >/dev/null 2>&1 || true

"$FULL_DEPLOY" "$VMID" "$VM_NAME" "$VM_IP"
