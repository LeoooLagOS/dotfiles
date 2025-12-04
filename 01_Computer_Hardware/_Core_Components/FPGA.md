---
tags:
  - concept
  - hardware
  - fpga
  - logic
category: computer-hardware
status: learning
related: "[[_Computer_Architecture]]"
date: 2025-12-04
---

# FPGA (Field-Programmable Gate Array)

## 📝 One-Sentence Summary
An FPGA is a complex programmable logic device composed of a massive matrix of configurable logic blocks and programmable interconnects, allowing it to be "wired" by software to perform almost any digital function.

## 💡 Analogy
*If a standard CPU is a **printed book** (fixed content), an FPGA is a **magnetic whiteboard** full of letters and magnets. You can rearrange the magnets (logic blocks) and draw lines between them (interconnects) to create any "page" (circuit) you want, and then erase it and build a completely different one tomorrow.*

## 🔑 Key Details
- **What it is:**
	- A high-density programmable chip consisting of an array of logic elements that can be configured by the user "in the field" (after manufacturing).
- **Why it exists:** 
	- To provide a flexible, re-programmable hardware platform that can implement complex digital circuits (like [[CPU]]s or custom datapaths) without the high cost and permanence of creating a custom [[ASIC]] (Application Specific Integrated Circuit).
-   **Core Components:**
    - **Logic Array Blocks (LABs):** Groups of smaller logic elements.
    - **Logic Elements (LEs):** The smallest unit, typically containing a **Look-Up Table ([[LUT]])** (to implement boolean functions) and a programmable **[[Flip-Flop]]** (for memory).
    - **Interconnects:** A network of row and column buses (like "FastTrack") that connect different blocks together.
    - **Embedded Array:** Specialized blocks for implementing [[RAM]] or complex logic functions.

## 🔗 Connections & Implementations
-   You program an FPGA using a Hardware Description Language like [[_VHDL]].
-  The code is synthesized into a "netlist" and downloaded to the chip.
-   It is distinct from a [[CPU]] because it does not run a fixed instruction set; it *becomes* the hardware circuit itself.

## 👍 Pros & 👎 Cons
-   **Pros:** Re-programmable, parallel execution (fast), lower initial cost than custom chips.
-   **Cons:** Slower and consumes more power than a dedicated ASIC designed for the exact same task.

## See Also
-   [[_VHDL]]
-   [[Logic Gate]]
