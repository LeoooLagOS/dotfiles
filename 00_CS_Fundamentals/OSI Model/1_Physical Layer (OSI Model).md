---
tags:
  - concept
  - cs-fundamental
  - networking
  - osi-model
category: networking
status:
  - reviewing
related: "[[OSI Model]]"
date: 2025-09-26
---

# Physical Layer (OSI Model)

## 📝 One-Sentence Summary 
The Physical Layer (Layer 1) is the lowest layer of the OSI model, responsible for the actual transmission and reception of unstructured raw data (bits) between a device and a physical transmission medium. 
## 💡 Analogy 
The Physical Layer is the **language of electricity and light**. It's the physical engineering that turns a `1` into a specific voltage on a copper cable or a pulse of light in a fiber optic cable, and a `0` into another. It doesn't know what the bits mean; it just knows how to send and receive them. 
## 🔑 Key Details 
- **PDU (Protocol Data Unit):** **Bits** 
- **Function:** It defines the electrical, mechanical, and procedural specifications for activating, maintaining, and deactivating a physical link. This includes voltages, pin layouts, cabling, and signaling rates. 
- **Hardware Examples:** Hubs, repeaters, network adapters (NICs), and media converters. `[[Ethernet Straight-through Cable|Ethernet cables]]` are also a Layer 1 component. 

## 🔗 Connections & Implementations 
- The status of this layer is the first part of the [[Interpreting Interface Status]] command output (`Interface is up/down`). 
- Issues at this layer, like a bad cable or interference, often manifest as [[Common Interface Errors|CRC errors]]. 
- It is the foundation upon which the [[2_Data Link Layer (OSI Model)]] operates.