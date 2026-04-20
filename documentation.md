# 📄 **Automatisierung von virtuellen Maschinen mit Proxmox und Ansible**

----------

# **1. Einleitung**

Im Rahmen dieses Projekts wurde eine Lösung zur automatisierten Erstellung und Konfiguration von virtuellen Maschinen (VMs) entwickelt.

Die Umsetzung basiert auf den Technologien **Proxmox**, **Ansible**, **Cloud-Init** sowie **Shell-Skripten**. Ziel ist es, den gesamten Prozess – von der Erstellung bis zur fertigen Desktop-Umgebung – vollständig zu automatisieren.

Dies ermöglicht:

-   eine erhebliche Zeitersparnis
-   eine Reduzierung von Fehlern
-   eine standardisierte und reproduzierbare Infrastruktur

----------

# **2. Projektziel**

Die wichtigsten Ziele des Projekts sind:

-   Automatisierte Erstellung von virtuellen Maschinen
-   Automatische Konfiguration von Desktop-Systemen (XFCE, XRDP)
-   Bereitstellung sofort einsatzbereiter Systeme
-   Minimierung manueller Eingriffe

# **3. Systemübersicht**

Die folgende Abbildung zeigt den automatisierten Ablauf des Systems:

```mermaid
flowchart LR
    C["Client / Administrator"]
    S["auto-deploy.sh"]
    A["Ansible Control Node"]
    P["Proxmox Host"]
    VM["VM (Debian + Cloud-Init)"]
    CI["Cloud-Init Setup"]
    CFG["XFCE + XRDP Configuration"]

    C -->|Start Deployment| S
    S -->|Run Script| A
    A -->|Proxmox API Call| P
    P -->|Create VM| VM

    VM -->|Initialize| CI
    CI -->|Network & User Setup| VM

    A -->|SSH Connection| VM
    A -->|Run site.yml| CFG
    CFG --> VM
```
**Abbildung 1: Gesamtübersicht des Systems**

Die Darstellung verdeutlicht den vollständigen Ablauf von der Erstellung bis zur Konfiguration der virtuellen Maschine.

----------

# **4. Ablauf des automatisierten Deployments**
```mermaid
sequenceDiagram
    autonumber
    participant User
    participant Script
    participant Ansible
    participant Proxmox
    participant VM

    User->>Script: ./auto-deploy.sh
    Script->>Ansible: create-vm.yml
    Ansible->>Proxmox: API-Aufruf
    Proxmox->>VM: VM erstellen
    Proxmox->>VM: VM starten

    VM->>VM: Cloud-Init Konfiguration

    Ansible->>VM: Warten auf SSH
    Ansible->>VM: site.yml ausführen
```
**Abbildung 2: Ablauf des Deployments**

----------

# **5. Automatisierungslogik**
```mermaid
flowchart TD
    A([Start Script]) --> B[Freie VMID berechnen]
    B --> C[VM Name generieren]
    C --> D[Freie IP-Adresse finden]
    D --> E([VM erstellen])
```
**Abbildung 3: Automatisierungslogik**

----------


# **6. Verwendete Dateien und deren Inhalt**

----------

## **6.1 Skript `auto-deploy.sh`**

#!/usr/bin/env bash  
set  -e  
  
START_IP=168  
END_IP=199  
  
VMID=$(python3 ...)  
VM_NAME=$(printf "vm-%02d" $((VMID % 100)))  
  
for i in $(seq "$START_IP"  "$END_IP"); do  
  IP="192.168.30.$i"  
  if ! ping  -c  1  -W  1  "$IP"; then  
  VM_IP="$IP"  
 break  
  fi  
done  
  
./full-deploy.sh "$VMID"  "$VM_NAME"  "$VM_IP"

Dieses Skript berechnet automatisch VMID und IP und startet das Deployment.

----------

## **6.2 Skript `full-deploy.sh`**

VMID="$1"  
VM_NAME="$2"  
VM_IP="$3"  
  
ansible-playbook create-vm.yml \  
  -e  "vmid=$VMID vm_name=$VM_NAME vm_ip=$VM_IP"  
  
ansible -m  ping  
  
ansible-playbook site.yml

 Führt die komplette Erstellung und Konfiguration aus.

----------

## **6.3 Playbook `create-vm.yml`**

