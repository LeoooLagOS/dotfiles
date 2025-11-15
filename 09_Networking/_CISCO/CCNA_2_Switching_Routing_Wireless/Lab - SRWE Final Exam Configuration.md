---
tags:
  - lab
  - networking
  - configuration
  - security
  - vlan
  - routing
  - hsrp
category: networking
status:
  - <mastered>
related: "[[Router-on-a-stick]]"
date: 2025-11-12
---
# Lab - Advanced Multi-Router and Switch Configuration

## 📝 One-Sentence Summary
*A comprehensive lab guide for configuring a complex multi-device topology, implementing advanced switching (VLANs, Port-channels, Port Security), multi-router routing (Static, Floating, HSRP), and dual-stack (IPv4/IPv6) services.

## 🎯 Lab Objectives
* **VLANs & Port Assignment:** 
	* Create VLANs 10, 20, 30, and 99 on all switches and assign specified ports.
* **Spanning Tree:** 
	* Configure S2 as the root bridge for all VLANs.
* **[[EtherChannel]]:** 
	* Configure [[EtherChannel Negotiation Protocols (LACP vs PAgP)|LACP and PAgP Port-channels]] between switches.
* **Port Security:** 
	* Secure S1 ports with static, sticky, and dynamic limits, plus different violation modes.
* **Inter-VLAN Routing:** 
	* Implement [[Router-on-a-stick]] on R1 for all VLANs.
* **[[DHCPv4]]:** 
	* Configure R1 as a DHCP server for VLAN 10.
* **[[DHCPv6]]:** 
	* Configure R1 for [[SLAAC]] on VLAN 10 and stateful DHCPv6 on VLAN 20.
* **IPv4 Routing:** 
	* Implement a mix of [[Static Routing|static]], [[Default Route|default]], and floating static routes.
* **IPv6 Routing:** 
	* Implement static and default IPv6 routes.
* **First Hop Redundancy:** 
	* Configure [[HSRP]] on R3 and R4 to provide a redundant gateway.

---
## Switch S1 Configuration

This section details the configuration for **S1**.

###  1. Basic Setup and VLANs
This follows [[Initial Device Security Configuration]] and [[VLAN Configuration]].
**Goals:**
* Hostname: `S1`
* Create VLANs: 10, 20, 30, 99
* Assign Ports: f0/5-10 (VLAN 10), f0/11-15 (VLAN 20), f0/16-20 (VLAN 30), f0/21-23 (VLAN 99)
```cisco
! --- Configuración Básica y VLANs ---
hostname S1
enable secret class
no ip domain-lookup
service password-encryption
banner motd #Acceso no autorizado sera castigado#

vlan 10
 name estudiantes
vlan 20
 name profesores
vlan 30
 name nativa
vlan 99
 name administrativa
exit

interface range f0/5 - 10
 switchport mode access
 switchport access vlan 10
exit
interface range f0/11 - 15
 switchport mode access
 switchport access vlan 20
exit
interface range f0/16 - 20
 switchport mode access
 switchport access vlan 30
exit
interface range f0/21 - 23
 switchport mode access
 switchport access vlan 99
exit
````

###  2. Port-Channel Configuration

This uses [[EtherChannel]] to bundle links. See [[EtherChannel Negotiation Protocols (LACP vs PAgP)]]. 

**Goals:**
- `Po1` (g0/1-2) to S2 using PAgP `desirable`.
    
- `Po3` (f0/1-2) to S3 using LACP `passive`.

``` Cisco CLI
! --- Configuración de Port-channels ---
! Po1 (PAgP) a S2
interface range g0/1 - 2
 switchport mode trunk
 channel-group 1 mode desirable
 no shutdown
exit
! Po3 (LACP) a S3
interface range f0/1 - 2
 switchport mode trunk
 channel-group 3 mode passive
 no shutdown
exit
```

###  3. Port Security

This section implements [[Port Security]] with specific [[Port Security MAC Address Modes]] and [[Port Security Violation Modes]].
**Goals:**
- `f0/6`: Max 1 host, static MAC, `shutdown` violation.
    
- `f0/12`: Max 1 host, dynamic MAC, `restrict` violation.
    
- `f0/18`: Max 1 host, sticky MAC, `protect` violation.

```Cisco CLI
! --- Configuración de Port Security ---
interface f0/6
 switchport mode access
 switchport port-security
 switchport port-security maximum 1
 switchport port-security mac-address aaaa.bbbb.cccc
 switchport port-security violation shutdown
