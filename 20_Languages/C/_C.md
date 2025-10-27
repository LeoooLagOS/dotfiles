---
tags:
  - concept
  - language
  - c
category: language
status:
  - learning
related: "[[_Java|Java]]"
date: 2025-09-30
---

# _C_

## 📝 One-Sentence Summary
C is a powerful, general-purpose, [[Procedural Programming]] [[_Programming Languages|language]] known for its performance, efficiency, and direct control over hardware and memory.

## 💡 Core Philosophy
"**Trust the programmer.**" 
C's design philosophy is minimalist and provides you with maximum power and flexibility. It assumes you know what you're doing and gives you the tools to interact with the computer at a very low level, without safety nets.

## 📜 History & Creator 
C was developed at Bell Labs by **Dennis Ritchie** between 1972 and 1973. It was created for a very practical purpose: to write the **[[Unix]] [[_Operating Systems|OS]]**. C was a successor to the B language and was designed to be a portable, efficient, and low-level language that was still easy for humans to use. 
Its influence is immense, and its syntax has inspired countless other languages, including C++, C#, [[_Java|Java]], and [[_Python|Python]].
## 🔑 Key Details
- **Execution:** 
	- A **compiled** language. C code is compiled directly into native machine code that the processor can execute, resulting in extremely fast performance. 
- **Typing:** 
	- A **[[Static vs Dynamic Typing|statically-typed]]** language. You must declare the data type of every variable before use. 
- **Memory:** 
	- Features **manual [[Memory Management]]**. You are responsible for explicitly allocating memory with `malloc()` and deallocating it with `free()`. 
- **Paradigm:** 
	- Primarily a **procedural** language.

## 🔗 Connections & Implementations
- **Operating Systems:** 
	- C is the language of operating systems. The [[Kernel|kernels]] of [[_Linux]], [[_Windows]], and [[_macOS]] are all primarily written in C. 
- **Embedded Systems:** 
	- Its direct hardware access and small footprint make it the standard for programming microcontrollers, IoT devices, and other resource-constrained hardware. 
- **High-Performance Computing:** 
	- Used to write performance-critical libraries and applications where speed is the top priority.
## 👍 Pros & 👎 Cons
- **✅ Strengths:** 
	- Unmatched performance, direct memory control via [[Pointers in C]], and a small, stable, and highly portable language. 
- **❌ Weaknesses:** 
	- Manual memory management is complex and a common source of bugs (e.g., memory leaks, buffer overflows). It lacks the built-in features and large standard libraries of modern languages like Python and Java.