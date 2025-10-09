---
tags:
  - overview
  - concept
  - networking
  - osi-model
  - cs-fundamental
category: cs-fundamental
status:
  - learning
related: "[[TCP/IP Model]]"
date: 2025-10-09
---
# _OSI Model_

## 📝 One-Sentence Summary
The OSI (Open Systems Interconnection) model is a conceptual framework that standardizes the functions of a network system into seven abstract layers, providing a universal language for troubleshooting and protocol design.

## 💡 Analogy
The OSI model is like the process of **shipping a package internationally**. 
Each layer is a different department in the logistics company that adds its own wrapper or label. 
- **Layer 7 (Application):** You write a letter and put it in an envelope. 
- **Layer 4 (Transport):** The mailroom splits your large package into smaller, numbered boxes. 
- **Layer 3 (Network):** The global shipping office puts the full international "To" and "From" addresses on each box. 
- **Layer 2 (Data Link):** The local mail truck driver adds the address of the *next* post office. 
- **Layer 1 (Physical):** The boxes are physically put on the truck. 
- On the receiving end, the process happens in reverse, with each department unwrapping its own layer until the recipient gets the original letter.
## 📜 History & Creator
The OSI model was developed by the **International Organization for Standardization (ISO)**, starting in the late 1970s and published in 1984. 
It was created as a vendor-neutral standard to promote interoperability between different networking vendors, each of whom had their own proprietary protocol stacks. 
Today, it serves primarily as a comprehensive teaching and reference model.

## 🔑 Core Philosophy & Design 
The core philosophy is **layered abstraction**. 
- **Divide and Conquer:** 
	- The complex problem of networking is broken down into seven smaller, manageable layers. 
- **Abstraction:** 
	- Each layer provides services to the layer above it and hides the complex details of how its own functions are implemented. 
- **Peer-to-Peer Communication:** 
	- Logically, Layer `N` on one machine communicates with Layer `N` on another machine.
## ⚙️ Key Details 
The seven layers of the OSI model, from top to bottom, are: 
- [[7_Application Layer]]: 
	- The layer closest to the end user. It provides network services directly to user applications, such as web browsers and email clients. **(PDU: Data)** 
- [[6_Presentation Layer]]: 
	- The "translator" of the network. It handles data formatting, encryption, and compression to ensure data from the application layer is in a usable format for the recipient. **(PDU: Data)** 
- [[5_Session Layer]]: 
	- Manages the "dialogue" between computers. It establishes, manages, and terminates the sessions between two communicating hosts. **(PDU: Data)** 
- [[4_Transport Layer]]: 
	- Provides reliable, end-to-end communication between hosts. It handles segmentation, flow control, and error correction. **(PDU: Segment)** 
- [[3_Network Layer]]: 
	- Responsible for logical addressing and routing packets across different networks to their final destination. **(PDU: Packet)** 
- [[2_Data Link Layer]]: 
	- Manages node-to-node data transfer and physical addressing (MAC addresses) on the local network. **(PDU: Frame)** 
- [[1_Physical Layer]]: 
	- Transmits raw bits over a physical medium (cables, radio waves). **(PDU: Bit)** 
A common mnemonic to remember the layers is: **"Please Do Not Throw Sausage Pizza Away."**
## 🔗 Connections & Implementations
- While the OSI model is the standard *teaching* model, most real-world networks are built on the simpler, four-layer **[[TCP/IP Model]]**. 
- The model provides a systematic framework for [[Troubleshooting Methodology|network troubleshooting]]. 
- The process of passing data down the stack and adding headers at each layer is called **[[Data Encapsulation]]**.
## See Also
- [[TCP/IP Model]] 
- [[Data Encapsulation]]