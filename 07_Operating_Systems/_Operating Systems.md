---
tags:
  - concept
  - OS
  - cs-fundamental
  - overview
category: <cs-fundamental>
status:
  - learning
related: "[[_Computer Hardware]]"
date: 2025-10-02
---

# _Operating Systems_

## 📝 One-Sentence Summary
An operating system (OS) is the core [[Software]] that acts as an intermediary between computer hardware and the user, managing all hardware resources and providing common services for application programs.
## 💡 Analogy
The OS is like the **government and infrastructure of a city**. It doesn't build the specific shops or houses (the applications), but it manages the essential, shared resources like the roads (`CPU scheduling`), the power grid (`memory management`), the postal service (`file system`), and the police force (`security`), allowing all the individual businesses to run smoothly and safely.

## 📜 History & Creator 
The concept of an OS evolved through the 1950s with early systems that could run one "batch" job at a time. The development of **[[Multics]]** in the 1960s at Bell Labs, MIT, and GE was a major milestone. From Multics came **[[Unix]]**, developed by **Ken Thompson** and **Dennis Ritchie** at Bell Labs in the early 1970s. 
The principles established by Unix form the foundation of most modern operating systems today.
## 🔑 Key Details
- **What it is:** 
	- A resource manager and an extended machine. It abstracts away the complex details of the hardware, presenting the user with a clean, virtual interface. 
- **Why it exists:** 
	- To manage complexity. Without an OS, every application programmer would have to write their own code to handle the [[CPU]], memory, and storage devices, which would be incredibly inefficient and error-prone. 
- **Core Functions:** 
	- **Process Management:** [[Processes vs Threads|Managing processes and threads]]. 
	- **Memory Management:** Allocating and deallocating memory space. 
	- **File System Management:** Organizing files and directories on storage devices. 
	- **Device Management:** Interacting with hardware devices through [[Drivers|drivers]]. 
	- **Security:** Enforcing access controls and protecting system resources.
## 🔗 Connections & Implementations
The OS is the foundational [[Software]] layer upon which everything else is built. 
- **Specific Implementations:** 
	- [[_Linux]] 
	- [[_Windows]] 
	- [[_macOS]] 
	- Network-specific: [[Cisco IOS]] 
- **Core Concepts:** 
	- The OS is responsible for managing the concepts described in [[Concurrency vs Parallelism]]. 
	- It controls how applications interact with [[_Computer Hardware]].

## See Also 
- [[Kernel]] 
- [[System Call]]