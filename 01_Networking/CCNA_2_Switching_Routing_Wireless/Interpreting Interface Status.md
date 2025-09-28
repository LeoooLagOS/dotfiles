---
tags:
  - concept
  - networking
  - troubleshooting
  - command
category: networking
status:
  - learning
related: "[[Common Switch Verification Commands]]"
date: 2025-09-28
---

# Interpreting Interface Status

## 📝 One-Sentence Summary
*The status line in the `show interfaces` command output indicates the health of both the [[1_Physical Layer (OSI Model)|physical layer]] (Layer 1) and the [[2_Data Link Layer (OSI Model)|Data Link Layer]] (Layer 2), providing a quick and powerful diagnostic tool.

## 💡 Analogy
* Think of it as the two main indicator lights on a modem.
	* The first light, **`Interface is up`**, is like the "Physical Link" light—it just tells you a cable is properly plugged in and the device on the other end is powered on. 
	* The second light, **`line protocol is up`**, is like the "Internet" light—it tells you that you're successfully communicating and exchanging meaningful data with the equipment on the other side. You need both to be green to get online.

## 🔑 Key Details
- **What it is:** The first line of the `show interfaces` output, which reports the status in a `(physical status), line protocol is (data link status)` format. 
	- **First Status (Physical):** Refers to Layer 1. If it's **`up`**, the interface is receiving a carrier detect signal from the other end. 
	- **Second Status (Data Link):** Refers to Layer 2. If it's **`up`**, the interface is successfully sending and receiving data link layer keepalives. 
- **Why it exists:** To allow an administrator to quickly determine the operational state of a connection and narrow down the scope of a network problem.
## 🔗 Connections & Implementations
*This is a primary command used in any [[Troubleshooting Methodology]] for connectivity issues.*

### Common Status Scenarios
| Status                        | Meaning & Common Causes                                                                                                                                                           |
| ----------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `up, line protocol is up`     | ✅ **Healthy:** The connection is fully operational at both Layer 1 and Layer 2.                                                                                                   |
| `down, line protocol is down` | ⚠️ **Layer 1 Issue:** Check for a bad or unplugged cable, or ensure the device on the other end is powered on and not shut down.                                                  |
| `up, line protocol is down`   | ❌ **Layer 2 Mismatch:** The physical link is good, but there's a configuration error. Check for mismatched encapsulation, a clocking issue (on serial links), or a VLAN mismatch. |
| `administratively down, down` | ⛔️ **Disabled:** The interface has been manually disabled with the `shutdown` command. Use `no shutdown` to enable it.                                                            |
## See Also 
- [[Common Switch Verification Commands]] 
- [[Physical Layer (OSI Model)]]
- [[Data Link Layer (OSI Model)]] 
- [[Troubleshooting Methodology]]