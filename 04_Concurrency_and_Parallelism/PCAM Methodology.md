---
tags:
  - methodology
  - design-pattern
  - parallelism
category: cs-fundamental
status:
  - learning
related: "[[Parallelism]]"
date: 2025-11-25
---
# PCAM Methodology

## 📝 One-Sentence Summary
PCAM is a four-stage design methodology (Partitioning, Communication, Agglomeration, Mapping) used to transition a problem from a sequential concept to an efficient parallel algorithm.

## 💡 Analogy
Think of organizing a **large construction project**:
1.  **Partitioning:** You break the blueprint into tiny tasks (lay one brick, cut one wire).
2.  **Communication:** You figure out who needs to talk to whom (the electrician needs the wall built by the bricklayer first).
3.  **Agglomeration:** You realize managing 1,000 workers laying one brick each is chaotic, so you group tasks into "Build Wall A" assigned to a specific team to reduce overhead.
4.  **Mapping:** You assign the "Build Wall A" team to the North side of the site based on available space to maximize utilization.

## 🔑 Key Stages
1.  **Partitioning (Partición):** The problem and data are decomposed into the smallest possible tasks to expose maximum concurrency, typically ignoring hardware constraints at this stage.
2.  **Communication (Comunicación):** Determines the flow of data. Tasks typically cannot execute independently; they require data exchange with other tasks to proceed.
3.  **Agglomeration (Aglomeración):** Small tasks are combined into larger tasks to improve performance or reduce communication and synchronization costs.
4.  **Mapping (Mapeo):** Each task is assigned to a physical processor to maximize processor utilization and minimize communication costs.

## See Also
- [[Concurrency vs Parallelism]]
- [[Parallel Communication Patterns]]