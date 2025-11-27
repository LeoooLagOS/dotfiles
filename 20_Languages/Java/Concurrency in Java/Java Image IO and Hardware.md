---
tags:
  - java
  - io
  - hardware
  - performance
category: applied-skills
status:
  - learning
related: "[[Thread Affinity]]"
date: 2025-11-27
---
# Java Image IO and Hardware Detection

## 📝 One-Sentence Summary

An explanation of the I/O and hardware management logic in `Main.java`, detailing how Java interacts with the OS file system and processor topology.

## 📚 Libraries Used

- **`java.awt.image.BufferedImage`**:
    
    - _Why:_ It stores image data in an accessible buffer in RAM. Unlike `Image` (which is for display), `BufferedImage` allows us to read/write individual pixels (`getRGB`, `setRGB`).
        
- **`javax.imageio.ImageIO`**:
    
    - _Why:_ A unified API to handle file formats (JPEG, PNG). It abstracts the complex headers of image files so we just get the pixel data.
        
- **`java.io.File`**:
    
    - _Why:_ Represents the file path on the OS disk.
        

## ⚙️ Key Mechanisms

### 1. Hardware Detection (Dynamic Mapping)

To adhere to the **Mapeo (Mapping)** phase of PCAM, we must know the physical limits of the machine.
```java
// Ask the Operating System: "How many logical cores do I have?"
// On a 6-core / 12-thread CPU, this returns 12.
int processors = Runtime.getRuntime().availableProcessors();

// Create a pool that exactly matches the hardware capability.
// Creating more threads than cores would cause "Thrashing" (context switching overhead).
ForkJoinPool pool = new ForkJoinPool(processors);
```

### 2. Robust I/O (Self-Healing Code)

The code is designed to never crash on missing data. This is a best practice for academic submissions and demos.
```java
private static BufferedImage loadOrCreateImage(String path) {
    File f = new File(path);
    if (f.exists()) {
        return ImageIO.read(f); // Happy Path
    } else {
        // Fallback Path: Generate Synthetic Data
        // This ensures the parallelism logic can always be tested,
        // even if the user forgot to download an image.
        System.out.println("Creating test image...");
        return new BufferedImage(4000, 4000, BufferedImage.TYPE_INT_RGB);
    }
}
```

## See Also

- [[Parallel Filter Logic]]
    
- [[Thread Affinity with JNA]] (Advanced hardware detection)