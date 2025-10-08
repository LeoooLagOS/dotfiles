---
tags:
  - concept
  - hardware
  - memory
category: computer-hardware
status:
  - learning
related: "[[DRAM]]"
date: 2025-09-17
---
# Flash Memory 
## 📝 One-Sentence Summary 
Flash memory is a type of non-volatile storage that acts as the permanent "hard drive" for a network device, storing the operating system and configuration files. 
## 💡 Analogy 
Flash memory is the device's storeroom or garage. It's where you keep all your important tools and project plans (the OS and config files) when you're not actively using them. Unlike your workbench ([[DRAM]]), this storage is permanent. 
## 🔑 Key Details 

- **Non-Volatile:** Its contents are saved even when the device is powered off. 
- **Function in a Switch:** It stores the [[Cisco IOS]] image file(s), the startup configuration, and VLAN databases. The integrity of the flash device is checked during the [[POST]]. 
- **Management:** A [[Flash File System]] is used to organize the files within it. 

## 🔗 Connections & Implementations 
- A corrupt IOS image in Flash Memory is a common reason for needing [[Switch System Crash Recovery]].