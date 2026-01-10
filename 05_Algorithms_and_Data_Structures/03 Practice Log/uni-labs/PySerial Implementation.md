---
tags:
  - algorithm-pattern
  - python
  - serial
difficulty: medium
source: University Lab 2
status: learning
related: "[[Flow Control]]"
date: 2026-01-09
---
# PySerial Implementation (Buffer & Flow Control)

## 🧠 Problem Summary
Implement a Python script that monitors a serial port and correctly handles the "Full Buffer" state using software flow control.

## 📋 Constraints & Edge Cases
- **Speed:** 9600 baud.
- **Port:** COM1 (Windows) or /dev/ttyS0 (Fedora).
- **Encoding:** ASCII with CRLF (Windows) or LF (Linux).

## 💡 Key Data Structure / Concept
- **Buffer Management:** Using `in_waiting` to check how many bytes are ready to be read.

## 💻 Code Implementation (Python)
```python
import serial
import time

# Fedora configuration
ser = serial.Serial(
    port='/dev/ttyS0', 
    baudrate=9600,
    xonxoff=True,  # Mandatory for Class 2 Goal
    timeout=1
)

def run_serial_node():
    try:
        while True:
            if ser.in_waiting > 0:
                # Read data and decode from ASCII
                line = ser.readline().decode('ascii').strip()
                print(f"[RECV] {line}")
                
                # Logic for "Accident & Emergency" (Simulated)
                if "EMERGENCY" in line:
                    ser.write(b"AMBULANCE_DISPATCHED\n")
            
            time.sleep(0.1) # Prevent CPU pegging
    except KeyboardInterrupt:
        ser.close()

if __name__ == "__main__":
    run_serial_node()
```

## 🔧 Code Breakdown

- `xonxoff=True`: Enables the automatic sending of XOFF when the internal buffer is nearly full.
    
- `.decode('ascii')`: Translates the incoming hex bytes back into human-readable text.