---
tags:
  - overview
  - concept
  - vhdl
  - language
category: language
status: learning
related: "[[_Computer Architecture]]"
date: 2025-10-30
---
# _VHDL_ (VHSIC Hardware Description Language)

## 📝 One-Sentence Summary
*VHDL is a standardized, strongly-typed programming language used to describe, simulate, and synthesize digital logic circuits and hardware (like [[FPGA]]s and [[ASIC]]s).*
## 💡 Analogy
*If C++ or Python are languages used to write **software instructions** (a "to-do list" for a processor), VHDL is a language used to write **hardware blueprints**. 
You are not describing *what* to do; you are describing the *physical machine itself*—the logic gates, wires, and registers.*
## 📜 History & Creator
*VHDL stands for **V**HSIC **H**ardware **D**escription **L**anguage, where VHSIC itself stands for **V**ery **H**igh **S**peed **I**ntegrated **C**ircuit. It was developed in the 1980s, sponsored by the U.S. Department of Defense (as part of the "Ada" project) to create a standard, vendor-neutral way to document the behavior of complex digital circuits.*
## 🔑 Core Philosophy & Design 
*The core philosophy of VHDL is **[[Concurrency vs Parallelism|concurrency]]** and **explicit timing**. 
Unlike software (which is almost always sequential), all hardware components described in VHDL are assumed to be "on" and "running" *at the same time* (concurrently), just as they would be in a real chip. Logic is described as a flow of signals between processes.
## ⚙️ Key Details 
- **What it is:** 
	- A domain-specific language for describing digital hardware. It is *not* a general-purpose programming language. 
- **Why it exists:** 
	- To allow engineers to design, test, and verify massive, complex digital circuits (like a modern CPU) in a human-readable format before committing to the multi-million dollar expense of manufacturing the physical chip. 
- **Core Functions/Components:** 
	- [[VHDL: ENTITY]]: The "black box" definition, describing a component's inputs and outputs (its `PORT` map). 
	- [[VHDL: ARCHITECTURE]]: The "inside" of the box, describing *how* the component works. 
	- [[VHDL: Structural vs. Behavioral]]: The two main design styles. 
	- [[VHDL: PROCESS]]: The basic unit for describing sequential logic. 
	- [[VHDL: SIGNAL]]: Represents a physical "wire" connecting components.
## 🔗 Connections & Implementations
*VHDL is used to create the physical implementation of a [[_Computer Architecture]]. Its main competitor is [[_Verilog]]. 
The VHDL code is compiled (`vcom`) and simulated in a tool like [[ModelSim]], and then *synthesized* (turned into a physical layout) by a tool like [[Intel Quartus]].*
## See Also
- [[_Verilog]] (The other major HDL) 
- [[FPGA]] 
- [[_Computer Architecture]]