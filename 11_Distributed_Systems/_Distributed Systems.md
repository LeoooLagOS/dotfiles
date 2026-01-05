---
tags:
  - overview
  - concept
  - distributed-systems
category: Distributed Systems
status: learning
related: "[[Concurrency vs Parallelism]]"
date: 2026-01-04
---
# _Distributed Systems

## 📝 One-Sentence Summary
A collection of independent computers that appears to its users as a single coherent system, collaborating to achieve a common goal through message passing.

## 💡 Analogy
**The Orchestra without a Conductor:** Imagine fifty musicians in different rooms, unable to see each other, but playing the same symphony. They must use headsets (Network) to hear cues (Messages) and synchronize their timing (Clocks/Consensus) to ensure the audience (User) hears a single, unified performance.

## 📜 History & Creator
* **Early Roots:** 
	* [[ARPANET]] and the development of [[TCP/IP]].
* **Key Figures:** 
	* **Leslie Lamport** (introduced logical clocks and the [[Paxos Algorithm]]), **Eric Brewer** (the [[CAP Theorem]]), and **Andrew Tanenbaum** (pioneer in [[Distributed OS]]).

## 🔑 Core Philosophy & Design
The fundamental philosophy is **Transparency and Reliability**. A distributed system should hide the fact that resources are physically separated and should remain operational even when individual nodes (hardware) fail.

## ⚙️ Key Details
- **What it is:** A software layer ([[Middleware]]) sitting atop multiple networked nodes to coordinate tasks.
- **Why it exists:** 
	- **Scalability:** Horizontal growth by adding more nodes.
    - **Availability:** Redundancy ensures the system stays up if a node crashes.
    - **Performance:** Parallel execution of complex tasks.
- **Core Functions/Components:**
    - **Resource Sharing:** Files, databases, and compute power.
    - **Concurrency Control:** Managing simultaneous access to data.
    - **Fault Tolerance:** Detecting and recovering from partial system failures.

## 🔗 Connections & Implementations
- **Networking:** Relies heavily on the [[4_Transport Layer|Transport Layer]]  ([[TCP/UDP]]) for inter-process communication ([[IPC]]).
- **Cloud Computing:** The backbone of AWS/Azure infrastructures.
- **Cybersecurity:** Distributed systems introduce more "surface area" for attacks ([[DDoS]], [[Man-in-the-Middle]]).
- **Implementation Tools:** [[Docker]] (Containerization), [[gRPC]], [[Apache Kafka]], and [[Kubernetes]].

## See Also
- [[CAP_Theorem]]
- [[RPC_Remote_Procedure_Call]]
- [[Distributed_Consensus]]
- [[Fallacies_of_Distributed_Computing]]