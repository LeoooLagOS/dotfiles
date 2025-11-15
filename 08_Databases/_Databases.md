---
tags:
  - overview
  - concept
  - database
category: databases
status: learning
related: "[[_Computer Science]]"
date: 2025-11-15
---
# _Databases_
## 📝 One-Sentence Summary
*An organized collection of structured information, or data, typically stored electronically in a computer system and managed by a Database Management System ([[DBMS]]).*
## 💡 Analogy
*A database is like a massive, digital library's filing system. The **Database Management System (DBMS)** is the head librarian who knows exactly how to store, retrieve, update, and protect every single book (data) efficiently and safely.*
## 📜 History & Creator
*Early databases in the 1960s were navigational (like IBM's IMS). The modern **relational database** concept was defined by **Edgar F. Codd** at IBM in 1970. His paper, "A Relational Model of Data for Large Shared Data Banks," laid the foundation for [[SQL|SQL (Structured Query Language)]] and systems like System R (IBM) and Oracle.*
## 🔑 Core Philosophy & Design
*The primary goal is to provide **data persistence**, **abstraction**, and **reliable access**. A database separates the **physical storage** (how data is on disk) from the **logical view** (how users and applications see it). This enables multiple users to access and modify data concurrently (concurrency control) while ensuring the data remains correct and consistent (data integrity).*
## ⚙️ Key Details
- **What it is:** 
	- A system for storing, managing, retrieving, and securing digital data at scale.
- **Why it exists:** 
	- To solve the problem of managing large amounts of data efficiently, consistently, and safely, allowing applications to function without having to build complex data storage and integrity logic from scratch.
- **Core Functions/Components:**
    - **[[DBMS|DBMS (Database Management System)]]**: The software that manages the database.
    - **Data Models**: The structure defining how data is organized (e.g., [[Relational Model]], [[Document Model]], [[Graph Model]]).
    - **Query Language**: The language used to interact with the data (e.g., [[SQL|SQL (Structured Query Language)]]).
    - **Transactions**: Operations that must succeed or fail as a single, atomic unit (e.g., [[ACID Properties]]).
    - **Indexes**: Data structures that dramatically improve data retrieval speed (e.g., [[B-Trees]]).
## 🔗 Connections & Implementations
*This topic is the foundation for the storage layer of almost all modern software.*
- **Applications:** Provides the backend for `21_Web_Development\` and virtually all enterprise software.
- **Distributed Systems:** Forms the basis for stateful `11_Distributed_Systems\` (see [[CAP Theorem]]).
- **Core CS:** Relies on `05_Algorithms_and_Data_Structures\` (for indexes, query optimization) and `03_Operating_Systems\` (for file I/O and memory management).
## See Also
- [[Relational Model]]
- [[NoSQL]]
- [[SQL]]