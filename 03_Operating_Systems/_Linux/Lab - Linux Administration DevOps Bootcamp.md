---
tags:
  - lab
  - linux
  - devops
  - configuration
  - systemd
  - sysadmin
  - vm
category: os
status: mastered
related: "[[_Linux]]"
date: 2025-11-27
---
# Lab - DevOps Bootcamp: Linux Administration

## 📝 One-Sentence Summary
*A comprehensive hands-on configuration of an Ubuntu 20.04 server, covering User Management, LVM Storage, Service Automation (Docker/Nginx), and Persistent Networking.*

## 💡 Analogy
*Building this server was like **constructing a high-tech office building**:*
* **Storage (LVM):** We built flexible walls that can be moved later.
* **Users & Sudo:** We issued ID cards and set strict access levels for the staff.
* **Services (Nginx/Docker):** We installed the machinery and appliances.
* **Networking:** We mapped the dedicated phone lines and emergency exits.

## 🎯 Lab Objectives
1.  **System Identity:** Configure Hostnames and DNS resolution.
2.  **User Management:** Create specific users/groups and configure passwordless `sudo` for specific commands.
3.  **Storage:** Implement [[LVM]] on a secondary disk and manage [[Linux Swap]].
4.  **Services:** Install specific versions of [[Docker]], configure [[Nginx]], and automate backups via [[Cron]].
5.  **Networking:** Configure persistent static routes using **[[Netplan]]**.

---

## 🖥️ System: Ubuntu Server 20.04 (VM)

*Context: A virtual machine with two disks (`/dev/sda` for OS, `/dev/sdb` for Data).*

### 1. Identity & User Management
*Theory Reference: 
* [[User and Group Management]] 
* [[Privilege Escalation (su vs sudo)]]
* [[DNS Configuration]]*

```bash
# --- 1. Hostname Resolution ---
# Requirement: Hostname must match FQDN and resolve to 127.0.0.1
sudo hostnamectl set-hostname student
# Edit /etc/hosts to add: "127.0.0.1 student localhost"
sudo nano /etc/hosts 

# --- 2. User & Group Creation ---
# Specific IDs required: User(1040), Group(1050)
sudo groupadd -g 1050 student_group
sudo useradd -u 1040 -g 1050 -G cdrom -d /home/student_home -m -s /bin/bash student

# --- 3. Sudo Configuration (Sudoers.d) ---
# Requirement: Allow 'apt install' without password, but require password for others.
# Best Practice: Do NOT edit /etc/sudoers directly. Create a file in .d/
sudo nano /etc/sudoers.d/student
# Content:
# student ALL=(ALL) NOPASSWD: /usr/bin/apt install *, /usr/bin/apt-get install *
sudo chmod 440 /etc/sudoers.d/student
```
### 2. Storage & LVM Configuration

_Theory Reference: 
* [[LVM]] 
* [[Linux Swap]]
* [[Linux File System]]_
```bash
# --- 1. LVM Setup on Secondary Disk (/dev/sdb) ---
# Initialize Physical Volume, Volume Group, and Logical Volume (50% size)
sudo pvcreate /dev/sdb
sudo vgcreate student /dev/sdb
sudo lvcreate -n student -l 50%FREE student

# Format and Mount
sudo mkfs.ext4 /dev/student/student
sudo mkdir -p /lvm/student
# Permanent Mount via /etc/fstab (Must use UUID)
# Command to get UUID: sudo blkid /dev/student/student

# --- 2. Swap Management ---
# Resize swap to exactly 1GB and secure it
sudo swapoff /swapfile
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
# Ensure it is in /etc/fstab: "/swapfile none swap sw 0 0"
```

### 3. Services & Automation

_Theory Reference: 
* [[Linux Package Management]]
* [[Cron]]
* [[Systemd Architecture]]
* [[File Attributes]]_
```bash
# --- 1. Docker Installation (Specific Version) ---
# Requirement: Version 19.03.15
# Added Docker GPG keys and Repo, then installed specific string:
sudo apt-get install docker-ce=5:19.03.15~3-0~ubuntu-focal docker-ce-cli=5:19.03.15~3-0~ubuntu-focal containerd.io -y
# Allow student user to run docker
sudo usermod -aG docker student

# --- 2. Nginx Configuration ---
# Change port to 8080 in /etc/nginx/sites-available/default
# Replaced /var/www/html/index.html with custom JSON data.
sudo systemctl restart nginx

# --- 3. Automation (Cron & Logrotate) ---
# Cron: Backup nginx config every minute with timestamp
# Edit: sudo crontab -e
# Line: * * * * * cp /etc/nginx/nginx.conf /etc/nginx/conf.d/nginx-$(date +\%s).conf.bak

# Logrotate: Change frequency to weekly
# Edit: /etc/logrotate.d/nginx (Change 'daily' to 'weekly')

# --- 4. Security (Immutable Files) ---
# Create a file that cannot be deleted even by root
sudo touch /immutable.txt
sudo chmod 777 /immutable.txt
sudo chattr +i /immutable.txt
```

### 4. Networking & Routing

_Theory Reference: 
* [[Network Configuration]]
* [[Bash Startup Files]]_
```YAML
# --- 1. Persistent Static Route (Netplan) ---
# File: /etc/netplan/50-cloud-init.yaml
# Requirement: Route 8.8.8.8 via 4.4.4.4
# CAUTION: YAML indentation is critical.
network:
    version: 2
    ethernets:
        enp0s3:
            dhcp4: true
            routes:
                - to: 8.8.8.8/32
                  via: 4.4.4.4
```

```bash
# Apply Netplan changes
sudo netplan apply

# --- 2. Bash Alias ---
# Permanent alias for 'student' user
echo "alias eip='curl ifconfig.me'" | sudo tee -a /home/student_home/.bashrc
```

## ⚠️ Key Challenges & Solutions

- **Hostname Resolution:** `hostname -f` failed until `/etc/hosts` was edited to prioritize the hostname before localhost. See [[Hostname Management]]
    
- **YAML Indentation:** [[Netplan]] failed with "mapping values not allowed" until `via:` was perfectly aligned with `to:`.
    
- **Swap Permission**s:** `swapon` warned of insecure permissions (0644); fixed by running `chmod 600`.