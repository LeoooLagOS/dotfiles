---
tags:
  - concept
  - networking
  - protocol
category: 11_Distributed_Systems
status: learning
related: "[[RS232]]"
date: 2026-01-09
---
# Flow Control (XON/XOFF)

## 📝 One-Sentence Summary
A software-based mechanism ("In-band" signaling) used to manage the rate of data transmission between nodes to prevent buffer overflow.

## 💡 Analogy
**The Water Tank:** A pipe (Sender) fills a tank (Buffer). If the tank is 80% full, a sensor sends a signal to close the valve (**XOFF**). When the tank is empty enough, it sends a signal to open it again (**XON**).

## 🔑 Key Details
- **What it is:** Software flow control using ASCII control characters.
- **Specific Characters:**
    - **XON:** DC1 (Device Control 1), Hex `11`.
    - **XOFF:** DC3 (Device Control 3), Hex `13`.
- **Petri Net Modeling:**
    - **Places:** Represent buffer slots (available space).
    - **Transitions:** Represent the arrival of a byte or the processing of a byte.
    - **Logic:** If "Available Slots" $\le$ threshold, trigger XOFF transition.

## 👍 Pros & 👎 Cons
- **Pros:** No extra wiring needed; works on simple 3-wire serial cables (GND, TX, RX).
- **Cons:** **Slow.** Processing the control characters in the data stream adds overhead. If the data contains Hex `13` naturally, the system will hang.

## See Also
- [[RS232]]
- [[Petri Nets]]