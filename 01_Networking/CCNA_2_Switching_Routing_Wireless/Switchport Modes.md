---
tags:
  - concept
  - networking
  - configuration
category: networking
status:
  - learning
related: "[[Dynamic Trunking Protocol (DTP)]]"
date: 2025-09-20
---

# Switchport Modes

## 📝 One-Sentence Summary
*Switchport modes are configuration settings that define the behavior of a switch port, determining whether it functions as a simple [[Access Port]] for a single VLAN or as a [[Trunk Port]] for multiple VLANs, and how it negotiates that status.
## 💡 Analogy
*Think of it as assigning a specific job to an employee (the port). You can give them a permanent, fixed role—"You only handle customer service calls" (`access`) or "You only sort inter-departmental mail" (`trunk`). Or, you can tell them to figure out their role based on who they talk to (`dynamic auto` or `dynamic desirable`).
## 🔑 Key Details
- **What it is:** A set of interface configuration options that control the trunking behavior of a port. 
- **Why it exists:** To give a network administrator precise control over the function of each physical port on a switch. 
- **The Modes:** 
	- `access`: 
		- Puts the port into permanent non-trunking mode. It will only ever be a member of one [[VLAN]]. 
	- `dynamic auto`: 
		- A passive mode. The port is willing to become a trunk *if* the neighboring port actively asks it to (by being in `trunk` or `dynamic desirable` mode). **This is the default mode on many switches.** 
	- `dynamic desirable`: 
		- An active mode. The port actively attempts to form a trunk with its neighbor. It will become a trunk if the neighbor is set to `trunk`, `dynamic desirable`, or `dynamic auto`. 
	- `trunk`: 
		- Puts the port into permanent trunking mode.
## 🔗 Connections & Implementations
*This section is for **links only**. How does this atomic idea connect to practical code?*
-   Implemented in [[Python]] as: `[[Python - Dictionaries]]`
-   Implemented in [[_Java]] as: `[[Java - HashMap]]`
-   Used to solve: `[[Two Sum (Python)]]`, `[[Two Sum (Java)]]`

## 👍 Pros & 👎 Cons
*The trade-offs associated with **this specific concept**.*
-   **Advantages:**
    -   *e.g., Fast O(1) lookups.*
-   **Disadvantages:**
    -   *e.g., Unordered, uses more memory.*

## See Also
-   `[[<Parent Concept>]]`
-   `[[<A related concept often confused with this one>]]`