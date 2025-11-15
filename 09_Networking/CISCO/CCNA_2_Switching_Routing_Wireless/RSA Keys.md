---
tags:
  - concept
  - networking
  - security
  - cryptography
category: networking
status:
  - learning
related: "[[SSH]]"
date: 2025-09-29
---

# RSA Keys

## 📝 One-Sentence Summary
*RSA keys are a pair of cryptographic keys (one public, one private) that a Cisco device generates to enable secure services like [[SSH]] by encrypting the communication session.

## 💡 Analogy
*The **public key** is like an open padlock you can give to anyone. They can use it to lock a message in a box, but only you, with the unique **private key**, can unlock it.

## 🔑 Key Details
- **What they are:** 
	- A cornerstone of asymmetric cryptography used for secure data transmission. 
- **Why they exist:** 
	- Generating an RSA key pair is the action that enables the SSH server on a Cisco device. Without these keys, the encryption required for SSH cannot be performed. 
- **Modulus Length:** 
	- When generating keys, you set a modulus length (e.g., 1024, 2048 bits). A longer modulus is more secure but takes more time to generate and use.

## 🔗 Connections & Implementations
*A prerequisite for generating RSA keys is setting a hostname and an IP domain name (`ip domain-name cisco.com`). 
* **Generation Command:** `crypto key generate rsa` 
* **Deletion Command:** `crypto key zeroize rsa` (This also automatically disables the SSH server).

## See Also
- [[Configuring SSH on a Switch]] 
- [[SSH]]
- [[Encryption]]