exit

interface f0/12
 switchport mode access
 switchport port-security
 switchport port-security maximum 1
 switchport port-security violation restrict
exit

interface f0/18
 switchport mode access
 switchport port-security
 switchport port-security maximum 1
 switchport port-security mac-address sticky
 switchport port-security violation protect
exit
```

###  4. SVI and Save
See [[Configuring a Layer 2 Switch for Remote Management]]. 
**Goal:** SVI 99 to receive an IP via DHCP.
```Cisco CLI
! --- Configuración SVI (DHCP) ---
interface vlan 99
 ip address dhcp
 no shutdown
exit

end
copy running-config startup-config
```

---

## Switch S2 Configuration

This section details the configuration for **S2**.
###  1. Basic Setup and Spanning Tree

This follows [[Initial Device Security Configuration]].
**Goals:**
- Hostname: `S2`
    
- Set S2 as the [[Root Bridge]] for all VLANs.
```Cisco CLI
! --- Configuración Básica ---
hostname S2
enable secret class
no ip domain-lookup
service password-encryption
banner motd "Acceso no autorizado sera castigado"

! --- Configuración de Spanning-Tree (Puente Raíz) ---
spanning-tree vlan 1-4094 priority 0
```

###  2. VLANs and Port Assignments
See [[VLAN Configuration]].
**Goals:** Create and assign ports for VLANs 10, 20, 30, 99.
```Cisco CLI
! --- Creación de VLANs y Asignación de Puertos ---
vlan 10
 name estudiantes
vlan 20
 name profesores
vlan 30
 name nativa
vlan 99
 name administrativa
exit

interface range f0/5 - 10
 switchport mode access
 switchport access vlan 10
exit
interface range f0/11 - 15
 switchport mode access
 switchport access vlan 20
exit
interface range f0/16 - 20
 switchport mode access
 switchport access vlan 30
exit
interface range f0/21 - 23
 switchport mode access
 switchport access vlan 99
exit
```

### 3. Port-Channels and Trunking
See [[EtherChannel Negotiation Protocols (LACP vs PAgP)]] and [[Trunk Port]]. 
**Goals:**
- `Po1` (g0/1-2) to S1 using PAgP `desirable`.
    
- `Po2` (f0/1-2) to S3 using LACP `active`.
    
- `f0/24` as a trunk to R1.
```Cisco CLI
! --- Configuración de Port-channels ---
! Po1 (PAgP) a S1
interface range g0/1 - 2
 switchport mode trunk
 channel-group 1 mode desirable
 no shutdown
exit
! Po2 (LACP) a S3
interface range f0/1 - 2
 switchport mode trunk
 channel-group 2 mode active
 no shutdown
exit

! --- Configuración de Enlace Troncal a R1 ---
interface f0/24
 switchport mode trunk
 no shutdown
exit
```
### 4. SVI and Save
See [[Configuring a Layer 2 Switch for Remote Management]].
```Cisco 
! --- Configuración SVI (DHCP) ---
interface vlan 99
 ip address dhcp
 no shutdown
exit

end
copy running-config startup-config
```

---

##  Switch S3 Configuration
This section details the configuration for **S3**.
```Cisco
! --- Configuración Básica y VLANs ---
hostname S3
enable secret class
no ip domain-lookup
service password-encryption
banner motd "Acceso no autorizado sera castigado"

vlan 10
 name estudiantes
vlan 20
 name profesores
vlan 30
 name nativa
vlan 99
 name administrativa
exit

! --- Asignación de Puertos a VLANs ---
interface range f0/5 - 10
 switchport mode access
 switchport access vlan 10
exit
interface range f0/11 - 15
 switchport mode access
 switchport access vlan 20
exit
interface range f0/16 - 20
 switchport mode access
 switchport access vlan 30
exit
interface range f0/21 - 23
 switchport mode access
 switchport access vlan 99
exit
```

**Goals:**

- `Po3` (f0/3-4) to S1 using LACP `active`.
    
- `Po2` (f0/1-2) to S2 using LACP `active`.
```Cisco
! --- Configuración de Port-channels ---
! Po3 (LACP) a S1
interface range f0/3 - 4
 switchport mode trunk
 channel-group 3 mode active
 no shutdown
exit
! Po2 (LACP) a S2
interface range f0/1 - 2
 switchport mode trunk
 channel-group 2 mode active
 no shutdown
