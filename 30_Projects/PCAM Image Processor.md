---
tags:
  - java
  - concurrency
  - portfolio
category: workshop
status:
  - finished
date: 2025-11-27
related: "[[Fork Join Framework]]"
---
# PCAM Image Processor: Architecture & Design

## 📝 One-Sentence Summary

A high-performance Java application that demonstrates Data Parallelism by applying image filters to high-resolution files using the Fork/Join framework, structured strictly according to the PCAM design methodology.

## 🏗️ Project Structure

The project is organized as a standalone repository nested within the course repository (Submodule pattern).

``` Plaintext
PCAM-Image-Processor/
├── .git/                # Independent version control history
├── src/
│   ├── ParallelFilter.java  # The Parallel Logic (RecursiveAction)
│   └── Main.java            # The Orchestrator (I/O & Setup)
├── input.jpg            # Source data (Domain)
├── output_negative.jpg  # Result data
└── README.md            # Documentation
```

## 🧠 PCAM Methodology Application

This project is a textbook implementation of the 4-stage parallel design process:

### 1. Partitioning 

- **Problem:** An image is a massive grid of pixels (e.g., $4000 \times 4000 = 16,000,000$ tasks).
    
- **Strategy:** Domain Decomposition. Instead of splitting by single pixels (too fine), we split by **Rows**.
    
- **Logic:** `int mid = (start + end) / 2`. The image domain is recursively halved until manageable chunks are found.
    

### 2. Communication 

- **Type:** Shared Memory (Implicit).
    
- **Strategy:** Global Address Space.
    
- **Implementation:** The image data resides in the heap (`BufferedImage`). Threads do not need to send messages (like in [[MPJ Express]]); they simply read/write to specific array indices. The **Scatter** (distribution of indices) and **Gather** (visualization of result) happen implicitly via memory access.
    

### 3. Agglomeration 

- **Problem:** Creating 4,000 threads (one per row) creates massive OS overhead (context switching).
    
- **Strategy:** Grouping tasks into **Blocks**.
    
- **Implementation:** The `THRESHOLD` constant (set to 100 rows).
    
    - _If rows < 100:_ Stop dividing. Process this "lump" of work sequentially.
        
    - _Benefit:_ Balances the cost of thread creation against the speedup of parallelism.
        

### 4. Mapping 

- **Strategy:** Dynamic Load Balancing.
    
- **Implementation:** The `ForkJoinPool`.
    
    - **Hardware Detection:** `Runtime.getRuntime().availableProcessors()` queries the OS for physical cores.
        
    - **Work-Stealing:** If Core 1 finishes its block of rows (e.g., a simple black sky), it "steals" a pending block from Core 2 (e.g., a complex texture), keeping the CPU 100% utilized.
        

## See Also

- [[Parallel Filter Logic]] (The code explanation)
    
- [[Java Image IO and Hardware]] (The libraries used)