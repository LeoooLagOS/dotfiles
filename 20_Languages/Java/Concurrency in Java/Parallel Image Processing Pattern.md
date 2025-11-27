---
tags:
  - java
  - pattern
  - image-processing
  - optimization
category: applied-skills
status:
  - learning
related: "[[Fork Join Framework]]"
date: 2025-11-27
---
# Parallel Image Processing Pattern

## 📝 One-Sentence Summary

A specific implementation pattern for processing images in parallel using Java's `RecursiveAction` to manipulate pixel data arrays in shared memory.

## 💡 Analogy

Think of an image as a **spreadsheet of numbers**.

- **Sequential:** You go row by row, updating cells one by one.
    
- **Parallel Pattern:** You tear the spreadsheet in half repeatedly until you have small scraps (chunks) of 100 rows. You hand these scraps to different accountants. They calculate independently, and because they write back to the _same_ sheet of paper (Shared Memory), you don't need to glue anything back together (Implicit Gather).
    

## 🔑 Implementation Details

1. **Partitioning (Rows):** Images are best split by rows, not pixels, to preserve memory locality and reduce overhead.
    
2. **Direct Memory Access:** Uses `BufferedImage.getRGB()` and `setRGB()` for simplicity, or `DataBuffer` for maximum speed.
    
3. **Thresholding:** Crucial for performance.
    
    - _Too small:_ Spending more time creating objects than calculating.
        
    - _Too large:_ Cores sit idle waiting for one massive task to finish.
        

## ⚙️ Code Snippet

```java
@Override
protected void compute() {
    // Aglomeration: Check Threshold
    if ((endRow - startRow) < THRESHOLD) {
        computeDirectly(); // Sequential loop over (x,y)
    } else {
        // Partitioning: Split rows
        int mid = (startRow + endRow) / 2;
        invokeAll(new Task(start, mid), new Task(mid, end));
    }
}
```

## See Also

- [[Fork Join Framework]]
    
- [[PCAM Methodology]]