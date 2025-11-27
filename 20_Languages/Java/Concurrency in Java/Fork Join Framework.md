---
tags:
  - java
  - framework
  - shared-memory
  - parallelism
status:
  - learning
related: "[[PCAM Methodology]]"
date: 2025-11-25
---
# Fork Join Framework

## 📝 One-Sentence Summary
The Fork/Join framework is a Java tool for parallelism based on the "divide and conquer" strategy, using a pool of worker threads and "work-stealing" to efficiently utilize multicore processors.

## 💡 Analogy
Imagine a **Chef (Main Task)** who has to chop 100 onions.
1.  **Fork:** The Chef splits the pile in half and gives 50 to a Sous-Chef. They both split their piles again until everyone has a manageable amount.
2.  **Work-Stealing:** If one Sous-Chef finishes early, they don't stand idle; they grab (steal) a pile of onions from a busy Chef's table to help out.
3.  **Join:** Once all onions are chopped, they are combined back into the main pot.

## 🔑 Key Details
- **Concept:** Designed for recursive problems that can be split into independent subtasks.
- **Work-Stealing:** The `ForkJoinPool` manages threads efficiently; idle threads steal tasks from the queues of busy threads to keep the CPU active.
- **Task Types:**
    * **`RecursiveTask<V>`**: Used when the task must return a result (e.g., a calculation).
    * **`RecursiveAction`**: Used when the task does not return a result (void).
- **Core Methods:**
    * **`compute()`**: Defines the main logic; decides whether to solve the base case or split further.
    * **`fork()`**: Sends a subtask to execute asynchronously in the pool.
    * **`join()`**: Waits for the subtask to finish and retrieves the result.

## See Also
- [[Processes vs Threads]]
- [[Concurrency vs Parallelism]]