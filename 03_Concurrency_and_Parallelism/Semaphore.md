---
tags:
  - concept
  - synchronization
  - OS
category: <cs-fundamental>
status:
  - learning
related: "[[Busy-Waiting]]"
date: 2025-10-03
---

# Semaphore

## 📝 One-Sentence Summary

A **semaphore** is a synchronization tool that uses a protected integer counter to manage access to a resource, efficiently blocking processes instead of making them busy-wait.

## 💡 Analogy

A semaphore is like the **control system for a parking garage with a limited number of spaces**.

- The sign at the entrance shows the number of free spaces (the semaphore's **counter**).
    
- When a car arrives (**acquire**), the barrier opens, and the counter decreases by one. If the counter is zero, the car must wait in a queue.
    
- When a car leaves (**release**), the counter increases by one, and if there are cars in the queue, the first one is allowed to enter. The cars in the queue are not burning fuel ([[CPU Cycles]]); they are parked and waiting passively (blocked).

## 🔑 Key Details

- **What it is:** 
	- A non-negative integer variable that can only be manipulated by two atomic and indivisible operations:
	    
	    - **`acquire` (or `wait`/`P`)**: Decrements the semaphore's value. If the value is zero, the process blocks until the value is greater than zero.
	        
	    - **`release` (or `signal`/`V`)**: Increments the semaphore's value. If there are processes blocked waiting, it wakes one of them up.
- **Why it exists:** 
	- It was invented by Edsger Dijkstra to solve synchronization problems efficiently, avoiding busy-waiting. By blocking a process, the OS can assign the CPU to other useful work.  

## 🔗 Connections & Implementations

- **Practical Example:** 
	- The `MeseroSemaforo` calls `mysem.release()` to indicate that a new dish is available, which could wake up a waiting diner.
	``` java 
	// MeseroSemaforo.java (Waiter)
	public void run(){
	  while(true) {
	    // ...
	    mysem.release(); // Signals a dish is available
	    m.agregarPlatilloMesa(nombre);
	    // ...
	  }
	}
	```
	* In  `ComensalSemaforo` code, the diner calls `mysem.acquire()` to "take" a dish. If there are no dishes (the semaphore's counter is zero), the thread blocks. 
	```java
	// ComensalSemaforo.java (Diner)
	public void run(){
	  while(true) {
	    try {
	      mysem.acquire(); // Waits for an available dish
	      m.tomarPlatilloMesa( nombre);
	    } catch (InterruptedException e) {
	      e.printStackTrace();
	    }
	  }
	}
```
 

- **Types:**
    - **Binary Semaphore (Mutex):** Can only take the values 0 or 1. Used to ensure mutual exclusion.
        
    - **Counting Semaphore:** Can take any non-negative value. Used to control access to a set of resources (as in the parking garage example).

## 👍 Pros & 👎 Cons

- **Pros:**
    - **Efficient:** Avoids busy-waiting by blocking processes.
        
    - **Flexible:** Can solve a wide range of complex synchronization problems.
- **Cons:**
    - **Error-prone:** It's easy to make mistakes like forgetting to call `release` after an `acquire`, which can lead to a [[Deadlock]].
        
    - **Low-level logic:** The responsibility for using it correctly falls entirely on the programmer.
## See Also

- [[Busy-Waiting]]
    
- [[Monitor]]
    
- [[Deadlock]]