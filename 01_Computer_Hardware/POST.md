---
tags:
  - concept
  - hardware
  - boot-process
category: computer-hardware
status:
  - learning
related: "[[Switch Boot Sequence]]"
date: 2025-09-16
---

# POST (Power-On Self-Test)

## 📝 One-Sentence Summary 
POST is a diagnostic program stored in [[ROM]] that runs automatically when a device is powered on to check the integrity and functionality of critical hardware components. 

## 💡 Analogy 
It's like a person waking up and taking a quick stretch—they check that their arms and legs are working before they try to get out of bed and start their day. 

## 🔑 Key Details 
- **What it is:** 
	- The very first step in the [[Switch Boot Sequence]]. It's a low-level check of core components. 
- **What it checks:** 
	- It verifies the basic operation of the [[CPU]], [[DRAM]], and the part of the [[Flash Memory]] that holds the file system. 
- **Why it exists:** 
	- To ensure the hardware is stable enough to proceed with loading the boot loader and, eventually, the full operating system. A failure at this stage indicates a serious hardware problem. 

## 🔗 Connections & Implementations 
- The results of the POST are often indicated by the **System LED** on a switch, as seen in the [[Switch LED Indicators]] note. 
- This process is fundamental to almost all computers, not just network devices.