---
tags:
  - concept
  - networking
  - protocol
category: networking
status:
  - learning
related: "[[STP]]"
date: 2025-10-01
---

# STP Versions (STP, RSTP, PVST, MSTP)

## 📝 One-Sentence Summary
*Multiple versions of [[STP|STP]] exist to provide faster convergence, support for [[VLAN|VLANs]], and improved scalability over the original 802.1D standard.*
## 💡 Analogy
It's like the evolution of Wi-Fi standards. The original was slow and basic (**STP**). Then came faster versions (**RSTP**), versions that handled guest networks better (**PVST+**), and finally, highly efficient versions for large corporate offices (**MSTP**).

## 🔑 Key Details
- **What they are:** 
	- Different protocols that all share the goal of creating a loop-free [[2_Data Link Layer (OSI Model)|Layer 2]] topology but with different features and efficiencies. 
- **Why they exist:** 
	- To address the limitations of the original STP standard, such as slow convergence time and lack of VLAN awareness.

### Comparison Table
| Protocol        | Standard          | Key Feature                                                                   |
| --------------- | ----------------- | ----------------------------------------------------------------------------- |
| **STP**         | IEEE 802.1D       | Original, slow-converging, one instance for all VLANs.                        |
| **PVST+**       | Cisco Proprietary | Runs a separate 802.1D instance for **each VLAN**.                            |
| **RSTP**        | IEEE 802.1w       | **Rapid** convergence (seconds vs. ~50s).                                     |
| **Rapid PVST+** | Cisco Proprietary | Combines RSTP's speed with a per-VLAN implementation.                         |
| **MSTP**        | IEEE 802.1s       | **Multiple** VLANs can be mapped to a single instance, improving scalability. |

## 🔗 Connections & Implementations
* All versions are backward-compatible, but mixing them can result in slower, legacy performance. Cisco switches use Rapid PVST+ by default.
## See Also
- [[STP]] 
- [[VLAN]]