---
tags:
  - concept
  - hardware
  - logic-gate
category: computer-hardware
status: learning
related: "[[Transistor]]"
date: 2025-12-04
---

# Logic Gate

## 📝 One-Sentence Summary
A logic gate is the fundamental physical building block of digital circuits, implemented using transistors to perform basic boolean logic operations like AND, OR, and NOT.

## 💡 Analogy
*A logic gate is like a **digital valve**. Depending on the combination of "pressure" (signals) arriving at its inputs, it either opens to let the signal through or closes to stop it, effectively making a simple "Yes/No" decision.*

## 🔑 Key Details
-   **What it is:** 
	- A physical device that implements a Boolean function. It is constructed by connecting transistors (like [[Transistor|MOSFETs]]) in specific patterns.
-   **Why it exists:** 
	- To allow computers to process binary information. Complex circuits like [[ALU]] are built by combining thousands of these simple gates.
-   **Common Types:**
    - **AND:** Output is 1 only if *all* inputs are 1.
    - **OR:** Output is 1 if *any* input is 1.
    - **NOT (Inverter):** Output is the inverse of the input.
    - **NAND / NOR:** Inverted versions of AND/OR. These are often the "universal" gates used in manufacturing.
    - **XOR (Exclusive OR):** Output is 1 if inputs are *different* (useful for adders).

## 🔗 Connections & Implementations
- In [[_VHDL]], gates are described using operators (e.g., `y <= a AND b;`).
- Physically, they are built using [[Transistor|CMOS]] technology (combining NMOS and PMOS transistors).

## See Also
-   [[Transistor]]