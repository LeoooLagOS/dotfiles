---
tags:
  - concept
  - networking
  - hardware
category: networking
status:
  - learning
related: "[[Switch Boot Sequence]]"
date: 2025-09-17
---

# Switch LED Indicators

## 📝 One-Sentence Summary
*The LEDs are a simple, visual diagnostic language on the switch's front panel that provides at-a-glance status of the system's health, port activity, and other operational modes.
## 💡 Analogy
*They are like the dashboard lights in a car. A quick look tells you if the engine is on (System LED), if a door is open (Port Status), or if there's a problem, without needing to plug in a complex diagnostic tool. 
## 🔑 Key Details
- **What it is:** A set of physical light-emitting diodes (LEDs) providing real-time hardware feedback. Key indicators include:
	- - **System (SYS) LED:** Shows the overall system status. A solid green light means the system is operational. A flashing green during boot indicates it's running the [[Switch Boot Sequence]]. Amber indicates a malfunction. 
	- **Port Status LEDs:** Each port has an LED. A solid green light typically means a link is active. Blinking indicates traffic activity. No light means there is no link. 
	- **Mode Button:** This button cycles the port LEDs through different diagnostic modes, such as showing speed (10/100/1000 Mbps), duplex status (half/full), and PoE (Power over Ethernet) status. 
	- **Why it exists:** To provide an immediate and simple way for a network technician to perform a physical-layer assessment of the switch's condition without needing to connect via a console or remote session.

## See Also
- [[POST]] 
- [[Physical Layer (OSI Model)]]
