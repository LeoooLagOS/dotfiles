---
tags:
  - overview
  - concept
  - computer-graphics
category: cs-fundamental
status: learning
related: "[[_Computer Science]]"
date: 2025-11-15
---
# _Computer Graphics_
## 📝 One-Sentence Summary
*Computer Graphics is the field of study focused on digitally synthesizing and manipulating visual content, or "how to create pictures with computers."*
## 💡 Analogy
*Think of Computer Graphics as **digital filmmaking and sculpting combined**. You are given a dark, empty "soundstage" (a 3D scene), and it's your job to add actors (models), define their surfaces (textures), set up lights (lighting), and finally, "film" it from a specific angle (rendering) to create a final 2D image.*
## 📜 History & Creator
*The field emerged in the early 1960s. **Ivan Sutherland** is widely regarded as the "father" of computer graphics for his work on **Sketchpad** in 1963, an innovative program that demonstrated graphical user interfaces ([[GUI]]s) and computer-aided design ([[CAD]]) for the first time. Major milestones include the development of 3D wireframes, raster graphics (pixel-based), and the creation of Pixar (originally Lucasfilm's graphics group), which pushed rendering technology forward.
## 🔑 Core Philosophy & Design
The core philosophy of computer graphics is **"faking reality efficiently."** It's a constant series of trade-offs between **realism** (how convincing the image looks) and **performance** (how fast it can be generated). This trade-off dictates its two main branches: **real-time graphics** (e.g., video games, prioritizing speed) and **offline rendering** (e.g., movies, prioritizing photorealism).*
## ⚙️ Key Details
- **What it is:** 
	- A subfield of Computer Science that involves generating images with the aid of computers. It combines elements of geometry, mathematics (especially linear algebra and calculus), physics (for light and simulation), and computer science (algorithms and data structures).
- **Why it exists:** 
	- To enable visual communication and simulation. It powers everything from user interfaces, data visualization, and entertainment (movies, games) to scientific simulation, medical imaging, and product design.
- **Core Functions/Components:**
    - **Modeling:** Creating 3D representations of objects (e.g., using meshes, polygons).
    - **Rendering:** The process of generating a 2D image from a 3D scene. This is the central problem.
    - **Animation:** Simulating motion over time by showing a sequence of images.
    - **Interaction:** Handling user input to manipulate models or the viewpoint (e.g., in a game or CAD tool).
## 🔗 Connections & Implementations
* This field is heavily reliant on **[[Linear Algebra]]** (for transformations like rotation, scaling, and translation) and **[[_Data Structures]]** (like B-trees and octrees for spatial partitioning).
* It is hardware-accelerated by the **[[GPU|GPU (Graphics Processing Unit)]]**, a piece of hardware designed for parallel computation.
* Key APIs and libraries include **[[OpenGL]]**, **[[DirectX]]**, and **[[Vulkan]]**.
## See Also
- [[Rendering Pipeline]]
- [[Linear Algebra]]
- [[OpenGL]]