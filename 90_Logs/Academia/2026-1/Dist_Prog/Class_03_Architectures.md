---
tags:
  - university
  - semester_8
course: Applied Distributed Programming
professor: Orato
date: 2026-01-14
status: refined
---

# 📝 Class: [[Class 03 - Distributed Architectures and Flow Simulation]]

## 🎯 Main Goal of Today
Understanding Distributed System Architectures through formal modeling (PIPE 4.3) and wireless serial analysis (BLE).

## 📓 Live Lecture Notes
- **Modeling & Analysis:**
    - **PIPE 4.3:** Primary tool for analyzing behavioral properties (liveness, deadlocks) of distributed models.
    - Workflow: Design model -> Input to PIPE -> Analyze Petri Net behavior.
- **Wireless Serial (BLE):**
    - Installation on Linux (Fedora) is mandatory.
    - **ble-serial:** Used for virtualizing the serial port over Bluetooth.
    - **ble-start:** Used specifically for signal analysis (decibel monitoring).
- **Flow Control Mechanics:**
    - Focus on **XON/XOFF** integration with **Stop & Wait** protocols.

## 🛠️ Code Snippets / Whiteboard Sketches
- Concept: Combining Serial communication with Software Flow Control (XON/XOFF).
- Protocol: Stop & Wait logic (Send packet -> Wait for ACK/XON -> Repeat).

## 📂 Follow-up Tasks
- [x] Create Atomic Note: [[Distributed System Architectures]]
- [x] Create Atomic Note: [[Stop and Wait Python | Stop and Wait Protocol (Pyhton)]]
- [ ] Refactor Python Code: ][[Python XON-XOFF Implementation]]
- [x] [[Distributed_Systems_Vocab]]: German translations for "Architecture" (*Architektur*) and "Behavior" (*Verhalten*).