- name: Neue VM aus Template erstellen  
 hosts: localhost  
  
 tasks:  
 - name: VM klonen  
 community.proxmox.proxmox_kvm:  
 clone: "{{ template_name }}"  
 name: "{{ vm_name }}"  
 newid: "{{ vmid }}"  
  
 - name: Cloud-Init konfigurieren  
 community.proxmox.proxmox_kvm:  
 vmid: "{{ vmid }}"  
 ipconfig:  
 ipconfig0: "ip={{ vm_ip }}/24"  
  
 - name: VM starten  
 community.proxmox.proxmox_kvm:  
 vmid: "{{ vmid }}"  
 state: started

 Erstellt und startet die VM.

----------

## **6.4 Inventory `inventory.ini`**

[desktop_vms:vars]  
ansible_user=admin  
ansible_ssh_private_key_file=/root/.ssh/id_ed25519  
  
[desktop_vms]  
vm-06 ansible_host=192.168.30.172

Definiert die Zielsysteme.

----------

## **6.5 Playbook `site.yml`**

- name: Desktop-VM konfigurieren  
 hosts: desktop_vms  
 become: true  
  
 pre_tasks:  
 - wait_for_connection:  
  
 roles:  
 - xfce_xrdp

Startet die Konfiguration.

----------

## **6.6 Rolle `xfce_xrdp`**

- name: Pakete installieren  
 apt:  
 name: "{{ base_packages }}"  
  
- name: Benutzer erstellen  
 user:  
 name: "{{ item.name }}"  
  
- name: XRDP starten  
 service:  
 name: xrdp

Richtet Desktop und Remote-Zugriff ein.

----------

# **6.7 Erweiterte Systemkonfiguration**

----------

## **Entfernen unerwünschter Apps**

-   libreoffice-*
-   atril*
-   exfalso*
-   parole
-   quodlibet
-   xfburn
-   firefox-esr*
-   xsane
-   kdeconnect
-   hv3

----------

## **Installation neuer Apps**

-   net-tools
-   htop
-   google-chrome
-   onlyoffice
-   xrdp

----------

## **Benutzer einrichten**

-   Benutzer erstellen
-   Gruppen zuweisen
-   Desktop vorbereiten
```mermaid
flowchart LR
    A([Start]) --> B[Apps entfernen]
    B --> C[Apps installieren]
    C --> D[Benutzer erstellen]
    D --> E([Fertig])
```
**Abbildung 4: Erweiterte Konfiguration**

----------

# **7. Ergebnis**

./auto-deploy.sh

👉 erstellt automatisch eine fertige VM.

----------


# **9. Fazit**

Das Projekt zeigt, dass durch Automatisierung eine effiziente Infrastruktur aufgebaut werden kann.

Der gesamte Prozess ist:

-   automatisiert
-   reproduzierbar
-   skalierbar


# **7. Durchführung und Ergebnisse**

## **7.1 Start des Deployments**

