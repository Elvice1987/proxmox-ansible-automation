# Dokumentation – Automatisierung von virtuellen Maschinen mit Proxmox und Ansible

---

## Projektübersicht

Dieses Projekt automatisiert die Erstellung und Konfiguration von virtuellen Maschinen (VMs) mithilfe von Proxmox und Ansible.

Ziel ist es, neue Systeme schnell, effizient und ohne manuelle Eingriffe bereitzustellen.

---

## Projektziel

- Automatische Erstellung von VMs
- Automatische Konfiguration (XFCE, XRDP, Benutzer)
- Sofort einsatzbereite Systeme
- Reduzierung von manuellen Aufgaben

---

## Verwendete Technologien

- Proxmox VE (Virtualisierung)
- Ansible (Automatisierung)
- Cloud-Init (Initialisierung)
- Bash (Skripte)
- SSH (Verbindung)

---

## Projektstruktur
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

## Ablauf (Workflow)

1. Start von `auto-deploy.sh`
2. Erstellung der VM mit `create-vm.yml`
3. Cloud-Init konfiguriert Netzwerk und Benutzer
4. Warten auf SSH-Verbindung
5. Konfiguration mit Ansible (`site.yml`)
6. VM ist einsatzbereit

---

## Automatisierungslogik

### VMID-Verwaltung

- Das System wählt automatisch den kleinsten freien VMID
- Beispiel:
  - Vorhanden: 100, 101, 102, 200
  - Neu: 103

---

### IP-Adressverwaltung

- Automatische Erkennung der ersten freien IP-Adresse
- Wiederverwendung von IP-Adressen nach Löschung einer VM

---

### Namensschema

- Kurzes und klares Format:
vm-01  
vm-02  
vm-03


- Basierend auf den letzten zwei Ziffern des VMID

---

## Optimierung durch Template

Ein optimiertes Template wurde erstellt mit:

- XFCE Desktop
- XRDP
- Anwendungen

➡ Vorteil:
- Sehr schnelle Bereitstellung
- Keine erneute Installation notwendig

---

## Sicherheit

- SSH Key Authentication (kein Passwort notwendig)
- Passwort-Hashing für Benutzer
- Automatische Host-Key-Bereinigung

---

## Nutzung

```bash
cd ~/proxmox-ansible
./auto-deploy.sh

## Ergebnis

-   Vollständig automatisiertes Deployment
-   Schnelle VM-Erstellung (wenige Sekunden)
-   Konsistente und saubere Infrastruktur
-   Reduzierung manueller Fehler

---

## Screenshots – Projektübersicht

### SSH Verbindung
![SSH](images/ssh-connection.png)

---

### Ansible Deployment
![Ansible](images/ansible-deploy.png)

---

### XRDP Login
![XRDP](images/xrdp-login.png)

---

### XFCE Desktop
![XFCE](images/xfce-desktop.png)

