---
tags:
  - concept
  - encoding
  - theory
category: cs-fundamental
status: learning
related: "[[RS232]]"
date: 2026-01-09
---
# ASCII Table

## 📝 One-Sentence Summary
A character encoding standard that assigns numerical values (0-127) to letters, digits, and control characters for digital communication.

## 💡 Analogy
**The Secret Decoder Ring:** Both computers agree that the number `65` always means the capital letter `A`. Without this shared "ring," the 1s and 0s are just noise.

## 🔑 Key Details
- **What it is:** American Standard Code for Information Interchange.
- **Control Characters:** The first 32 codes (0-31) are non-printable actions (e.g., `XON`, `XOFF`, `NULL`).
- **Platform Differences (Newline Protocol):**
    - **Windows:** Uses **CRLF** (Carriage Return + Line Feed) $\rightarrow$ `\r\n` (Hex `0D 0A`).
    - **Linux/Unix:** Uses **LF** (Line Feed) $\rightarrow$ `\n` (Hex `0A`).
    - **Note:** In class, Linux was simplified as `0`, but in standard ASCII, Line Feed is `10` (Hex `0A`).

## 🔗 Connections & Implementations
- Used in **[[Hercules]]/[[RealTerm]]** to display data in "Hexispace" mode.
- Critical for serial protocols where specific hex values trigger flow control ([[XON-XOFF Protocol|XON/XOFF]]).

## 👍 Pros & 👎 Cons
- **Pros:** Extremely lightweight; universal support.
- **Cons:** Limited to 128 characters (no emojis or non-English scripts); replaced by UTF-8 in modern web apps.