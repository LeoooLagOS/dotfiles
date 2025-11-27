---
tags:
  - virtualization
  - concept
  - hardware
  - emulation
category: os
status: learning
related: "[[Hypervisor]]"
date: 2025-11-27
---
# Hardware Virtualization
## 📝 One-Sentence Summary
*Hardware virtualization uses a hypervisor to simulate physical hardware, allowing an unmodified or slightly modified "Guest" Operating System to run in isolation.*
## 🔑 The Three Types
### 1. Paravirtualization
* **Concept:** "I know I am a simulation."
* **Mechanism:** The Guest OS is **modified** to communicate directly with the hypervisor (Hypercalls) instead of trying to talk to raw hardware.
* **Pros:** High performance (removes emulation overhead).
* **Cons:** Requires a modified OS (can't easily paravirtualize closed-source Windows).

### 2. Full Virtualization
* **Concept:** "I think I am real."
* **Mechanism:** The Guest OS is **unmodified**. The hypervisor uses **Binary Translation** to trap sensitive operations (I/O, status changes) and emulate the hardware response.
* **Pros:** Runs any OS.
* **Cons:** Slow (high emulation overhead).

### 3. Hardware-Assisted Virtualization
* **Concept:** "The CPU helps me lie."
* **Mechanism:** Uses physical CPU extensions (**Intel VT-x** or **AMD-V**) to handle the privileged instructions and memory access (ring transitions) directly in silicon.
* **Pros:** Near-native performance with unmodified Guest OS.
* **Examples:** Intel VT (Vanderpool), AMD-V (Pacifica).

## See Also
- [[Hypervisor]]
- [[OS Virtualization]]