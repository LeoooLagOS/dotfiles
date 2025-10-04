---
tags:
  - concept
  - hardware
  - memory
category: computer-hardware
status:
  - learning
related: "[[RAM]]"
date: 2025-09-17
---

# ROM (Read Only Memory)

## 📝 One-Sentence Summary 
ROM is a type of non-volatile memory containing [[Firmware]] that is permanently written during manufacturing and is used to boot up a device. 

## 💡 Analogy 
ROM is like the printed instruction manual that's glued inside an appliance. It contains the most essential, unchangeable startup guide that the device reads every time it's turned on. 

## 🔑 Key Details 
- **What it is:** 
	- A class of storage media used in computers and other electronic devices that, under normal operation, can only be read from.
- **Why it exists:** 
	- To store **firmware**—low-level software that is permanent and is required for the hardware to function, but which the user does not need to change. 
- **Core Characteristics:** 
	- **Non-Volatile:** 
		- It retains its data even when power is turned off. This is crucial for storing boot-up instructions. 
	- **Read-Only:** 
		- Its contents cannot be easily or quickly modified, which prevents accidental or malicious changes to the core system firmware.

## 🔗 Connections & Implementations 
- The programs in ROM are the first to execute in the [[Switch Boot Sequence]].
- On a PC's motherboard, the ROM chip stores the **[[BIOS]]** or **[[UEFI]]** firmware. 
- On a Cisco switch, the ROM stores the [[POST|POST (Power-On Self-Test)]] and the [[Boot Loader]]. 
- **Evolution:** While traditional ROM was written once at the factory, modern variations like **EEPROM** (Electrically Erasable Programmable ROM) can be modified, though slowly. This technology evolved into modern **[[Flash Memory]]**, which is why we can now update the firmware on our devices.

## See Also 
- [[Firmware]] 
- [[BIOS]] 
- [[Memory (Computer)]]