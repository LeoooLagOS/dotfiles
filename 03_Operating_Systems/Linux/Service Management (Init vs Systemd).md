---
tags:
  - legacy
  - services
  - sysadmin
  - linux
  - concept
category: os
status: learning
related: "[[Linux Boot Process]]"
date: 2025-11-23
---
# Service Management (Init vs Systemd)
## 📝 One-Sentence Summary
*A comparison of the legacy SysV-style `init.d` (which uses sequential shell scripts) and the modern `systemd` (which uses parallel execution and declarative unit files) to manage background services.*
## 💡 Analogy
* **Init.d (SysV):** Like a **Relay Race**. The runner (service) A must hand the baton to runner B before runner B can start. If runner A trips, the whole race stops or hangs. It's simple but slow.
* **Systemd:** Like a **Formula 1 Pit Crew**. Everyone (network, storage, GUI) jumps over the wall at the same time. They work in parallel based on dependencies ("I can't put the tire on until the car is lifted"). It's complex but incredibly fast.
## 🔑 Key Details
### 1. Legacy: Init.d (SysV Init)
- **Mechanism:** Uses directories containing shell scripts (`/etc/init.d/`).
- **Behavior:** Serial (Sequential) execution.
- **Syntax:** `/etc/init.d/<service_name> <option>`
    - `start`, `stop`, `restart`, `reload`, `force-reload`
- **Pros/Cons:** Simple to read (just bash scripts), but slow boot times and hard to manage dependencies.

### 2. Modern: Systemd
- **Mechanism:** A suite of tools (`systemd`, `journald`, `logind`) using declarative `.ini` style config files.
- **Behavior:** Parallel execution with dependency tracking.
- **Key Feature:** Uses **Targets** (`.target`) instead of strictly numbered runlevels.
## 🔗 Connections & Implementations
* **Compatibility:** Most `systemd` systems still respect old `init.d` scripts for backward compatibility, but they wrap them in systemd units generated at runtime.
## See Also
- [[Systemd Architecture]]
- [[Runlevels]]