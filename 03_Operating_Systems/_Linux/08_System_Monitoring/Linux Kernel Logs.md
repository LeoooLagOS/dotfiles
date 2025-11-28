---
tags:
  - kernel
  - troubleshooting
  - linux
  - monitoring
  - tool
category: os
status: learning
related: "[[Linux Boot Process]]"
date: 2025-11-26
---
# Kernel Logs (dmesg)
## 📝 One-Sentence Summary
*`dmesg` (Display Message) is a command that prints the message buffer of the kernel, primarily used to troubleshoot hardware detection and driver initialization during boot.*
## 💡 Analogy
* **dmesg** is the **Flight Recorder (Black Box)**. It records the pilot's (Kernel's) comments from the moment the engines start. "Engine 1 checked. Flaps OK. Landing gear stuck."
## 🔑 Key Details
- **The Ring Buffer:** The kernel logs to a fixed-size buffer in memory. Old messages eventually get overwritten by new ones.
- **Use Cases:**
    1.  **Boot Issues:** Why didn't the WiFi start?
    2.  **Hardware Insertion:** What device name did the OS give my new USB drive? (`/dev/sdb`?)
    3.  **Crashes:** Did a Segfault occur?
- **Filtering:** `dmesg | grep -i usb` or `dmesg | grep -i error`.
## See Also
- [[Linux Boot Process]]
- [[Kernel]]
- [[Linux Kernel]]