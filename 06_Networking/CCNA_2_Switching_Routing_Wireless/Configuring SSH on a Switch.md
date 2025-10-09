---
tags:
  - concept
  - networking
  - security
  - configuration
  - lab
  - Cisco_IOS
  - command
category: <cs-fundamental>
status:
  - learning
related: "[[Telnet vs SSH]]"
date: 2025-09-29
---

# Configuring SSH on a Switch

## 📝 One-Sentence Summary
*Configuring SSH on a Cisco switch is a multi-step process that involves setting a domain name, generating [[RSA Keys]], creating local user accounts, and configuring the [[VTY Lines]] to accept only secure connections.
## 💡 Analogy
Setting up SSH is like installing a high-security door for your office. You must first establish a unique building address (`domain-name`), create a one-of-a-kind key and lock (`RSA Keys`), register authorized employees with badges (`username/password`), and finally, set the door's entry system to only accept these secure badges (`transport input ssh`).*

## 🔑 Key Details
- **What it is:** 
	- The standard procedure for enabling secure, encrypted remote access to a Cisco device. 
- **Why it exists:** 
	- To replace the insecure, plaintext communication of Telnet, protecting credentials and configuration data from being intercepted.
## 🔗 Connections & Implementations
*This process leverages several key concepts, including [[Telnet vs SSH]], [[RSA Keys]], and [[VTY Lines]].
### Configuration Steps 
1. **Configure Hostname and Domain Name:** 
 ```
 cisco S1(config)# hostname S1 
 S1(config)# ip domain-name cisco.com 
 ``` 
 2. **Generate RSA Keys:** (This enables the SSH server) 
 ```cisco 
 S1(config)# crypto key generate rsa 
 How many bits in the modulus [512]: 1024 
 ``` 
 3. **Create a Local User Account:**
 ``` cisco 
 S1(config)# username admin secret ccna 
 ``` 
 4. **Configure VTY Lines for SSH:** 
``` cisco 
S1(config)# line vty 0 15 
S1(config-line)# transport input ssh 
S1(config-line)# login local 
``` 
5. **(Optional but Recommended) Enforce SSH Version 2:** 
``` cisco 
S1(config)# ip ssh version 2 
``` 
6. **Verification:** 
``` cisco 
S1# show ip ssh 
```

## See Also
- [[Telnet vs SSH]] 
- [[RSA Keys]] 
- [[VTY Lines]]