exit

! --- Configuración SVI (DHCP) ---
interface vlan 99
 ip address dhcp
 no shutdown
exit

end
copy running-config startup-config
```

---
## Router R1 Configuration

This section details the configuration for **R1**.

###  1. Basic Setup and DHCP

See [[Initial Router Security Configuration]], [[Enabling IPv6 Routing]], and [[Configuring a Cisco IOS DHCPv4 Server]].
**Goals:**
- Configure R1 as a DHCPv4 server for `vlan10`.
    
- Configure R1 as a stateful DHCPv6 server (`IPV6-STATEFUL`).
```Cisco
! --- Configuración Básica ---
hostname R1
enable secret class
no ip domain-lookup
service password-encryption
banner motd "Acceso no autorizado sera castigado"
ipv6 unicast-routing

! --- Configuración DHCP IPv4 (VLAN 10) ---
ip dhcp excluded-address 192.168.1.30
ip dhcp pool vlan10
 network 192.168.1.0 255.255.255.224
 default-router 192.168.1.30
exit

! --- Configuración DHCP IPv6 (VLAN 20) ---
ipv6 dhcp pool IPV6-STATEFUL
 prefix-delegation 2001:db8:acad:1::/64
 dns-server 2001:4860:4860::8888
 domain-name cisco.com
exit
```

###  2. Interface Configuration

This implements [[Router-on-a-stick]], [[SLAAC]], and stateful [[DHCPv6 (Stateful)]].
**Goals:**

- Configure `GigabitEthernet0/0/0` (from S2) as the trunk.
    
- Configure Subinterfaces for VLANs 10, 20, 30, 99 using the last valid IP in each subnet.
    
- Configure `VLAN 10` for SLAAC and `VLAN 20` for stateful DHCPv6.
    
- Configure `g0/0/1` (to R5) and `s0/1/0` (to R2).
```Cisco
! --- Configuración Sub-interfaces (Router-on-a-Stick) ---
! Habilitar la interfaz física principal
interface GigabitEthernet0/0/0
 no shutdown
exit

! VLAN 10 (DHCP IPv4 + SLAAC IPv6)
interface GigabitEthernet0/0/0.10
 encapsulation dot1q 10
 ip address 192.168.1.30 255.255.255.224
 ipv6 address 2001:ABC:FCE:1::1/64
 ipv6 address fe80::1 link-local
 no shutdown
exit

! VLAN 20 (DHCPv6 Stateful)
interface GigabitEthernet0/0/0.20
 encapsulation dot1q 20
 ip address 192.168.1.62 255.255.255.224
 ipv6 address 2001:db8:acad:1::1/64
 ipv6 address fe80::2 link-local
 ipv6 nd managed-config-flag
 ipv6 dhcp server IPV6-STATEFUL
 no shutdown
exit

! VLAN 30 (Nativa)
interface GigabitEthernet0/0/0.30
 encapsulation dot1q 30 native
 ip address 192.168.1.94 255.255.255.224
 no shutdown
exit

! VLAN 99 (Administrativa)
interface GigabitEthernet0/0/0.99
 encapsulation dot1q 99
 ip address 192.168.1.126 255.255.255.224
 no shutdown
exit

! --- Interfaz a R5 ---
interface GigabitEthernet0/0/1
 ipv6 address 2001:2001:2001:1::1/64
 no shutdown
exit

! --- Interfaz Serial a R2 ---
interface Serial0/1/0
 ip address 10.10.10.1 255.255.255.252
 no shutdown
exit
```

###  3. Static Routing

**Goals:** Create [[Default Route|default routes]] for IPv4 (via R2) and IPv6 (via R5).
```Cisco
! --- Rutas Estáticas ---
ip route 0.0.0.0 0.0.0.0 10.10.10.2
ipv6 route ::/0 2001:2001:2001:1::2

end
copy running-config startup-config
```

---

## ## Router R2 Configuration

This section details the configuration for **R2**.
```Cisco
! --- Configuración Básica e Interfaces ---
hostname R2
enable secret class
no ip domain-lookup
service password-encryption
banner motd "Acceso no autorizado sera castigado"

interface Serial0/1/0
 description Enlace a R1
 ip address 10.10.10.2 255.255.255.252
 no shutdown
exit

interface GigabitEthernet0/0/0
 description Enlace a R3
 ip address 192.168.3.2 255.255.255.0
 no shutdown
