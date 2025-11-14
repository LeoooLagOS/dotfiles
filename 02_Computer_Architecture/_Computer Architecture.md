---
tags:
  - overview
  - concept
  - hardware
category: computer-architecture
status: learning
related: "[[_Computer Hardware]]"
date: 2025-10-23
---
# _Computer Architecture_

## 📝 One-Sentence Summary
*Computer Architecture is the set of rules, methods, and principles that describe the functionality, organization, and implementation of a computer system.*
## 💡 Analogy
*If Computer Hardware is the set of **building materials** (bricks, wires, silicon), Computer Architecture is the **master blueprint** that defines how those materials are arranged to create a functional building, including its layout (organization) and the "rules" of how it operates (instruction set).*
## 📜 History & Creator
*Early concepts emerged from figures like **Charles Babbage**. However, modern computer architecture is dominated by the **von Neumann architecture**, proposed by **John von Neumann** in the 1940s. This model introduced the revolutionary idea of a stored-program computer, where both data and program instructions are stored in the same memory.*
## 🔑 Core Philosophy & Design 
*The core philosophy is to create a functional system that balances **performance**, **cost**, and **power consumption**. It answers the "how" and "why" of a processor's design, defining the abstract model without specifying the exact physical technology.*
## ⚙️ Key Details 
- **What it is:** 
	- The formal design and functional description of a computer's components, especially the [[CPU|Central Processing Unit (CPU)]]. 
- **Why it exists:** 
	- To provide a blueprint for engineers to design and build hardware (like CPUs) that can execute software. 
- **Core Functions/Components:** 
	- [[_ISA]] (The "language" the CPU understands) 
	- [[Datapath]] (The components that process data) 
	- [[Control Unit]] (The component that directs the datapath) 
	- [[Memory Hierarchy]] (Caches, RAM, etc.) 
	- [[Pipelining]] (A technique for improving performance)
## 🔗 Connections & Implementations
* This abstract design is physically implemented using components from [[_Computer Hardware]]. It is described using a [[VHDL|Hardware Description Language (HDL)]] and its principles are fundamental to the design of [[_Operating Systems]], which must manage this hardware.
## See Also
- [[_Computer Hardware]] 
- [[_Operating Systems]] 
- [[_ISA]] 
- [[Datapath]]