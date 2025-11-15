---
tags:
  - concept
  - isa
  - cpu
  - overview
category: computer-architecture
status:
  - learning
related: "[[_Computer Architecture]]"
date: 2025-10-24
---
# _ISA (Instruction Set Architecture)

## 📝 One-Sentence Summary
*The ISA is the foundational "contract" between software and hardware, defining the complete set of commands, data types, and registers that a processor can understand and execute.*

## 💡 Analogy
*An ISA is like the **full user manual and dashboard layout** for a car. It's the complete "interface" a driver (software) interacts with.* It defines *what* the car can do (e.g., "turn left," "accelerate," "brake") but *not* how the engine or steering rack (the hardware) is built to accomplish it. 
## 📜 History & Creator
*The concept of a formal ISA emerged with the first stored-program computers, like the **IBM System/360** in the 1960s. This was a landmark:* IBM created a *family* of computers with different hardware and prices that all ran the same software, proving the power of a stable, abstract ISA.

## 🔑 Core Philosophy & Design
*The core philosophy is **abstraction**. The ISA intentionally hides the complex, inner details of the hardware (the "microarchitecture"). This allows hardware engineers to invent new, faster processors (e.g., Intel vs. AMD) while allowing software (e.g., Windows) to run on both without modification. The primary design choice is between [[RISC|RISC (Reduced Instruction Set Computer)]] and [[CISC|CISC (Complex Instruction Set Computer)]] philosophies.*

## ⚙️ Key Details
-   **What it is:** 
	- The part of the computer architecture that is visible to the programmer or compiler.
-   **Why it exists:** 
	- To create a stable, standard interface that separates the concerns of software development from the concerns of hardware design.
-   **Core Functions/Components:**
    -   [[Instruction Set]]: The list of all commands (e.g., `add`, `load`, `branch`).
    -   [[ISA: Addressing Modes]]: The different ways instructions can specify data locations.
    -   [[ISA: Registers]]: The number, type, and names of programmer-visible registers.
    -   [[ISA: Data Types]]: The fundamental data sizes (e.g., byte, word) the CPU supports.
    -   [[ISA: Instruction Formats]]: The binary layout (R-type, I-type, J-type) of instructions.

## 🔗 Connections & Implementations
*The ISA is a core component of [[_Computer Architecture]]. A [[Compiler]]'s job is to translate a high-level language (like C, into the specific machine code of a target ISA. 
The [[_Datapath]] and [[Control Unit]] are the physical *implementation* of an ISA.*

## See Also
-   [[_Computer Architecture]]
-   [[RISC]]
-   [[CISC]]
-   [[_Datapath]]
-   [[Compiler]]