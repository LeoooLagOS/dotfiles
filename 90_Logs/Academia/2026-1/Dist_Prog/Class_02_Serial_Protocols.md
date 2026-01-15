---
tags:
  - university
  - semester_8
course: Applied Distributive Programming
professor: Orato
date: 2026-01-09
status: raw
---
# 📝 Class: [[Class 02 - Serial Protocols and Buffer Control]]

## 🎯 Main Goal of Today
Understanding Flow Control (XON/XOFF) and Serial Communication through software simulation (Hercules/RealTerm/CuteCom) and modeling (Petri Nets).

## 📓 Live Lecture Notes
- **Software Setup:** 
	- RealTerm (Windows) / CuteCom (Fedora) speed set to **9600 baud**.
    - **CR (Carriage Return)** and **LF (Line Feed)** must be appended to messages.
    - Display mode: **Hexispace** (viewing raw hex values with spaces).
- **Flow Control (XON/XOFF):** 
	- A software-based protocol to prevent "Buffer Overflow."
    - **XON (Transmit On):** Sent when the buffer has space.
    - **XOFF (Transmit Off):** Sent when the buffer is nearly full (e.g., 80%).
- **Encoding (ASCII Table):**
    - Used to translate binary/hex into human-readable characters.
    - **Platform Differences:** Windows typically uses `\r\n` (0D 0A) for new lines; Linux uses `\n` (0A).

- **Warning/Tip:** The Petri Net model for XON/XOFF flow control is high probability for the exam.

## 📂 Follow-up Tasks
- [x] Create Atomic Note: [[XON-XOFF Protocol]]
- [x] Create Atomic Note: [[ASCII Table]]
- [x] Refactor Python Code: [[PySerial Implementation]]
- [ ] Practice Project: "Accident & Emergency Unit" with RabbitMQ.