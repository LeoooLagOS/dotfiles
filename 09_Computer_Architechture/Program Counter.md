---
tags:
  - concept
  - program-counter
  - cpu
  - register
category: computer-architecture
status:
  - learning
related: "[[Datapath]]"
date: 2025-10-24
---

# Program Counter (PC)

## 📝 One-Sentence Summary
*The Program Counter is a special-purpose register inside the CPU that holds the memory address of the next instruction to be fetched and executed.*

## 💡 Analogy
*If your program is a **cookbook** and each instruction is a **single recipe step**, the Program Counter is the **bookmark**. It always points to the exact step you need to read and perform next. After you complete a step, you (usually) just move the bookmark to the next one.*
## 🔑 Key Details
- **What it is:** 
	- A 32-bit register (in our MIPS-like design) that is updated on every clock cycle. It is the heart of the "Fetch" stage of the instruction cycle. 
- **Why it exists:** 
	- To give the CPU a way to work through a program's instructions sequentially. 
- **How it updates:** 
	1. **Normally (PC+4):** In a MIPS-like architecture, instructions are 4 bytes long. The PC is usually incremented by 4 to point to the next instruction in memory. 
	2. **Branches/Jumps:** For `branch` or `jump` instructions, the PC is *not* incremented by 4. Instead, it is loaded with a new, different address, causing the program to "jump" to a different part of the code.
## 🔗 Connections & Implementations
- The PC is a core part of the [[Datapath]]. 
- It provides the "address" to the Instruction Memory. - The decision to update by 4 or to a branch address is made by a [[MUX]] which is controlled by the [[Control Unit]]. 
- In [[_VHDL]], the PC is a classic example of **sequential logic**, as it uses a `rising_edge(clk)` and a `reset` signal to store its current value.
## 👍 Pros & 👎 Cons
- **Pros:** 
	- Provides a simple and reliable mechanism for executing code sequentially. 
- **Cons:** 
	- In simple designs, the PC is a bottleneck; the CPU can't fetch the next instruction until the current one is (at least partially) processed. This is solved by techniques like [[Pipelining]] and `branch prediction`.
## See Also
- [[Datapath]] 
- [[ISA]] 
- [[Control Unit]]