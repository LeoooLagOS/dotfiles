---
tags:
  - concept
  - theory
  - networking
category: cs-fundamental
status: learning
related: "[[_Distributed Systems]]"
date: 2026-01-07
---
# Communication Models

## 📝 One-Sentence Summary
The logical topology defining how nodes exchange data: 1 to 1 (Direct), 1 to N (Broadcast/Multicast), or N to N (Mesh).

## 💡 Analogy
**1 to 1** is a private phone call; **1 to N** is a professor lecturing to a class; **N to N** is a chaotic but structured dinner party where everyone can talk to everyone.

## 🔑 Key Details
- **What it is:** The abstract framework for data flow in distributed systems.
- **Why it exists:** To determine the routing logic and scalability of a network.
- **Implementation Logic:** - **State Machines:** Connected via threads with **FIFOs** (Input buffers) and a single output.
	- **Flow Control:** Usage of **Stop and Wait** (Sender waits for ACK before next packet).

## 🔗 Connections & Implementations
- Relates to [[RabbitMQ]] for N to N routing.
- Implemented in [[RS232]] for simple 1 to 1 serial communication.

## 👍 Pros & 👎 Cons
- **Pros:** Clear models prevent data collisions.
- **Cons:** N to N models increase complexity and latency significantly.