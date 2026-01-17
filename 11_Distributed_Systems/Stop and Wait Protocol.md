---
tags:
  - concept
  - protocol
  - networking
category: Distributed Systems
status: learning
related: "[[Flow Control]]"
date: 2026-01-16
---
# Stop and Wait Protocol

## 📝 One-Sentence Summary
The simplest form of error and flow control where the sender transmits one frame and stops to wait for an acknowledgment (ACK) before sending the next.

## 💡 Analogy
**The Cautious Text:** You send one WhatsApp message and refuse to send a second one until you see the "Blue Checks" (ACK) for the first.

## 🔑 Key Details
- **What it is:** A connection-oriented protocol for reliable data transfer.
- **Why it exists:** To prevent the sender from overwhelming the receiver with data.
- **Core Mechanism:**
    - **Sender:** Sends $Data_n$, starts timer.
    - **Receiver:** Receives $Data_n$, sends $ACK_n$.
    - **Sender:** Receives $ACK_n$, sends $Data_{n+1}$.

## 👍 Pros & 👎 Cons
- **Pros:** Very simple to implement; requires minimal buffer space.
- **Cons:** Inefficient; the "Link Utilization" is low because the sender spends most of its time idling.

## See Also
- [[Petri Net Flow Control]]
- [[XON-XOFF Protocol]]