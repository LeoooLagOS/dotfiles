---
tags:
  - design-pattern
  - architecture
  - parallelism
category: cs-fundamental
status:
  - learning
related: "[[MPJ Express]]"
date: 2025-11-25
---
# Parallel Communication Patterns

## 📝 One-Sentence Summary
Parallel communication patterns define the structural relationship and data exchange strategies between tasks, primarily distinguishing between centralized control (Master-Slave) and distributed cooperation (SPMD).

## 💡 Analogy
* **Master-Slave:** A **Conductor (Master)** directing an **Orchestra (Slaves)**. The conductor distributes the sheet music (Scatter) and the musicians play. The musicians don't decide what to play; they follow the Master's beat.
* **SPMD (Single Program, Multiple Data):** A **group of neighbors mowing their lawns**. Everyone does the same task (mowing) but on their own patch of grass. They only talk to their immediate neighbors to align the edges.

## 🔑 Key Architectures
* **Master-Slave (Global):** A central "Master" process collects data and distributes it to "Slave" processes. Best for aggregating results (e.g., calculating a global average).
* **SPMD (Local):** "Single Program, Multiple Data." All processors run the same program on different chunks of data. Often uses local communication between neighbors.

## 🔄 Collective Operations
* **Broadcast:** One process sends the same message to all.
* **Scatter:** One process splits an array and sends a unique chunk to each process.
* **Gather:** One process collects chunks from all processes and reassembles them.
* **Reduce:** Combines values from all processes (e.g., Sum, Max) into a single result.

## See Also
- [[MPJ Express]]
- [[PCAM Methodology]]