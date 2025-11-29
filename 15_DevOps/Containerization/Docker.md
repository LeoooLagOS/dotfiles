---
tags:
  - concept
  - devops
  - containers
  - tool
category: dev-ops
status:
  - learning
related: "[[IaC]]"
date: 2025-11-29
---
# Docker

## 📝 One-Sentence Summary
Docker is an open-source platform that uses [[OS Virtualization|OS-level virtualization]] to deliver software in packages called containers, ensuring an application runs exactly the same way in any environment.

## 💡 Analogy
Docker is like a **standardized shipping container**. 
Before shipping containers, goods (software) were loaded haphazardly onto ships (servers). Sacks of flour might get wet; pianos might break.
With Docker, everything is packed into a sealed, standard box. The ship (the OS) doesn't care what's inside (web app, database, script); it just knows how to stack and carry the box. The content arrives exactly as it was packed.

## 🔑 Key Details
-   **What it is:** 
	- A tool for building, running, and managing containers.
-   **Why it exists:** 
	- To solve the "It works on my machine" problem. It bundles the code, runtime, libraries, and settings into a single **Image**.
-   **Core Concepts:**
    -   **Image:** The read-only blueprint or template (the "class").
    -   **Container:** The runnable instance of an image (the "object").
    -   **Immutability:** Once an image is built, it doesn't change. If you need to update the app, you build a new image.

## 🔗 Connections & Implementations
-   Docker is a primary tool for implementing [[IaC]].
-   **The `/dev/null` Trick:** To keep a container running indefinitely (especially for testing), you might see a command like `tail -f /dev/null`. This gives the container a process that never finishes, preventing it from exiting immediately.

## 👍 Pros & 👎 Cons
-   **✅ Pros:** Consistency across environments (Dev, Test, Prod), lightweight (uses shared OS kernel), fast startup.
-   **❌ Cons:** Security complexity (shared kernel), networking can be tricky to debug.

## See Also
-   [[_Virtualization]]
-   [[_Operating Systems]]