exit

interface GigabitEthernet0/0/1
 description Enlace a R4
 ip address 192.168.4.2 255.255.255.0
 no shutdown
exit
```

This section configures [[Static Routing]] to reach all remote networks. **Goals:**

- Add static routes for all of R1's VLANs.
    
- Add a primary route to `192.168.2.0/24` via R3.
    
- Add a floating static route (AD of 4) to `192.168.2.0/24` via R4.
```Cisco
! --- Rutas Estáticas IPv4 ---
ip route 192.168.1.0 255.255.255.224 10.10.10.1
ip route 192.168.1.32 255.255.255.224 10.10.10.1
ip route 192.168.1.64 255.255.255.224 10.10.10.1
ip route 192.168.1.96 255.255.255.224 10.10.10.1

ip route 192.168.2.0 255.255.255.0 192.168.3.1
ip route 192.168.2.0 255.255.255.0 192.168.4.1 4

end
copy running-config startup-config
```

---

## ## Router R3 Configuration

This section details the configuration for **R3**.
```Cisco
! --- Configuración Básica e Interfaces ---
hostname R3
enable secret class
no ip domain-lookup
service password-encryption
banner motd "Acceso no autorizado sera castigado"

interface GigabitEthernet0/0/0
 description Enlace a R2
 ip address 192.168.3.1 255.255.255.0
 no shutdown
exit

interface GigabitEthernet0/0/1
 description Enlace a R4 y LAN
 ip address 192.168.2.1 255.255.255.0
 no shutdown
exit
```

This configures R3 as the Active router in an [[HSRP]] group. 
**Goals:**
- `standby version 2`, group `1`, virtual IP `192.168.2.254`.
    
- Set priority to `150` (active).
    
- Enable `preempt` to reclaim control.
```Cisco
! --- Configuración HSRP (Activo) ---
interface GigabitEthernet0/0/1
 standby version 2
 standby 1 ip 192.168.2.254
 standby 1 priority 150
 standby 1 preempt
exit
```

Configures a [[Default Route]] via R2.
```Cisco
! --- Ruta Estática por Defecto ---
ip route 0.0.0.0 0.0.0.0 192.168.3.2

end
copy running-config startup-config
```

---

## Router R4 Configuration

This section details the configuration for **R4**.
```Cisco
! --- Configuración Básica e Interfaces ---
hostname R4
enable secret class
no ip domain-lookup
service password-encryption
banner motd "Acceso no autorizado sera castigado"

interface GigabitEthernet0/0/0
 description Enlace a LAN
 ip address 192.168.2.2 255.255.255.0
 no shutdown
exit

interface GigabitEthernet0/0/1
 description Enlace a R2
 ip address 192.168.4.1 255.255.255.0
 no shutdown
exit
```

Configures R4 as the Standby router in the [[HSRP]] group. 
**Goal:** Join `standby group 1` with the shared virtual IP.
```Cisco
! --- Configuración HSRP (Standby) ---
interface GigabitEthernet0/0/0
 standby version 2
 standby 1 ip 192.168.2.254
exit
```

Configures a [[Default Route]] via R2.
```Cisco
! --- Ruta Estática por Defecto ---
ip route 0.0.0.0 0.0.0.0 192.168.4.2

end
copy running-config startup-config
```

---

## Router R5 Configuration

This section details the configuration for **R5**.
```Cisco
! --- Configuración Básica ---
hostname R5
enable secret class
no ip domain-lookup
service password-encryption
banner motd "Acceso no autorizado sera castigado"
ipv6 unicast-routing
```

See [[Configuring Router Interfaces]].
```Cisco
! --- Configuración de Interfaces ---
interface GigabitEthernet0/0/1
 description Enlace a R1
 ipv6 address 2001:2001:2001:1::2/64
 no shutdown
exit

interface GigabitEthernet0/0/0
 description Enlace a P1
 ipv6 address 2001:1:1:1::1/64
 no shutdown
exit
```

Configures [[Static Routing|Static Routes]] to reach R1's IPv6 networks. **Goal:** Add IPv6 static routes for R1's VLANs.
```Cisco
! --- Rutas Estáticas IPv6 ---
ipv6 route 2001:ABC:FCE:1::/64 2001:2001:2001:1::1
ipv6 route 2001:db8:acad:1::/64 2001:2001:2001:1::1

end
copy running-config startup-config
```