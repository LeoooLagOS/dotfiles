---
tags:
  - java
  - fork-join
category: applied-skills
status:
  - learning
related: "[[Fork Join Framework]]"
date: 2025-11-27
---
# Parallel Filter Logic (Code Analysis)

## 📝 One-Sentence Summary

A deep dive into the `ParallelFilter.java` class, explaining why `RecursiveAction` was chosen and how the compute cycle implements the parallel strategy.

## 📚 Libraries Used

- **`java.util.concurrent.RecursiveAction`**:
    
    - _Why:_ We are modifying an array _in place_ (the image buffer). We do not need the thread to return a result (like a sum); we just need it to _do_ the work. If we needed a return value, we would have used `RecursiveTask`.
        
- **`java.util.concurrent.ForkJoinPool`**:
    
    - _Why:_ It is the specialized executor service for running recursive tasks. It manages the queue of tasks created by `invokeAll`.
        

## ⚙️ Key Code Blocks Explained

### 1. The Decision Engine (`compute`)

This method is the heart of the "Divide and Conquer" strategy.
```Java
@Override
protected void compute() {
    // AGLOMERATION CHECK
    // Is the work small enough to do effectively?
    if ((endRow - startRow) < THRESHOLD) {
        computeDirectly(); // YES: Do it now (Sequential phase)
    } else {
        // PARTITIONING
        // NO: Too big. Split it in half.
        int mid = (startRow + endRow) / 2;
        
        // Create objects representing the work (but don't run them yet)
        ParallelFilter topHalf = new ParallelFilter(image, startRow, mid);
        ParallelFilter bottomHalf = new ParallelFilter(image, mid, endRow);
        
        // MAPEO / EXECUTION
        // Send to the pool. 'invokeAll' forks the tasks and joins them.
        invokeAll(topHalf, bottomHalf);
    }
}
```

### 2. The Payload (Bitwise Image Processing)

Why do we use `>>` and `& 0xff` instead of `Color.getRed()`? **Performance.** Creating `Color` objects for 16 million pixels triggers the Garbage Collector and slows down the process. Bit manipulation is instantaneous for the CPU.
```java
int rgb = image.getRGB(x, y); // Get the 32-bit integer color

// Extract components (0-255)
// Alpha is the highest 8 bits, then Red, Green, Blue.
int a = (rgb >> 24) & 0xff; 
int r = (rgb >> 16) & 0xff; 

// Invert Color (Negative Filter)
r = 255 - r; 

// Reassemble the 32-bit integer
int newRgb = (a << 24) | (r << 16) | ...
image.setRGB(x, y, newRgb); // Direct memory write
```

## See Also

- [[PCAM Image Processor]]
    
- [[Java Image IO and Hardware]]