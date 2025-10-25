---
tags:
  - concept
  - mux
  - cpu
category: computer-architecture
status:
  - learning
related: "[[Datapath]]"
date: 2025-10-24
---

# MUX

## 📝 One-Sentence Summary
*A Multiplexer, or MUX, is a digital "switch" that selects one of several input signals and forwards the selected one to a single output line.*

## 💡 Analogy
*A MUX is a **railroad track switch**. You have multiple tracks (inputs) merging into one, and the switch operator (the `sel` signal) decides which train (data) gets to go onto the main track (output).*

## 🔑 Key Details
- **What it is:** 
	- A combinational logic circuit. Its output is determined *only* by the current value of its inputs (both the data inputs and the select input). 
- **Why it exists:** 
	- To allow multiple data sources to share a single resource or bus. It's the "decision-making" component in hardware, allowing the [[Control Unit]] to choose what data goes where. 
- **Core Inputs/Outputs:** 
	- **Data Inputs:** 
		- Two or more data lines (e.g., `d0`, `d1`). 
	- **Select Input:** 
		- A control signal (`sel`) that determines *which* data input to choose. 
	- **Data Output:** 
		- The single output line (`y`) that carries the selected data.
## 🔗 Connections & Implementations
- The [[Datapath]] uses MUXes extensively. For example: 
	1. To select the [[ALU]]'s second operand (either from the [[Register File]] or from [[Sign Extension]]). 
	2. To select the next value for the [[Program Counter]] (either `PC+4` or the `branch` address). 
	3. To select what data to write back to the [[Register File]] (either from the `ALU` or from memory). 
- The `sel` (select) lines of all MUXes in the datapath are typically controlled by the [[Control Unit]]. 
- In [[_VHDL]], a 2-to-1 MUX can be implemented with a single line: `y <= d0 WHEN sel = '0' ELSE d1;`
## 👍 Pros & 👎 Cons
- **Pros:** 
	- Simple, fast, and essential for routing data and controlling the datapath's operation. 
- **Cons:** 
	- Each MUX introduces a small propagation delay. In complex datapaths, the time it takes for a signal to pass through multiple MUXes can become a factor in the overall clock speed.
## See Also
- [[Datapath]]
- [[Control Unit]]
- [[VIm: VHDL ALU Example]]
