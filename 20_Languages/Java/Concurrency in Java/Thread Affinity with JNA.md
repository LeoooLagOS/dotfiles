---
tags:
  - java
  - jna
  - parallelism
  - hardware
category: applied-skills
status:
  - learning
related: "[[Fork Join Framework]]"
date: 2025-11-26
---
# Thread Affinity & Hardware Identification (JNA)

## 📝 One-Sentence Summary
Java Native Access (JNA) allows Java applications to bypass the JVM abstraction and call native OS functions (like `sched_getcpu` on Linux) to identify exactly which physical CPU core is executing a specific thread.

## 💡 Analogy
Standard Java is like a **Passenger in a Taxi**: You know who your driver is (the Thread Name), but you don't know exactly which street you are on (the CPU Core) because the taxi moves around.
**JNA** is like rolling down the window and asking a police officer for your exact GPS coordinates.

## 🔑 Key Concepts
1.  **The Gap:** Java abstracts hardware. It knows about Threads, but not CPU Cores.
2.  **The Bridge (JNA):** Dynamically loads native libraries (`libc` for Linux, `Kernel32` for Windows) to access system calls.
3.  **The Functions:**
    * **Linux:** `sched_getcpu()` returns the current CPU index.
    * **Windows:** `GetCurrentProcessorNumber()` does the same.
4.  **Use Case:** Critical for performance tuning. Identifying if threads are "migrating" between cores too often helps optimize CPU Cache usage (L1/L2).

## ⚙️ Implementation Pattern
```java
// Logic defined in CpuId class
// Load the C library interface
interface CLib extends Library {
    CLib INSTANCE = Native.load("c", CLib.class);
    int sched_getcpu();
}

// Call the function based on OS
if (os.contains("linux")) {
    return CLib.INSTANCE.sched_getcpu();
}
```
## See Also

- [[Fork Join Framework]]
- [[_Computer Architecture]]
