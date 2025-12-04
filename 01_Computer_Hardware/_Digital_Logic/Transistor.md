---
tags:
  - concept
  - hardware
  - transistor
  - electronics
category: computer-hardware
status: learning
related: "[[Logic Gate]]"
date: 2025-12-04
---
# Transistor

## 📝 One-Sentence Summary
A transistor (specifically the MOSFET in modern computers) is a tiny electronic component that acts as a voltage-controlled switch, either blocking or allowing the flow of current to represent binary 0s and 1s.

## 💡 Analogy
*A transistor is like a **water spigot**. The **Source** is the water pipe coming from the wall, the **Drain** is the sink, and the **Gate** is the handle. When you turn the handle (apply voltage), you create a channel for the water (current) to flow from the source to the drain.*

## 🔑 Key Details
- **What it is:** 
	- The fundamental active component in digital electronics. Modern CPUs use **MOSFETs** (Metal-Oxide-Semiconductor Field-Effect Transistors).
- **Why it exists:** 
	- To create physical on/off switches that can be controlled electrically, allowing for the construction of logic gates without moving parts.
-   **Core Types (CMOS Logic):**
    - **NMOS (n-channel):** Turns **ON** when the gate is High (1). It is excellent at passing a "0" (Ground) signal.
    - **PMOS (p-channel):** Turns **ON** when the gate is Low (0). It is excellent at passing a "1" (Voltage/Vcc) signal.
    - **CMOS (Complementary MOS):** A design technique that uses pairs of NMOS and PMOS to create gates that consume very little power.

## 🔗 Connections & Implementations
-   Transistors are combined to build [[Logic Gate|Logic Gates]]. For example, a NAND gate needs 4 transistors (2 PMOS + 2 NMOS).
-   Millions (or billions) of them are printed onto a single [[CPU]] die using photolithography.

## 👍 Pros & 👎 Cons
-   **Pros:** Extremely small, fast switching, low power consumption (especially CMOS).
-   **Cons:** Generates heat when switching; susceptible to "leakage" current as they get smaller.

## See Also
-   [[Logic Gate]]
-   [[_Computer Hardware]]