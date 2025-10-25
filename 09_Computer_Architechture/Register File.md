---
tags:
  - concept
  - register
  - register-file
  - cpu
category: computer-architecture
status:
  - learning
related: "[[Datapath]]"
date: 2025-10-24
---

# Register File

## 📝 One-Sentence Summary
*The Register File is a small, extremely fast array of registers located inside the CPU, used to temporarily store data (like variables or intermediate results) that is being actively processed.*

## 💡 Analogy
*If the CPU is a **woodshop**, the [[RAM]] is the **lumber rack** across the room, and the [[ALU]] is the **table saw**. The Register File is the **carpenter's workbench** right next to the saw, holding only the specific planks of wood and tools being measured, cut, and assembled *right now*.*
## 🔑 Key Details
- **What it is:** 
	- A collection of 32-bit registers (e.g., 32 of them in MIPS) implemented as a small, high-speed memory. It is a piece of **sequential logic**, meaning its contents are updated on a clock edge. 
- **Why it exists:** 
	- To provide the [[ALU]] with data much faster than main memory ([[RAM]]) or even cache. Accessing RAM is like a (relatively) long trip to the lumber rack; accessing the register file is instantaneous. 
- **Core Inputs/Outputs:** 
	- **Read Addresses:** 
		- Specifies *which* registers to read (e.g., `rs` and `rt` in MIPS). 
	- **Write Address:** 
		- Specifies *which* register to write to (e.g., `rd` or `rt`). 
	- **Write Data:** 
		- The actual data to be written into that register. 
	- **Write Enable:** 
		- A 1-bit signal (`RegWrite`) that, when active, allows data to be written.
## 🔗 Connections & Implementations
- The Register File is a central component of the [[Datapath]]. 
- It **outputs** data to the [[ALU]] and the [[Datapath]] (for memory stores). 
- It **receives** its "Write Data" input from a [[MUX]] that chooses between the `ALU` result or data from memory. 
- Its operation is governed by the [[Control Unit]].
## 👍 Pros & 👎 Cons
- **Pros:** 
	- Extremely fast read and write access (often completes in a single, short clock cycle). 
- **Cons:** 
	- Very small capacity (e.g., 32 registers) due to its high cost and physical space requirements on the CPU die.
## See Also
- [[Datapath]] 
- [[ALU]] 
- [[Control Unit]] 
- [[RAM]]