---
tags:
  - concept
  - cpu
category: computer-architecture
status:
  - learning
related: "[[Datapath]]"
date: 2025-10-24
---

# Sign Extension

## 📝 One-Sentence Summary
*Sign Extension is the process of increasing the number of bits of a binary number while preserving its original sign (positive or negative) and value, which is crucial for operations involving different data sizes.*
## 💡 Analogy
*Imagine you have a small number line from -8 to +7 (4-bits). If you want to put a number, say -3 (`1101`), onto a bigger number line from -128 to +127 (8-bits), you can't just add zeros, or `0000 1101`, because that's +13. To keep the "negativeness," you must **copy the sign bit** (the `1`) into all the new spaces. The correct 8-bit version of -3 is `1111 1101`.*
## 🔑 Key Details
- **What it is:** 
	- A hardware operation that takes a number (e.g., 16-bits) and expands it to a larger size (e.g., 32-bits) by **copying its Most Significant Bit (MSB)**—the sign bit—into all the new, higher-order bits. 
- **Why it exists:** 
	- In our MIPS-like datapath, this is essential for `I-type` (immediate) instructions like `addi` or `lw`. These instructions have a 16-bit immediate value (a constant or an offset) that must be added to a 32-bit register. Before the [[ALU]] can perform this 32-bit addition, the 16-bit number must be correctly "sign-extended" to 32 bits. 
- **Examples (16-bit to 32-bit):** 
	- **Positive (`0` in MSB):** `0000 0000 0000 0101` (5) 
		- becomes `0000 0000 0000 0000 0000 0000 0000 0101` (5) 
	- **Negative (`1` in MSB):** `1111 1111 1111 1101` (-3) 
		- becomes `1111 1111 1111 1111 1111 1111 1111 1101` (-3)
## 🔗 Connections & Implementations
- This is a dedicated hardware block within the [[Datapath]]. 
- It provides one of the inputs to the [[MUX]] that feeds the [[ALU]]. 
- The necessity for sign extension is defined by the [[Instruction Set Architecture (ISA)]]. 
- This concept relies on the [[Two's Complement]] representation for negative numbers.
## 👍 Pros & 👎 Cons
- This isn't a trade-off; it's a **necessary function**. 
- **Significance:** It allows a compact 16-bit immediate value inside an instruction to correctly interact with 32-bit register values for signed arithmetic. The alternative, *zero-extension* (filling with `0`s), is used for *unsigned* or logical operations.
## See Also
- [[Datapath]] 
- [[ALU]] 
- [[Two's Complement]]