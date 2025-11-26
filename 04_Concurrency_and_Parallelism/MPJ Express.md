---
tags:
  - java
  - mpi
  - distributed-systems
  - parallelism
status:
  - learning
related: "[[PCAM Methodology]]"
date: 2025-11-25
---
# MPJ Express

## 📝 One-Sentence Summary
MPJ Express is a Java implementation of the MPI (Message Passing Interface) standard, enabling parallel programming on distributed clusters where processes do not share memory and must communicate via messages.

## 💡 Analogy
Unlike Fork/Join (people in the same room sharing a whiteboard), MPJ Express is like **a team of researchers in different buildings**.
They cannot see each other's notes (**No Shared Memory**). To collaborate, they must send physical letters (**Message Passing**) containing the data. If the leader needs a total count, every researcher sends their number, and the leader sums them up (Reduction).

## 🔑 Key Details
- **Architecture:** Executes on multicore processors or clusters (multiple nodes).
- **Memory Model:** **Distributed Memory**. Process A cannot access Process B's variables directly; they must send data packets.
- **Communicator:** `MPI.COMM_WORLD` is the default group containing all processes.
- **Communication Types:**
    * **Point-to-Point:** Direct communication between two specific processes (`Send`, `Recv`).
    * **Collective:** Communication involving all processes (`Bcast`, `Scatter`, `Gather`, `Reduce`).

## See Also
- [[Parallel Communication Patterns]]
- [[Fork Join Framework]]