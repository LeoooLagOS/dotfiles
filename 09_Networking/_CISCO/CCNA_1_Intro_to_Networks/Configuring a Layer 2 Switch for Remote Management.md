---
tags:
  - concept
  - networking
  - configuration
  - procedure
  - Cisco_IOS
  - ccna
  - command
category: networking
status:
  - learning
related: "[[Switch Management Interface (SVI)]]"
date: 2025-10-08
---

# Configuring a Layer 2 Switch for Remote Management

## 📝 One-Sentence Summary
*To manage a Layer 2 switch remotely, you must create a [[Switch Management Interface (SVI)]], assign it an IP address, and configure a default gateway so it can be reached from other networks.*
## 💡 Analogy
*This is like giving the **building's main security office** its own unique mailing address (`ip address`) and telling the office mailroom where the local post office is (`ip default-gateway`). Without both, the security office can't send or receive mail from outside its own building.*

## 🔑 Key Details
- **What it is:** 
	- A two-part process to make a Layer 2 switch accessible on an IP network. 
- **Why it exists:** 
	- By default, Layer 2 switches do not participate in IP routing. This configuration gives the switch's management plane an IP address so that administrators can connect to it via [[Telnet vs. SSH|SSH or Telnet]].

## 🔗 Connections & Implementations
*These commands enable in-band management, allowing you to configure the switch without a physical console connection.
### Command Sequence
1. **Configure the SVI (Switch Virtual Interface):** 
	* A virtual interface is created for a management [[VLAN]] (often VLAN 1 by default). 
	* It must be given an IP address and activated with `no shutdown`. 
```cisco 
Switch(config)# interface vlan 1 
Switch(config-if)# ip address 192.168.1.157 255.255.255.240 
Switch(config-if)# no shutdown 
Switch(config-if)# exit 
``` 
2. **Configure the Default Gateway:** 
	* The default gateway is the IP address of a router on the same network. 
	* This tells the switch where to send traffic destined for a different network (like an administrator's PC in another subnet). 
```cisco 
Switch(config)# ip default-gateway 192.168.1.158
 ``` 

## See Also 
 - [[Switch Management Interface (SVI)]] 
 - [[Default Gateway on a Switch]] 
 - [[VLAN]]