![https://images.openai.com/static-rsc-4/jVtIn8vGQ84OCRSKkRmy5SKXHCPIlShWGMpwnTu-wF_DS_7m9xi_87aKCVHkrF8roaC3e5L7Q3wyaFsm8GCJwYLHf1BTyKybhVoVNL3NuxgfAUDqW6lSL2N6hq_KP0YdQOvNTPhIqyFkICa8ZhuTY90lf79Ga07XMdt1I_dxur6ZHd_YBXuDCwQy-5TsI14v?purpose=fullsize](https://images.openai.com/static-rsc-4/E_nSMpp4SjbnkQbkaKoZiwTFwkH-ERnYmElyOYRk5NRkiXrMT8yhMJk76zqS4SQhWuIMJfKs_CpVk1ewv1u-s7oe1zUPbzrFoBKokgOfbMLD9viQyiYXv_hHsgoVx6Jtoq1UssVrBg5heZphZVEFdDz0hz7WmIDDy0wRwgAtYiY?purpose=inline)

![https://images.openai.com/static-rsc-4/JGq1AwlBzjbnZH0ZqxCZrrp2XuaQO2Kc6uxrQMm-0GSobPoA0LeBCnwOsB03UjqjEKIwRwj49abDI-NTM1NAncaWKJ2ftJAUszz9TYgeDv0JinlCETXBtgKYpW6RXnbH-SgyIxBB2QgYpffCv8voC7fWwZE969Q38h9m3j7LK3TCQLQrRsAJJI7xSqd7n5EB?purpose=fullsize](https://images.openai.com/static-rsc-4/J0RdMFpflInw74TpPhFagcK0ol1V74iqe7dQWWUV0V3vkZGaTtUJJtvyGi5EZNe-csgrKtTvmPphP7KuJbxuSlJIhF0_te9JM7jsJoPorkisHDR_rzcKgBgxlV1Wur_LdnOzW294ocMnewHluQNgBVIkILhz8pbZt-RoyuIcuUw?purpose=inline)

![https://images.openai.com/static-rsc-4/v7ebNB4LEAdzPf757dy0nqzhCTkdsXy-jULzDyPEGn-uk2EFm5HFGI1bHDGeJHfyC-DnccV61nSnF2XZFN55SFonHDCUHB5-0B_0XC8-wmZYVbU6JWqDsVFwrWw06t-msjzWX3LFUTMYfCflFr8YqeoNV_xtL4Y__BuEHyawNjfdzufdK_9iM-eYHMy2ZGs_?purpose=fullsize](https://images.openai.com/static-rsc-4/pLrV_VUXWY_LqgOjhAU7vHfmSdoxYwsS7KuOHTZ9kvy2R1IKGFMoHmXIrvNORPI1pomfZ5F67z1vewk83x5shdKnyxBqNjAAfChfWB6OtEhhf_0isjBgwV6r6XaU0Qu8WDz7EC_NWYbSdfuhxYs4WkDoT1WkhSgawtYZZlQ8o88?purpose=inline)

4

**Abbildung 5: Ausführung des Deployments**

Die Ausgabe zeigt, dass alle Aufgaben erfolgreich ausgeführt wurden (failed=0).

----------

## **7.2 Erstellung der VM in Proxmox**

![https://images.openai.com/static-rsc-4/OEftRRx82NV_hU-8jos4tnu8rpcCOkhmDRkf1_n7Db1R6ZbEVFakiWriKdXse7cgMeDP95-eFhuIbis5L9HklrnwkuzMRIqlzBUlMZeEmUuZcVHBUyQzug21Y2pBhLJ_yOhdjTf2mvGdFPw9sFoUC2df3sI80GebwZyKXaa56SG8QQGtWgPy8H0kOadLkdQR?purpose=fullsize](https://images.openai.com/static-rsc-4/2mSyRFh92fbqLAIL1BVi_yEQfkXdLsGJrGd7pPIeW_fEmfCF_2ld0Yi-sTI94mDloD33j8DwCOk49VGaXRG0T1Q3cZq2lXhEg_RjBJJoXHreuF-6533VNqtnZY9k1CMCeeFCQuAWmsKbtrdIQ0NIEdCVLXQeluPe_qBt1Bdg1r8?purpose=inline)

![https://images.openai.com/static-rsc-4/OEftRRx82NV_hU-8jos4tnu8rpcCOkhmDRkf1_n7Db1R6ZbEVFakiWriKdXse7cgMeDP95-eFhuIbis5L9HklrnwkuzMRIqlzBUlMZeEmUuZcVHBUyQzug21Y2pBhLJ_yOhdjTf2mvGdFPw9sFoUC2df3sI80GebwZyKXaa56SG8QQGtWgPy8H0kOadLkdQR?purpose=fullsize](https://images.openai.com/static-rsc-4/2mSyRFh92fbqLAIL1BVi_yEQfkXdLsGJrGd7pPIeW_fEmfCF_2ld0Yi-sTI94mDloD33j8DwCOk49VGaXRG0T1Q3cZq2lXhEg_RjBJJoXHreuF-6533VNqtnZY9k1CMCeeFCQuAWmsKbtrdIQ0NIEdCVLXQeluPe_qBt1Bdg1r8?purpose=inline)

![https://images.openai.com/static-rsc-4/OEftRRx82NV_hU-8jos4tnu8rpcCOkhmDRkf1_n7Db1R6ZbEVFakiWriKdXse7cgMeDP95-eFhuIbis5L9HklrnwkuzMRIqlzBUlMZeEmUuZcVHBUyQzug21Y2pBhLJ_yOhdjTf2mvGdFPw9sFoUC2df3sI80GebwZyKXaa56SG8QQGtWgPy8H0kOadLkdQR?purpose=fullsize](https://images.openai.com/static-rsc-4/2mSyRFh92fbqLAIL1BVi_yEQfkXdLsGJrGd7pPIeW_fEmfCF_2ld0Yi-sTI94mDloD33j8DwCOk49VGaXRG0T1Q3cZq2lXhEg_RjBJJoXHreuF-6533VNqtnZY9k1CMCeeFCQuAWmsKbtrdIQ0NIEdCVLXQeluPe_qBt1Bdg1r8?purpose=inline)

4

**Abbildung 6: VM in Proxmox**

Die VM wurde erfolgreich erstellt und gestartet.

----------

## **7.3 SSH-Verbindung**

![https://images.openai.com/static-rsc-4/bhrIJLllryeoNqFA6DOZnMxFeNveK3W3xZwEFeU4RlXyDNjJLoKI6wWsu32x2CgT4Pg4tiCrv26mHNwQ0Tora4o6cJ3Y8-AICIMxKryAO8rs0kBGxlyI0vRsi_WlrGBRt8xUHxgJ-beAzcQ61oqpujWiQTdouyAfP5W04ZCDmk_vmR-R4xp-UNz2KmFZs6px?purpose=fullsize](https://images.openai.com/static-rsc-4/hqie_ECkurqqqfYgLkRRfXkGUO-GutvBPyFpiSBw-Htkr6Is0hMVoMGpSRIgl1R1It3Lzf0XA-_p83noxrWID-7hUepRazALuJMjV_QD2aOyVRcv_wKBpQUAZJOATKy2tvN1Iwwv1BbXCWDe1-LQehHx-Uu5Ey763XK7psRz-Fc?purpose=inline)

![https://images.openai.com/static-rsc-4/8dPFhkyLeaU7Lxv402cjbAJTxpAajjERPlAnyoWhqh6K5AqAeASU8QNu_EHB5k-7S3fM7xng0573SiPyWlYobdnmZUBGV_S0Bn8DgFa5yAE2uzmO1VC84iQbs68A2EmDBxsfCq74RUXFecmDnQLBzBAJVETeHrA-vfY27bESqHRNizwPwuea_VIKS3AXdEGW?purpose=fullsize](https://images.openai.com/static-rsc-4/14khSLhclSBheC76yt8fHX1J97Ik8Af4qy_9m49YmKdj08o-KpGs1PHkKB8po8yXJUheC-L7uQzq4wb1HvqoEkUPgyWTPoMkg2mrMZ3LAyHSF9qSjKKoPOOgoxKzOjeLjS9selk0SbyxcrpMeStFM9K_j9ou1FmGklKgDub7lYo?purpose=inline)

![https://images.openai.com/static-rsc-4/GW2tZutGGTHPRCTBj7OL8yYhIVqwR3uU9wJNcgW_BBjXPIWX3FB0deDFUSPev0yWZCS0SpIpQsOFO6Npm6WJCbws4fxffESrUYfgsW9nGTSkrI6dMioYUkV7VW_IZnRrYQBPLj0wv1sAmjiRPTY8Qu-kYUSxeApsUa2BNxAwX452LDDINCM4Q1l3aRKn4qIS?purpose=fullsize](https://images.openai.com/static-rsc-4/yDg0FSS-qXwRV8LWlcQAtMUBJViZpWHTjTFLDmAQthO2Cbbz9V-_jXllQU_f8eXGgatOJwvjeNqUq11eSU4L1pGFOZdXVcGGu3Mh0kFNXdhMQS4O6Wg-fHcpVMNj4acBzavsjVNYAtlSTxEZvLCSLdixw9N7oCRoMzBbH2qOSzA?purpose=inline)

4

**Abbildung 7: SSH-Verbindung**

Die Verbindung bestätigt die korrekte Netzwerkkonfiguration.

----------

## **7.4 Desktop-Umgebung**

![https://images.openai.com/static-rsc-4/JB46O0bhOGjJSUC7pkPoNTHvSHiYB4WAxbEx0Uc6E3W57CBRjpIKnjsFL8a8JmNLsTgz8FMeEbce7zMOjJSh9olPPo-5agKky1i80BJqcg6j3gvvE-16Mg3asyuejeUXvPHSWNjThyaPkP_paEBS_tntsvLELAZE11cqw-hHgkeIHciVqnLktVvo_D8AyH9m?purpose=fullsize](https://images.openai.com/static-rsc-4/VUiRnaMQ3eWI8Hw4kPbQkeNd-DvrfjI3a63BpnEZv1jMEdbv6zA9eUfwjyhwsJT6W25q2_Ub_qQh_MVNJEYUb_kYIhqEnKyR0uLLwaClUyaQuB2hA33WuBHDaO_41iEt3_mpriPVzKiIt6zM57JSj_avI-mzErIg3zZlV3Jo-bs?purpose=inline)

![https://images.openai.com/static-rsc-4/MjqPdOJDS34yiVkDrKLwBXZXb_QBXucz33fKuQscsxj2Ql7zXQwRZnOK2tWRB1ROu8RagqEqbEcE7l54wYCbbztnnXVv1Qlv--6ubupFs6R00CShZA3_adHwQ9MBEnPkW4ywUWQCkif7niYtTaQKXtZol6EspFFwBxja0dh20ArL60qXOuYQkgAxpSUZM-SO?purpose=fullsize](https://images.openai.com/static-rsc-4/vhBpRHX-LS62iXaDd1dtf0kT2uWCAkGTXa4VPBlaOWZpugP0ljEha8TMFgVaTa0N87KahUte2R6kNT16cZ4Mc-ZuKvkMUl8ZB5_BxWFbM-s4RvtVPHp3AD7rh6IbVgfHrIb4GzWsWRE7KOGA9Pf5xN3DHXryQ0aHLSJm-6VzNls?purpose=inline)

![https://images.openai.com/static-rsc-4/Wd3thQeRXbOQbzNvcGCUiQe82i_KZL2QEj3j6fdrkk_EUPzL_HnzHzecmC3oxJPrNEzBnQO9jBys18OF72qoyaV5BNLIQx8hCx_tVU6c3sQqsjjacQJiyUWMRwb2rkrgVmHqgAdqMYKYDrKxmnkfwj3Tz9OLeh9rICWt2ZfG_Onu8VWREpfUYn77qXvfB7gE?purpose=fullsize](https://images.openai.com/static-rsc-4/If82UWoXYiRFg8LgoLehlGaIO11xvXtyVhUHbPeOX3KrCpxA2Je0-ev3IYDAxA97Gv8-5Y7Rq68ovSAUKwFYV7oCXcXF-dsZHPhMvS26-u4bX5epno0elZwXqTS0NNNrqnr6xQVF-YQYGY7K0OS2NRoHT1RsL9RPgbKI5pdsvdg?purpose=inline)

4

**Abbildung 8: XFCE Desktop**

Die VM ist vollständig nutzbar.

----------

## **7.5 Remote Zugriff (XRDP)**

![https://images.openai.com/static-rsc-4/F-nvFcXudnGTdUkIzd7wCDhG23cYrrlUC5dUjFd3cXIaChMQti3A0amfQwS3Q0Q5H7HuFn23KhZ1JRj04QoNgDLLWFWTRYTDd9Dn_RXhp9F3sG0ZeuTAMBPrRmbeUKKe17qS9YtRafpIvMKRKamPSGOO5sCJKKT-5Lt15N7v5DVGMVOyVUag27essr7et11B?purpose=fullsize](https://images.openai.com/static-rsc-4/RJWc2IIzV8OvSrtJUjoGD1W_omQAjOSClcfifhpnMsVxaFhj_LymBRVvvzsXWQqkiumChiEcvbB-SNKMF8gJ7WiIrOyclhxdfTVHDAFQD9nIpaQpQSTEsi-Bpyqp8pAltJvIDIPBIIo-Wt9j2Lkd0uaHMapwubBlsc0_QDtEOxE?purpose=inline)

![https://images.openai.com/static-rsc-4/8BHSeBpo0TGQlVxeTkJM7UazQQHxpZVcvPyr3FPKFHh0N8jR7SFMQmXCr_utTq6CyXjqsybyzAIHEZiCyBX_sAU-U5FEBzAraDYIcSHhFVWOuG4yK8-LOuLQ6hSXUIo11lJZUHYRUD6w81W4oHYIDPKgr-jWPlmVJOAb1AAXiyphZSxkKkHZN7Ftj_lQjGX_?purpose=fullsize](https://images.openai.com/static-rsc-4/Lh1jFTmP-Kn-IAGe7do3Tl3txknTFSt60XLjHzXCH8aQC5qrjnVt3l3VJi4sf-2V0KzBsSvfha787LXzMVkzVHp3RwgWDFdhvumcZuGGTlp8iYb611bRvs6mQ6h3L7QcEXUcRq5N431xQCNvXF77TJNKwKq1GEgkqxQCnXXe4no?purpose=inline)

![https://images.openai.com/static-rsc-4/qMoHD2eoEeO4HnL525l_8M6tfVrwzxwCCPudnhbPEnJjvscBKZsLMeRx3PJ_ofJkZdOE1DDtvnmTQoV9jrnIWeJSlpH98e_p3F0UZ2Zbn_N_A8L0fXyVk7DEG8PeRSbG5AHowU8wNGo2pGDs-8Zp1d_ZATsLRoPK6pxMLHQNsqXu2oWWHNCfOOCNA28igH2J?purpose=fullsize](https://images.openai.com/static-rsc-4/nHZbc6VmbxmysqVWLcaoDON9Uscx-FX1CRD5QE0hMQ8H3Da-3BomBmvq3yYN-DI_Y1-LQCsMim556W4-sq3OuW0dD69cMLvf2QY19Uwj2RAzrJwT_A4uGnOSZvomjw5boW1F-DuMqjap43ZbJbIst0sVO2rgbmxoO07qjHd2-Ls?purpose=inline)

4

**Abbildung 9: Remote Desktop Verbindung**

Der Zugriff funktioniert über XRDP.

----------

## **7.6 Skalierbarkeit**

![https://images.openai.com/static-rsc-4/6wnqdpVc2S5QkhDclgFDi24IkzIhHtgq_sRLyuxAo6TDMfEU4dCntj-KO5roBnSy8FO-GHY1Bo30Ot9d8nBpVHzNE09tM-ZdGOAIYVD-XYzIJvHfY0abpM0ETmB6Zax6mS4aE8yjmzR_7uNMT9j4Z8lwZrleLzn8qNwvcZrYx6QCT0SekOtgaTr3RkguovYd?purpose=fullsize](https://images.openai.com/static-rsc-4/EB8Bm5EpZ0Vw1jb-Bk32ueK5geYb6CohelQMyzon2YD_e1REmlF7OnZBIquHlKEuSE_bPnvgc-_2jFnPLSZJ6ieq3BhEwCTLhGRgXyJzwDKyxdt5gzI3zZrWFhgEMCBlJCjBuH-ryFgPpjfLnkdC8t-nq2oKstfaIfun8DZfjEk?purpose=inline)

![https://images.openai.com/static-rsc-4/CNzw_0SZxrMIxdvRNLxAvIKsp2S_qMaWefaVgZdLLbAYdq1afd7g3JD2Y3-FYNoGuXO_1Ajkm0sulcwucKScU96rgIRyOBN_LObzL_OuG1LyufICw8UDtZ3uMekChXEhBfQviziFyskuzvNW494VvHFVkQR1PDJY2w-ogoHnPX6MCsRVgKCBDabjqStq9CFD?purpose=fullsize](https://images.openai.com/static-rsc-4/QHg1JKu_P2FosLnhpZHPxYcdZUQjJ6HTARFHm7uEaO0S_zYNokO5LwtoZ7Ue6avOdAyL7vzSvvOafmSXpQ7hpFFby9VvgAskwWYUvpvQ8eHNPNGGVQzB08j3FQPY9IRzAMKJfRakUF_DlcDqQGwuqRgS3LfkdLfvx41B87GFiN8?purpose=inline)

![https://images.openai.com/static-rsc-4/8BHSeBpo0TGQlVxeTkJM7UazQQHxpZVcvPyr3FPKFHh0N8jR7SFMQmXCr_utTq6CyXjqsybyzAIHEZiCyBX_sAU-U5FEBzAraDYIcSHhFVWOuG4yK8-LOuLQ6hSXUIo11lJZUHYRUD6w81W4oHYIDPKgr-jWPlmVJOAb1AAXiyphZSxkKkHZN7Ftj_lQjGX_?purpose=fullsize](https://images.openai.com/static-rsc-4/Lh1jFTmP-Kn-IAGe7do3Tl3txknTFSt60XLjHzXCH8aQC5qrjnVt3l3VJi4sf-2V0KzBsSvfha787LXzMVkzVHp3RwgWDFdhvumcZuGGTlp8iYb611bRvs6mQ6h3L7QcEXUcRq5N431xQCNvXF77TJNKwKq1GEgkqxQCnXXe4no?purpose=inline)

4

**Abbildung 10: Mehrere VMs**

(ansible-venv) root@ansible-control:~/proxmox-ansible# cat ~/proxmox-ansible/auto-deploy.sh

#!/usr/bin/env bash

set -e

  

FULL_DEPLOY="/root/proxmox-ansible/full-deploy.sh"

  

# ----- Proxmox API -----

PROXMOX_HOST="192.168.30.99"

PROXMOX_USER="root@pam"

PROXMOX_PASSWORD="12345678"

  

# ----- IP-Bereich -----

START_IP=168

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

echo "IP: $VM_IP"

  

# ancienne host key éventuelle

ssh-keygen -f '/root/.ssh/known_hosts' -R "$VM_IP" >/dev/null 2>&1 || true

  

"$FULL_DEPLOY" "$VMID" "$VM_NAME" "$VM_IP"
