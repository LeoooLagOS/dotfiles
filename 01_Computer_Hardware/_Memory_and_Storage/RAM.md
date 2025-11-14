---
tags:
  - concept
  - hardware
  - memory
category: computer-hardware
status:
  - learning
related: "[[Memory (Computer)]]"
date: 2025-10-03
---

# RAM (Random-Access Memory)

## 📝 One-Sentence Summary
RAM is a volatile form of computer memory that provides high-speed, temporary storage for the operating system, applications, and data currently in use, allowing for fast "random" access to any location.

## 💡 Analogy
RAM is the **workbench of your computer**. When you want to work on a project (run a program), you take the tools and materials from your storeroom (the [[Storage Devices|Hard Drive]]) and place them on your workbench (RAM). This gives you fast, direct access to everything you need. When you're done for the day (power off), you clear the workbench.
## 🔑 Key Details
- **What it is:** 
	- The primary "working memory" of a computer. 
- **Why it exists:** 
	- To provide the [[CPU]] with extremely fast access to data and instructions. Retrieving data from RAM is orders of magnitude faster than from a hard drive or SSD. 
- **Core Characteristics:** 
	- **Random Access:** The [[CPU]] can access any memory cell directly in roughly the same amount of time, regardless of its physical location. This is unlike sequential access (e.g., a magnetic tape) where you have to wind through the tape to find the data. 
- **Volatile:** 
	- It loses all its stored information when the computer is powered off. 
- **Types of RAM:** 
	- **[[DRAM]] (Dynamic RAM):** 
		- The most common type used for main system memory. It's dense and cheap but requires a constant electrical refresh to maintain its data. 
	- **[[SRAM]] (Static RAM):** 
		- Much faster than DRAM and doesn't need to be refreshed. It's more expensive and less dense, so it's used for smaller, high-speed applications like CPU [[Cache]].
## 🔗 Connections & Implementations
- The [[_Operating Systems|Operating System]] is loaded into RAM during the boot process. 
- When you launch an application, its code is copied from a [[Storage Devices|Storage Device]] into RAM. 
- The OS uses techniques like [[Virtual Memory]] to manage RAM efficiently.
## 👍 Pros & 👎 Cons
- **✅ Pros:** 
	- Extremely fast read and write speeds, essential for modern multitasking. 
- **❌ Cons:** 
	- Volatile (all data is lost on power down), significantly more expensive per gigabyte than mass storage.