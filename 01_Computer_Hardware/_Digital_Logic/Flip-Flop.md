---
tags:
  - concept
  - hardware
  - sequential-logic
  - memory
category: computer-hardware
status: learning
related: "[[Transistor]]"
date: 2025-12-04
---
# Flip-Flop

## 📝 One-Sentence Summary
A Flip-Flop is a sequential logic circuit element that can store one bit of information, updating its value only at a specific "edge" (rising or falling) of a clock signal.

## 💡 Analogy
*A Flip-Flop is like a **camera** taking a photo. It doesn't record a continuous movie of the input; it only captures a "snapshot" of the data exactly when the shutter clicks (the clock edge) and holds that image steady until the next click.*

## 🔑 Key Details
- **What it is:** 
	- A memory element made of latches. Unlike a **Latch** (which is "transparent" or level-sensitive), a Flip-Flop is **edge-triggered**.
- **Why it exists:** 
	- To synchronize data movement in digital systems. It ensures all parts of a circuit update at the exact same moment, preventing race conditions.
- **Key Types:**
    - **D Flip-Flop:** The most common type. It captures the value of the Data (D) input at the clock edge and outputs it at Q.
    - **JK Flip-Flop:** Can toggle its state.
    - **T Flip-Flop:** Toggles state on every clock cycle if input T is 1.

## 🔗 Connections & Implementations
- Used to build [[Register File|Registers]], [[Program Counter (PC)]], and Counters.
- In [[_VHDL]], it is implied by using `RISING_EDGE(clk)` in a process.

## See Also
-   [[Latch]]
-   [[Register File]]
-   [[Clock]]