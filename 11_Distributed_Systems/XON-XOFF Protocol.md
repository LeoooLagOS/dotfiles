---
tags:
  - concept
  - networking
  - protocol
category: Distributed Systems
status: learning
related: "[[RS232]]"
date: 2026-01-09
---
# XON-XOFF Protocol

## 📝 One-Sentence Summary
A software-based flow control protocol used in serial communication to prevent data loss by signaling the sender to pause or resume transmission based on buffer capacity.

## 💡 Analogy
**The Kitchen Pass:** A chef (Sender) sends plates to the waiter (Receiver). If the waiter's tray is full, they shout "STOP!" (**XOFF**). Once they deliver the plates and have space, they shout "NEXT!" (**XON**).

## 🔑 Key Details
- **What it is:** In-band flow control using specific ASCII characters (DC1 and DC3).
- **Mechanism:**
    - **XOFF (Hex 13 / DC3):** Signal to stop transmitting.
    - **XON (Hex 11 / DC1):** Signal to resume transmitting.
- **Petri Net Modeling:** Transitions represent the sending of data, while places represent the available slots in the receiver's FIFO buffer.
	- **High-water Mark (The XOFF trigger):** 
		- Usually set at **80%** of buffer capacity. When reached, the receiver sends **Hex 13 (DC3)** to the sender. 
	- **Low-water Mark (The XON trigger):** 
		- Usually set at **20%** or when the buffer is empty. The receiver sends **Hex 11 (DC1)** to resume data flow. 
	- **Full Buffer Scenario:** 
		- If the sender ignores the XOFF or the receiver’s CPU is too slow to process the signal, a **Buffer Overflow** occurs, and data is permanently lost (Dropped packets).

## 👍 Pros & 👎 Cons
- **Pros:** Does not require extra physical wires (unlike Hardware Flow Control/RTS-CTS).
- **Cons:** If the XON/XOFF character is accidentally sent within the data payload, it can cause the link to hang (Escape characters required).
## ⚙️ Key Details 
- **XON (DC1):** Transmit On ($17_{10} / 11_{16}$). 
- **XOFF (DC3):** Transmit Off ($19_{10} / 13_{16}$).
## See Also
- [[Petri Nets]]
- [[RS232]]
- [[ASCII Table]]
