---
tags:
  - concept
  - distributed-systems
  - theory
category: Distributed Systems
status: learning
related: "[[_Distributed Systems]]"
date: 2026-01-04
---

# CAP Theorem

## 📝 One-Sentence Summary
A fundamental principle stating that a distributed data store can only provide two out of three guarantees simultaneously: Consistency, Availability, and Partition Tolerance.

## 💡 Analogy
**The Restaurant Phone-In:** 
1. **Consistency:** Every waiter knows the exact number of tables available at any second.
2. **Availability:** The phone is always answered, and you can always book a table.
3. **Partition Tolerance:** The restaurant stays open even if the phone line between the kitchen and the front desk is cut.
*If the line is cut (Partition), you either stop taking bookings (Lose Availability) or risk overbooking because the kitchen and desk can't talk (Lose Consistency).*

## 🔑 Key Details
- **What it is:** 
	- A theorem proposed by Eric Brewer that defines the trade-offs in distributed system design.
- **Why it exists:** 
	- Because network failures (Partitions) are inevitable in real-world distributed systems.

### The Three Pillars
1. **Consistency (C):** 
	1. Every read receives the most recent write or an error.
2. **Availability (A):** 
	1. Every request receives a (non-error) response, without the guarantee that it contains the most recent write.
3. **Partition Tolerance (P):** 
	1. The system continues to operate despite an arbitrary number of messages being dropped or delayed by the network between nodes.

## 🔗 Connections & Implementations
- **[[CP Systems]]:** (e.g., [[MongoDB]], [[HBase]]) Wait for a response from the partitioned node, risking timeout/unavailability to ensure data is correct.
- **[[AP Systems]]:** (e.g., [[Cassandra]], [[CouchDB]]) Return the most recent local version of data, risking "stale" info to ensure the system stays up.
- **Note:** In a world with network partitions, you **must** choose between C and A.

## 👍 Pros & 👎 Cons
- **Pros:** 
	- Provides a clear framework for choosing the right database/tool for a specific project (e.g., Banking needs **CP**, Social Media likes **AP**).
- **Cons:** 
	- It's often misunderstood as a "pick 2" static choice; modern systems ([[PACELC Theorem|PACELC]]) refine this during normal operation.

## See Also
- [[PACELC Theorem]]
- [[Eventual_Consistency]]