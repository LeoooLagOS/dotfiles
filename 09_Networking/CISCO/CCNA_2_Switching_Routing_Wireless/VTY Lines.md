---
tags:
  - concept
  - networking
  - configuration
category: networking
status:
  - learning
related: "[[Telnet vs SSH]]"
date: 2025-09-29
---

# VTY Lines

## 📝 One-Sentence Summary
*VTY (Virtual Teletype) lines are virtual, software-based ports on a Cisco device that allow for remote management access using protocols like [[Telnet vs SSH]].
## 💡 Analogy
Think of VTY lines as the **telephone lines** into a company's call center. There isn't a separate physical phone for each operator, but there are multiple logical lines allowing several customers (network administrators) to connect simultaneously.
## 🔑 Key Details

-   **What they are:** Logical access ports used for inbound connections to a device's command-line interface. They are not physical interfaces.
-   **Why they exist:** To allow administrators to manage a device remotely without needing a direct physical console connection.
-   **Configuration:** VTY lines are configured to control remote access by:
    -   Specifying which protocols are allowed (`transport input`).
    -   Defining the authentication method (`login`).

## 🔗 Connections & Implementations
*The configuration of VTY lines is a critical part of [[Configuring SSH on a Switch]].
* **Securing VTY Lines for SSH:**
```cisco
Switch(config)# line vty 0 15
! Allow only SSH connections
Switch(config-line)# transport input ssh
! Use the local username database for authentication
Switch(config-line)# login local
````

## See Also

- [[Configuring SSH on a Switch]]
    
- [[Telnet vs SSH]]