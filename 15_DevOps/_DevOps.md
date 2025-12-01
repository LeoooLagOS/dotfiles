---
tags:
  - overview
  - concept
  - devops
category: software-engineering
status:
  - learning
related: "[[_Software Engineering]]"
date: 2025-12-01
---
# _DevOps_

## 📝 One-Sentence Summary

DevOps is a set of practices, tools, and cultural philosophies that automate and integrate the processes between software development and IT teams to shorten the systems development life cycle.

## 💡 Analogy

**The Formula 1 Pit Crew.** In traditional software approaches ([[Waterfall]]), developers drive the car, but when they need maintenance, they park it and walk away while mechanics work in isolation. In **DevOps**, the mechanics (Ops) and drivers (Devs) function as a single, synchronized unit. They communicate instantly, tools are prepared in advance (automation), and the goal is to keep the car (application) moving at maximum speed with minimal downtime.

## 📜 History & Creator

- **Origin:** The term was coined by **Patrick Debois** in 2009.
    
- **Context:** It emerged from the "[[Agile]]" software movement. While Agile solved inefficiencies in _development_, deployment was still a bottleneck.
    
- **Event:** The first "DevOpsDays" conference in Ghent (2009) marked the official birth of the movement.

## 🔑 Core Philosophy & Design

The core design is often summarized by the acronym **CALMS**:

1. **C**ulture: Shared responsibility between Dev and Ops.
    
2. **A**utomation: Removing manual toil from deployment and testing.
    
3. **L**ean: Minimizing waste and work-in-progress.
    
4. **M**easurement: Using data (metrics/logs) to make decisions.
    
5. **S**haring: Open communication loops.

## ⚙️ Key Details

- **What it is:** 
	- A methodology that bridges the gap between writing code and keeping it running in production.
    
- **Why it exists:** 
	- To eliminate the "It works on my machine" problem and reduce the friction of deployment, allowing for frequent, reliable releases.
    
- **Core Functions/Components:**
    
    - **[[CI/CD]] (Continuous Integration/Continuous Deployment):** Automating the merge and release process.
        
    - **[[IaC]] (Infrastructure as Code):** Managing hardware via configuration files.
        
    - **[[Monitoring & Logging]]:** Real-time visibility into system health.
![Imagen de DevOps infinity loop stages](https://encrypted-tbn1.gstatic.com/licensed-image?q=tbn:ANd9GcQok2Mgp01QPNeTMBTsTSwGUSI-ijAaSdUMYDmRHBoIdQs56fDsHN0QHQ6uptOONjH5Qpu2PmxtlVRAA4w1ShQEQmi_a2fGs_2JHyrTka_ht7hS39o)

## 🔗 Connections & Implementations

This topic connects the logic of software with the reality of hardware.

- It relies heavily on **[[_Operating Systems]]** (specifically [[_Linux]]) for execution environments.
    
- It utilizes **[[_Git]]** as the single source of truth for code and infrastructure.
    
- It is the foundation for modern **[[_Cybersecurity]]** practices ([[DevSecOps]]).
## See Also

- [[DevOps vs SysAdmin]]
    
- [[SRE]]
    
- [[Docker]]