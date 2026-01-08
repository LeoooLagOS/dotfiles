---
tags:
  - concept
  - protocol
  - networking
category: Distributed Systems
status: learning
related: "[[MIB]]"
date: 2026-01-07
---
# SNMP (Simple Network Management Protocol)

## 📝 One-Sentence Summary
An application-layer protocol used for managing and monitoring network devices like routers, switches, and servers on an IP network.

## 💡 Analogy
**The Doctor’s Check-up:** The network administrator (Manager) uses a stethoscope (SNMP) to check the "vitals" (CPU load, traffic, uptime) of the patient (Device). The patient has a chart (**MIB**) where all their health history is recorded.

## 🔑 Key Details
- **What it is:** The standard protocol for device management.
- **Why it exists:** To allow IT managers to monitor network performance, find and solve network problems, and plan for network growth.
- **Core Components:**
    - **Manager:** The central system used to monitor the network.
    - **Agent:** Software running on the managed device.
    - **MIB (Management Information Base):** A hierarchical database of device parameters.

## 🔗 Connections & Implementations
- Heavily used in **Networking Administration** and Cybersecurity monitoring.
- Data is often visualized in dashboards like Zabbix or Grafana.

## 👍 Pros & 👎 Cons
- **Pros:** Universal support across hardware vendors; very low overhead.
- **Cons:** Older versions (v1, v2c) have significant security vulnerabilities; v3 is required for encryption.

## See Also
- [[NTCIP]]
- [[Communication Models]]