---
tags:
  - concept
  - OS
  - kernel
  - cs-fundamental
category: OS
status:
  - learning
related: "[[_Operating Systems]]"
date: 2025-10-03
---

# Kernel

## 📝 One-Sentence Summary
The kernel is the central, core component of an [[_Operating Systems|Operating System]] that has complete control over everything in the system, acting as the primary bridge between software applications and the physical hardware.
## 💡 Analogy
If the Operating System is the government of a city, the **kernel is the city's executive branch and control tower**. It's the small, powerful, and protected group that makes all the critical decisions: dispatching emergency services (`handling interrupts`), managing all the traffic (`CPU scheduling`), allocating land (`memory management`), and giving special permissions to access secure facilities (`system calls`). All other programs in the city must make requests to this central authority.
## 🔑 Key Details
- **What it is:** 
	- The foundational program of an OS that is loaded first on boot and remains in memory at all times. 
- **Why it exists:** 
	- To securely manage the hardware resources ([[CPU]], [[Memory (RAM & ROM)|Memory]], [[Input and Output (I/O) Devices]]) and provide a stable, consistent API ([[System Call|System Calls]]) for applications. 
- **Kernel Space vs. User Space:** 
	- The kernel runs in a highly privileged processor mode (kernel space), with unrestricted access to all hardware. Applications run in a restricted mode (user space) and must ask the kernel for permission to perform privileged operations.

The core philosophy of a kernel is to provide a secure and efficient abstraction layer over the hardware. 
The main design decision is how to structure this control, leading to different kernel architectures. 
- **Monolithic Kernel:** 
	- The entire operating system (process management, memory management, file systems, device drivers) runs in a single, large program in a special, protected memory space called **kernel space**. 
		- **Analogy:** A single, all-powerful government building where every department works together in one place. 
		- **Pros:** Very fast communication between components. 
		- **Cons:** A bug in one part (like a device driver) can crash the entire system. 
- **Microkernel:** 
	- Only the absolute most essential functions (like process scheduling and memory management) run in kernel space. Other services (like file systems and device drivers) run as separate programs in the less-privileged **user space**. 
		- **Analogy:** A small, central government that delegates most services to independent, private companies. 
		- **Pros:** More secure and stable; a crash in a driver won't crash the whole OS. 
		- **Cons:** Slower, as communication between services requires more overhead. 
- **Hybrid Kernel:** 
	- A practical compromise that combines the speed of a monolithic kernel with the stability of a microkernel. It keeps more services in kernel space than a microkernel for performance but still allows some components (like [[Drivers|drivers]]) to run in user space.

## 🔗 Connections & Implementations
- **[[Linux Kernel]]**: The most famous example of a **monolithic** kernel. 
- **[[Windows NT Kernel]]**: A well-known **hybrid** kernel. 
- **[[XNU Kernel]]** (macOS/iOS): Also a **hybrid** kernel, combining parts of a monolithic kernel with technologies from the Mach microkernel.
## See Also
- [[System Call]] 
- [[Drivers]]