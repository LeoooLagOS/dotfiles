---
tags:
  - concept
  - robotics
  - middleware
category: Distributed Systems
status: learning
related: "[[_Distributed Systems]]"
date: 2026-01-07
---
# ROS 2 (Robot Operating System 2)

## 📝 One-Sentence Summary
A set of software libraries and tools that provide a distributed framework for building robot applications using a node-based architecture.

## 💡 Analogy
**The Nervous System:** Each "Node" is like a sensory organ or a muscle. They all speak different "languages" (data types), but the ROS 2 middleware acts as the nerves that ensure the message from the "Eye" (Camera Node) gets to the "Leg" (Motor Node) instantly and reliably.

## 🔑 Key Details
- **What it is:** A collection of tools, libraries, and conventions that simplify the task of creating complex and robust robot behavior across a variety of robotic platforms.
- **Why it exists:** To provide a standard way for hardware-independent processes (Agents) to communicate, allowing for modularity and code reuse in robotics.
- **Core Components:**
    - **Nodes:** Single-purpose executable units.
    - **Topics:** Channels for continuous data streams (Publish/Subscribe).
    - **Services:** For synchronous Request/Response patterns.

## 🔗 Connections & Implementations
- Uses **[[DDS|DDS (Data Distribution Service)]]** as its underlying communication layer.
- Relates to the **N to N** communication model.

## 👍 Pros & 👎 Cons
- **Pros:** Massively scalable, huge community support, and works across multiple operating systems.
- **Cons:** High learning curve; debugging distributed nodes across a network can be complex.

## See Also
- [[_Distributed Systems]]
- [[Communication Models]]