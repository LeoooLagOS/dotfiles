---
tags:
  - lab
  - networking
  - configuration
  - command
  - Cisco_IOS
category: networking
status:
  - reviewing
related: "[[Autonegotiaton]]"
date: 2025-09-28
---

# Lab - Configure Port Autonegotiation

## 📝 One-Sentence Summary
*This lab provides the specific [[Cisco IOS]] commands to enable and verify the automatic negotiation of speed, duplex, and MDIX on a switch port.

## 💡 Analogy
*This is the instruction manual for setting your car's transmission back to **automatic**. You are telling the port to figure out the best settings on its own by communicating with whatever device is connected to it.

## 🔑 Key Details
- **What it is:** 
	- A practical exercise to configure a switch port to use its default autonegotiation capabilities. 
- **Why it exists:** 
	- To provide a hands-on example of the commands used to enab0le [[Autonegotiaton]], [[Duplex Communication]], and [[Auto-MDIX]] on an interface, and to demonstrate how to save the configuration.

## 🔗 Connections & Implementations

*This is the practical implementation of the concepts described in [[Autonegotiation]], [[Configuring Switch Port Speed and Duplex]], and [[Auto-MDIX]].

### Command Sequence

#### 1. Enter Configuration Mode
```cisco
S1# configure terminal
S1(config)# interface FastEthernet0/1
````

#### 2. Set Port to Autonegotiate

These commands instruct the port to automatically determine the best settings for operation.

``` cisco
S1(config-if)# duplex auto
S1(config-if)# speed auto
S1(config-if)# mdix auto
```

#### 3. Save the Configuration

The `end` command returns to privileged EXEC mode. The `copy running-config startup-config` command saves the changes from RAM to NVRAM, making them permanent.

``` Cisco 
S1(config-if)# end
S1# copy running-config startup-config
```

## See Also

- [[Autonegotiaton]]
    
- [[Configuring Switch Port Speed and Duplex]]
    
- [[Auto-MDIX]]
    
- [[Running-Config vs Startup-Config]]