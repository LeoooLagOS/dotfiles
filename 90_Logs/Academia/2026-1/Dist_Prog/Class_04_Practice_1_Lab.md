---
tags:
  - university
  - semester_8
  - lab
course: Applied Distributed Programming
professor: Orato
date: 2026-01-16
status: active
---
# 🧪 Practice 1: Serial Communication & Protocol Development

## 🎯 Main Goal of Today
Implementing and validating **XON-XOFF** and **Stop & Wait** protocols using Python, commercial terminals, and Petri Net modeling.

## 📓 Live Lecture Notes / Objectives
- **Channel Establishment:**
    - **Windows:** Use **VSPE** to create virtual COM pairs.
    - **Fedora:** Use `socat` or `ble-serial` for native port emulation.
- **Protocol Requirements:**
    - **Baud:** 9600 | **Parity:** None | **Stop Bits:** 1 | **Flow Control:** None (HW).
- **Python Integration:** Use `pyserial` to replace one end of the communication.
- **Analysis:** Use **PIPE IV.3** to verify Reachability, Safety, and Liveness.

## 🛠️ Step-by-Step Execution Plan
1. **Virtual Link:** Create a Pair (COM1 <-> COM2) in VSPE.
2. **Standard Test:** Send a file between **Realterm** and **Hercules**.
3. **Python Bridge:** Replace Hercules with a Python script and receive data.
4. **XON-XOFF:** Test with a large file in Realterm;Python must send XOFF when the buffer hits the threshold.
5. **Stop & Wait:** Two Python modules (TX/RX) exchanging data with disk logging.
6. **Petri Nets:** Model both protocols and extract the properties report.

## 📂 Follow-up Tasks
- [ ] Create Atomic Note: [[Stop and Wait Protocol]]
- [ ] Create Atomic Note: [[XON-XOFF Logic]]
- [ ] Refactor Code: `[[uni-labs/Practice 1 Implementation]]`