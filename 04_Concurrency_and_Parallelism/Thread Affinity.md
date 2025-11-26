---
tags:
  - theory
  - OS
  - performance
  - hardware
category: cs-fundamental
status:
  - learning
related: "[[Thread Affinity with JNA]]"
date: 2025-11-26
---
# Thread Affinity 
## 📝 One-Sentence Summary 
Thread Affinity (or Processor Affinity) is a scheduling property that binds a specific thread or process to a specific CPU core (or set of cores) to optimize performance.
## 💡 Analogy 
Think of **assigned seating** in an office versus **hot-desking**: 
* **No Affinity (Hot-Desking):** You sit at a different desk every day. You waste time every morning setting up your monitor, adjusting the chair, and finding your stapler (Context Switching & Cold Cache). 
* **Affinity (Assigned Desk):** You sit at the exact same desk every day. Your documents are already open, and your tools are exactly where you left them (Cache Locality). You start working immediately. 
## 🔑 Key Concepts 
1. **Cache Locality:** 
	* The primary benefit. If a thread stays on Core 0, the data it needs is likely already sitting in Core 0's L1 or L2 cache. Moving to Core 1 would require fetching that data again from RAM (which is slow). 
2. **Soft Affinity:** 
	* The Operating System's scheduler *tries* to keep a thread on the same core, but will move it if necessary to balance the system load. 
3. **Hard Affinity:** 
	* The programmer explicitly commands the OS to *only* run a thread on specific cores (e.g., using `taskset` in Linux). 
4. **Migration:** 
	* The act of moving a thread from one core to another. Tools like JNA can be used to detect when this migration occurs by querying the current CPU ID. 
## See Also 
- [[Thread Affinity with JNA]] (practical JAVA implementation) 
- [[_Operating Systems]]