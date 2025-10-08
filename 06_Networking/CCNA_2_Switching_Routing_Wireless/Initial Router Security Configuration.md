---
tags:
  - concept
  - networking
  - security
  - configuration
  - router
  - command
category: networking
status:
  - learning
related: "[[Initial Switch Security Configuration]]"
date: 2025-10-06
---

# Initial Router Security Configuration

## 📝 One-Sentence Summary
*This is the foundational set of commands applied to a new router to establish a baseline of security and manageability, including setting a hostname, creating passwords, and displaying a legal banner.*
## 💡 Analogy
*Think of this as **changing the locks and setting up the security system** for a new building. You're replacing the generic factory keys with unique ones, adding a password to the main security panel, and putting a "No Trespassing" sign on the front lawn before you allow any traffic.*
## 🔑 Key Details
- **What it is:** 
	- A standard operating procedure for hardening a Cisco router before it is deployed on a network. 
- **Why it exists:** 
	- To protect the device from unauthorized access and to create a professional and manageable configuration environment. These steps are nearly identical to the [[Initial Switch Security Configuration]] but are applied to a Layer 3 device.
## 🔗 Connections & Implementations
*This procedure is one of the first tasks performed after accessing a new router's command line.*
### Command Sequence
```cisco
Router(config)# hostname R1
R1(config)# enable secret class
R1(config)# line console 0
R1(config-line)# password cisco
R1(config-line)# login
R1(config-line)# exit
R1(config)# line vty 0 4
R1(config-line)# password cisco
R1(config-line)# login
R1(config-line)# exit
R1(config)# service password-encryption
R1(config)# banner motd #Authorized Access Only!#
R1(config)# end
R1# copy running-config startup-config
````

## See Also

- [[Initial Switch Security Configuration]]
    
- [[Configuring Router Interfaces]]
    
- [[Cisco IOS Modes]]