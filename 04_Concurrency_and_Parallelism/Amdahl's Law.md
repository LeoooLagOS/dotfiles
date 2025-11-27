---
tags:
  - concept
  - concurrency
  - performance
  - math
category: cs-fundamental
status: learning
related: "[[Concurrency vs Parallelism]]"
date: 2025-11-27
---
# Amdahl's Law
## 📝 One-Sentence Summary
*Amdahl's Law is a formula used to find the maximum improvement possible by improving a particular part of a system, defining the theoretical speedup limit of parallel execution.*
## 💡 Analogy
* **The Tunnel:** You drive 100 miles. 90 miles are on a 10-lane highway (Parallelizable), but 10 miles are in a **single-lane tunnel** (Serial).
* Even if you buy a Ferrari that goes 1,000,000 MPH on the highway, your trip can **never take less than the time it takes to drive through the tunnel.** The serial portion limits the maximum speedup.
## 🔑 Key Details
- **Formula:** $S = \frac{1}{(1 - p) + \frac{p}{n}}$
    - $S$ = Speedup
    - $p$ = Proportion of code that is parallelizable.
    - $n$ = Number of processors.
- **Implication:** If 5% of your program is serial (cannot be split), the maximum speedup is **20x**, no matter if you have 1,000 cores.
## 🔗 Connections & Implementations
* **Hardware:** This explains why we stopped seeing massive clock speed jumps and started seeing more Cores ([[Linux CPU Monitoring|lscpu]]).
* **Coding:** Optimization should focus on the *serial* bottlenecks, not just throwing more threads at the problem.
## 👍 Pros & 👎 Cons
* **Cons:** It assumes the problem size is fixed (Fixed Workload). *Gustafson's Law* argues that as computers get faster, we solve larger problems, making parallelism more valuable.
## See Also
- [[Concurrency vs Parallelism]]
- [[Thread]]