---
tags:
  - lab
  - networking
  - configuration
  - security
  - router
  - switch
category: networking
status:
  - reviewing
related: "[[Initial Device Security Configuration]]"
date: 2025-10-09
---
# Lab - Foundational Device Configuration

## 📝 One-Sentence Summary
*A comprehensive lab guide containing the exact command sequences for the initial security hardening and interface configuration of a Cisco [[Router]] and [[Switch]], with granular links to the underlying concepts for each command.

## 💡 Analogy
*This note is like a master **blueprint or checklist** used by a network technician to set up new equipment according to standard operating procedures. Each step on the checklist now has a direct footnote linking back to the engineering principle that explains *why* it's done.
## Router Configuration (Building-1)

This section details the complete initial setup for a Cisco IOS router.

[[Initial Device Security Configuration]] for the basics.
```cisco
! --- Initial Hostname and Security ---
hostname Building-1
enable secret class12345
````
! See [[Device Hardening Best Practices]] for details on these commands.
```
banner motd $Authorized Access Only$
no ip domain-lookup
service password-encryption
! --- Advanced Hardening ---
security passwords min-length 10
login block-for 120 attempts 2 within 30
```
See [[Configuring SSH on a Switch]] for the full SSH Configuration procedure.
```
! --- SSH Configuration ---
```
! Prerequisite for [[RSA Keys]].
! Generates keys to enable SSH. See [[RSA Keys]].
```
ip domain-name google.com
crypto key generate rsa 
1024
! Creates a local user for authentication.
username netadmin privilege 15 secret Cisco_CCNA7

! --- Line Configuration ---
! Securing the physical console port.
line console 0
 password cisco12345
 login
 ```
 ! See [[Improving CLI Usability]] for these commands.
``` 
logging synchronous
 exec-timeout 60
 exit
```
! Securing the virtual remote access lines. See [[VTY Lines]].
```
line vty 0 4
password cisco12345
! This command restricts access to SSH only.
 transport input ssh
! This tells the line to use the local user database.
 login local
 ```
 ! See [[Improving CLI Usability]].
 ```
 logging synchronous
 exec-timeout 60
 exit

! Enforce the more secure SSH version 2.
ip ssh version 2
```

! For the 'Interface Configuration' see [[Configuring Router Interfaces]] for the standard procedure.
```
! --- Interface Configuration ---
interface g0/0
 description First Floor Switch
 ip address 192.168.1.126 255.255.255.224
 ipv6 address 2001:DB8:ACAD:A::1/64
 ```
 ! Manually setting the [[IPv6 Link-Local Address]].
 ```
 ipv6 address fe80::1 link-local
 no shutdown
 exit

interface g0/1
 description Second Floor Switch
 ip address 192.168.1.158 255.255.255.240
 ipv6 address 2001:DB8:ACAD:B::1/64
 ipv6 address fe80::1 link-local
 no shutdown
 exit
```
! --- IPv6 Routing ---
! See [[Enabling IPv6 Routing]].
```
ipv6 unicast-routing

! --- Save Configuration ---
```
! See [[Running-Config vs Startup-Config]].
```
copy running-config startup-config
````

---
## Switch Configuration

This section details the initial setup for a Layer 2 switch with a management interface.
! See [[Initial Device Security Configuration]] for The Initial Hostname and Security
``` cisco
! --- Initial Hostname and Security ---
hostname S2
enable secret class12345
banner motd $Administration Switch$
no ip domain-lookup
service password-encryption
```
! Securing the console and [[VTY Lines]]. See [[Improving CLI Usability]].
```
! --- Line Configuration ---
line console 0
 password cisco12345
 login
 logging synchronous
 exec-timeout 60
 exit

line vty 0 15
 password cisco12345
 login
 logging synchronous
 exec-timeout 60
 exit
```
!  For 'Remote Management Configuration' see [[Configuring a Layer 2 Switch for Remote Management]].
! This creates the [[Switch Management Interface (SVI)]].
```
! --- Remote Management Configuration ---
interface vlan 1
 ip address 192.168.1.157 255.255.255.240
 no shutdown
 exit
! This sets the [[Default Gateway on a Switch]].
ip default-gateway 192.168.1.158
```
! See [[Running-Config vs Startup-Config]].
```
! --- Save Configuration ---
copy running-config startup-config
```