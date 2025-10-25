---
tags:
  - concept
  - alu
  - cpu
category: computer-architecture
status:
  - learning
related: "[[Datapath]]"
date: 2025-10-24
---

# ALU (Arithmetic Logic Unit)

## 📝 One-Sentence Summary
*The ALU is a digital circuit within the CPU that performs all arithmetic (e.g., add, subtract) and logic (e.g., AND, OR) operations on data.*
## 💡 Analogy
*If the [[Datapath]] is the assembly line, the ALU is the **primary workstation** or **robotic tool** on that line. It's the component that actually does the work—performing calculations, comparisons, or logical operations—on the data that passes through it.*
## 🔑 Key Details
- **What it is:** 
	- A combinational logic circuit. "Combinational" means its output depends *only* on its current inputs. 
- **Why it exists:** 
	- To act as the computational core of the CPU. Instead of having separate circuits for adding, subtracting, and logic, the ALU combines them into one efficient unit. 
- **Core Inputs/Outputs:** 
	- **Inputs:** 
		- Two data operands (e.g., `a` and `b`) and a `control signal` (like our `alucontrol`). 
	- **Outputs:** 
		- A `result` (the 32-bit answer) and `flags` (like our `zero` flag).
## 🔗 Connections & Implementations
- The ALU receives its data from the [[Register File]] or from [[Sign Extension]] and is directed by the [[Control Unit]]. 
- Its `zero` flag output is often used to make decisions, such as in a `branch` instruction. 
- In [[_VHDL]], an ALU is a perfect example of a [[VHDL: Structural vs. Behavioral|Behavioral]] design, typically implemented with a `CASE` statement inside a `PROCESS`.
## 👍 Pros & 👎 Cons
- **Pros:** 
	- Centralizes all calculations into a single, optimized hardware unit. 
- **Cons:** 
	- In a simple, single-cycle datapath, the ALU's speed can be a bottleneck, as the clock cycle must be long enough for the *slowest* ALU operation (like division or complex floating-point math) to complete.
## See Also
-   [[Datapath]]
-   [[Control Unit]]
-   [[VIm: VHDL ALU Example|VHDL ALU Example]]
