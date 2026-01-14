---
tags:
  - algorithm-pattern
  - python
  - protocol
difficulty: medium
status: learning
related: "[[XON-XOFF Protocol]]"
date: 2026-01-14
---
# Stop and Wait Protocol (Python)

## 🧠 Problem Summary
Implement a communication flow where the sender transmits one frame and must receive an acknowledgement (or XON) before sending the next.

## 💻 Code Implementation (Python)
```python
import serial
import time

def stop_and_wait_send(ser, data_list):
    for item in data_list:
        print(f"[SENDING] {item}")
        ser.write(f"{item}\n".encode())
        
        # Stop and Wait Logic
        waiting_for_ack = True
        while waiting_for_ack:
            if ser.in_waiting > 0:
                response = ser.readline().decode().strip()
                if response == "ACK" or response == "XON":
                    print("[RECEIVED] Acknowledgement. Moving to next...")
                    waiting_for_ack = False
            time.sleep(0.1)
```
## 📊 Complexity Analysis

- **Time:** O(n×latency) where n is number of packets.
    
- **Space:** O(1) as we only handle one packet at a time.