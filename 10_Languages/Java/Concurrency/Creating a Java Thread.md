---
tags:
  - concept
  - java
  - concurrency
  - implementation
category: language
status:
  - learning
related: "[[_Java Threads]]"
date: 2025-10-06
---

# Creating a Java Thread

## 📝 One-Sentence Summary
The two primary ways to define a task for a thread in Java are by extending the `Thread` class or by implementing the `Runnable` interface, with the latter being the more flexible and preferred approach.

## 💡 Analogy
- **`extends Thread`** is like becoming a specialized **"Chef"** yourself. Your very identity is that of a chef; you can cook, but you can't also be a specialized "Baker" (extend another class). 
- **`implements Runnable`** is like writing a **"Recipe"**. You are creating a task (the recipe) that any available chef (any `Thread` object) can be given to execute. Your recipe can still inherit from a "Master Recipe Book" (extend another class).

## 🔑 Key Details
- **Method 1: `extends Thread`** 
	1. Create a class that `extends java.lang.Thread`. 
	2. **Override the `run()` method** with the code you want the thread to execute. 
	3. Create an instance of your new class and call its **`.start()` method** to begin execution. 
	- **Limitation:** Your class cannot extend any other class. 
- **Method 2: `implements Runnable` (Preferred)** 
	1. Create a class that `implements` the `Runnable` interface. 
	2. Implement the `run()` method from the interface. 
	3. Create an instance of your class (the task), create a new `Thread` object, and pass your task to the `Thread`'s constructor. 
	4. Call the `.start()` method on the `Thread` object. 
	- **Advantage:** This is better object-oriented design. It separates the task from the runner. Your task class is still free to extend another class.
## 🔗 Connections & Implementations
- Calling `.start()` is crucial as it initializes the thread with the OS and then calls `run()`. Calling `run()` directly simply executes the code in the current thread, providing no concurrency.

## See Also

- [[_Java Threads]]