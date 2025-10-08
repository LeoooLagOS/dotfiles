---
tags:
  - concept
  - cs-fundamental
  - memory
category: <cs-fundamental>
status:
  - learning
related: "[[Data Types]]"
date: 2025-09-16
---

# Variables and Memory

## 📝 One-Sentence Summary
A variable is a named reference to a location in computer memory that stores a specific piece of data.

## 💡 Analogy
A variable is like a **labeled box** in a vast warehouse (your computer's memory). 
-   The **variable name** (`age`) is the label written on the box.
-   The **value** (`25`) is the content inside the box.
-   The **memory address** is the box's unique location code (e.g., Aisle 5, Shelf 3, Position 2), which the computer uses to find it instantly.

## 🔑 Key Details
-   **What it is:** 
	- A symbolic name (an identifier) that is associated with a value and a location in memory. It is the primary way we interact with data in a program.
-   **Why it exists:** 
	- It allows us to store, retrieve, and manipulate data without having to know the specific, low-level memory address where the data is located. It abstracts away the hardware complexity.
-   **Core Operations:**
    -   **Declaration:** "Creating" the box and specifying what kind of stuff it's allowed to hold (its [[Data Types|Data Type]]).
    -   **Assignment:** "Putting" a value into the box.

## 🔗 Connections & Implementations
The way variables are handled differs between language types.

-   In a **statically-typed** language like [[_Java]], you must declare the type of the box before you can put anything in it:
   ```java
    // Declaration and assignment are separate
    String name;      // Creates the box labeled "name" for Strings
    name = "Leo";   // Puts the value in the box
    ```

-   In a **dynamically-typed** language like [[_Python]], the box is created and typed automatically when you put a value in it:
   ```python
    # Declaration and assignment happen at the same time
    name = "Leo"
    ```

## See Also
-   [[Pointers]] (A special variable that stores a memory address)
-   [[Data Types]]
-   [[Static vs Dynamic Typing]] 