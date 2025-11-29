---
tags:
  - concept
  - devops
  - sre
  - business
category: devops
status: learning
related: "[[Site Reliability Engineering (SRE)]]"
date: 2025-11-29
---
# Service Level Agreement (SLA)

## 📝 One-Sentence Summary
An SLA is a formal commitment between a service provider and a client that defines the expected level of service, specifically regarding uptime and availability.

## 💡 Analogy
An SLA is like a **warranty on a car**. The manufacturer guarantees it will run 99% of the time. If it breaks down more than that, they owe you money or a refund.

## 🔑 Key Details
-   **The "Nines":** Availability is measured in percentages.
    -   **100%:** Impossible in reality.
    -   **99.95% (Google Standard):** Allows for about 21 minutes of downtime per month.
-   **Downgrade / Downtime:** The time the service is unavailable.
    -   **Reasons:** System updates, expanding resources (adding RAM/Storage), hardware failures (NAS/RAID issues), or accidents.
    -   **Error Budget:** **[[SRE]]s** use the gap between 100% and the SLA (e.g., the 0.05%) as a budget to perform maintenance or push risky updates.

## 🔗 Connections & Implementations
-   SREs are responsible for monitoring metrics to ensure the SLA is met.
-   Redundancy (like **[[Scalability (Vertical vs Horizontal)|Horizontal Scaling]]**) is used to maintain high SLAs even when individual servers fail.

## See Also
-   [[SRE]]