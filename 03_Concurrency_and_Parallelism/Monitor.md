---
tags:
  - concept
  - synchronization
  - OOP
category: <cs-fundamental>
status:
  - learning
related: "[[Semaphore]]"
date: 2025-10-03
---

# Monitor

## 📝 One-Sentence Summary

A **monitor** is a high-level construct that encapsulates a shared resource along with the procedures that manipulate it, automatically guaranteeing [[Mutual Exclusion]] and providing mechanisms for thread coordination.

## 💡 Analogy

A monitor is like an **operating room in a hospital**. 
- The room (the **monitor**) contains the patient (the **shared resource**) and all necessary equipment.
    
- By rule, **only one surgical team (thread) can be inside the room at a time**. Mutual exclusion is an inherent property of the room.
    
- Inside the room, there is an intercom system (**`wait` and `notify`**). A surgeon can say, "I need to wait for lab results" (`wait`), temporarily leaving the room so another specialist can enter. When the results arrive, the lab can announce over the intercom, "The results are ready" (`notify`), allowing the original surgeon to re-enter when the room is free.

## 🔑 Key Details

- **What it is:** 
	- A programming language structure that combines shared data, the operations on that data, and the necessary synchronization into a single package. 
	- It guarantees that only one thread can be executing any of its methods at a time.
- **Why it exists:** 
	- To simplify concurrent programming and make it less error-prone than semaphores. 
	- The monitor handles mutual exclusion implicitly, freeing the programmer from manually managing locks.
## 🔗 Connections & Implementations

- **Components:**
    - **Mutual Exclusion:** Inherent to the monitor.
        
    - **Condition Variables:** Allow threads to wait (`wait`) for a specific condition inside the monitor and be notified (`notify`/`notifyAll`) by another thread when that condition is met.
    
- **Example in Java:** In `MesaMonitor` code, the `synchronized` keyword on the methods turns the `MesaMonitor` object into a monitor.
    
    - The `ComensalMonitor` uses `wait()` inside a `while` loop to wait for a dish to be available. By calling `wait()`, it temporarily releases the monitor's lock so the waiter can enter.
        
    - The `MeseroMonitor` uses `notifyAll()` to wake up all waiting diners, informing them that the state has changed (a dish has been added).
	    ```java
	    // MesaMonitor.java
	public synchronized void agregarPlatilloMesa( String nombre) {
	  System.out.println("soy el mesero "+nombre+" he colocado en la mesa el platillo ");
	  hayplatillo=true;
	  notifyAll(); // Wakes up waiting diners
	}
	
	public synchronized void tomarPlatilloMesa( String nombre) throws InterruptedException {
	  // The diner must wait if there is no dish
	  while (!hayplatillo)
	    wait(); // Releases the lock and waits
	  System.out.println("soy el comensal "+nombre+" he tomado de la mesa el platillo ");
	} 
    ```

## 👍 Pros & 👎 Cons

- **Pros:**
    - **Safe and structured:** Drastically reduces the risk of synchronization errors. Mutual exclusion is automatic.
        
    - **Easier to reason about:** The concurrency logic is encapsulated in one place.
        
- **Cons:**
    - Less flexible than semaphores in some niche cases.
        
    - Its implementation and notification policies (`notify` vs. `notifyAll`) can be subtle and require a good understanding.
## See Also

- [[Semaphore]]
    
- [[Synchronization]]
    
- [[Object-Oriented Programming]]
