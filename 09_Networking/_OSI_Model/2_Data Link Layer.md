---
tags:
  - concept
  - cs-fundamental
  - networking
  - osi-model
category: networking
status:
  - reviewing
related: "[[_OSI Model]]"
date: 2025-09-26
---

# Data Link Layer (OSI Model)

## 📝 One-Sentence Summary
*The Data Link Layer (Layer 2) is the second layer of the OSI model, responsible for reliable, node-to-node data transfer by packaging bits into frames and handling physical addressing (MAC addresses).*

## 💡 Analogy
*The Data Link Layer is like the **local postal service for a single city**. It takes letters (data packets), puts them into standard envelopes (`Frames`), and writes the specific street address of the next person to handle it (`MAC Address`). It only knows how to get the envelope to the next stop within the city; it doesn't know the final destination in another country.*

## 🔑 Key Details
- **PDU (Protocol Data Unit):** **Frames** 
- **Function:** This layer provides the functional and procedural means to transfer data between network entities. Its primary jobs are: 
	- **Framing:** Encapsulating network layer packets into frames. 
	- **Physical Addressing:** Using MAC addresses to identify devices on the local network segment. 
	- **Flow and Error Control:** Ensuring data is transmitted reliably across the physical link. 
- **Hardware Examples:** Switches, bridges, and network interface cards (NICs).
## 🔗 Connections & Implementations
-   The health of this layer is the second part of the [[Interpreting Interface Status]] command output (`line protocol is up/down`).
-   A **[[Layer 2 Loops]]** is a catastrophic failure at this layer, which [[STP]] is designed to prevent.
-   Switches operate primarily at this layer to make forwarding decisions based on the [[MAC Address Table]].
