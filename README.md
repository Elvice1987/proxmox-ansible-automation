# 🚀 Proxmox + Ansible VM Automation

![Automation](https://img.shields.io/badge/Automation-100%25-brightgreen)
![Ansible](https://img.shields.io/badge/Ansible-Configured-blue)
![Proxmox](https://img.shields.io/badge/Proxmox-VMs-orange)

---

## 📌 Projektbeschreibung

Dieses Projekt automatisiert die Erstellung und Konfiguration von virtuellen Maschinen mit **Proxmox** und **Ansible**.

Neue virtuelle Maschinen können automatisch erstellt und innerhalb weniger Sekunden vollständig konfiguriert werden.

---

## 🎯 Ziele

- Automatische VM-Erstellung
- Automatische Konfiguration
- XFCE Desktop Umgebung
- Remote Zugriff über XRDP
- Vollautomatischer Ablauf ohne manuelle Eingriffe

---

## ⚙️ Technologien

- 🖥️ Proxmox VE
- ⚙️ Ansible
- ☁️ Cloud-Init
- 🐧 Linux (Debian)
- 🔐 SSH

---

## 🧩 Projektstruktur

proxmox-ansible/
├── create-vm.yml
├── full-deploy.sh
├── auto-deploy.sh
├── inventory.ini

vm-konfiguration/
├── site.yml
└── roles/
└── xfce_xrdp/
└── tasks/
└── main.yml

---

## 🔄 Workflow

auto-deploy.sh → VM erstellen → SSH warten → Ansible konfigurieren → Fertige VM

---

## ⚡ Optimierung

Template enthält bereits:
- XFCE
- XRDP
- Anwendungen

→ sehr schnelle Bereitstellung

---

## 🔐 Sicherheit

- SSH Keys
- Passwort Hashing

---

## 🚀 Nutzung

```bash
cd proxmox-ansible
./auto-deploy.sh
