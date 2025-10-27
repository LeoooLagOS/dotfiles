---
tags:
  - concept
  - java
  - cs-fundamental
category: <cs-fundamental>
status:
  - mastered
related: "[[Control Structures]]"
date: 2025-09-16
---

# For-Loops in Java

## 📝 One-Sentence Summary
Java provides two primary `for` loop constructs: the traditional index-based loop for full control, and the enhanced for-each loop for simple, readable iteration.

## 💡 Analogy
A **traditional `for` loop** is like driving a manual car: you have full control over the gears, clutch, and accelerator (the index `i`, condition, and increment). An **enhanced `for-each` loop** is like driving an automatic: you just press "go," and it handles the details of moving through the elements for you. 

## 🔑 Key Details
-   **What it is:** A control flow statement for specifying iteration, which allows code to be executed repeatedly.
-   **Why it exists:** To automate the process of iterating over a sequence of elements, such as an array or collection.

## 🔗 Connections & Implementations
### Traditional `for` Loop
Gives you access to the index `i`, which is essential for tasks that require positional information.
```java
for (int i = 0; i < array.length; i++) {
    // Best for modifying the array or comparing adjacent elements.
    System.out.println("Index: " + i + ", Value: " + array[i]);
}
````

### Enhanced `for-each` Loop

Provides a cleaner, more readable syntax when you only need the value of each element, not its index. It is less error-prone as it hides the index management logic.

```Java
for (ElementType element : collection) {
    // Best for simply reading or processing each element in a collection.
    System.out.println("Value: " + element);
}
```

- Used to solve: [[Best Time to Buy and Sell Stock (Java)]]
    

## See Also

- [[While Loops in Java]]
    
- [[Control Structures]]