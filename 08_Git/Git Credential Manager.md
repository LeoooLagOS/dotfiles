---
tags:
  - concept
  - tool
  - git
  - authentication
category: git
status:
  - learning
related: "[[_Git]]"
date: 2025-10-22
---

# Git Credential Manager

## 📝 One-Sentence Summary
Git Credential Manager is a secure Git credential helper built on top of the native credential stores of Windows, macOS, and Linux, simplifying authentication to remote Git hosts like GitHub.
## 💡 Analogy
GCM is like a **secure digital keychain** specifically for Git. The first time you need to unlock a door (authenticate with GitHub), you use your master key (log in via browser/token). GCM securely remembers this key for that specific door, so the next time you approach it, GCM automatically uses the stored key for you, without you having to type your password again.
## 🔑 Key Details
- **What it is:** 
	- A helper program that Git uses to securely store and retrieve credentials (usernames, passwords, personal access tokens) when interacting with remote repositories. 
- **Why it exists:** 
	- To avoid needing to type your credentials every time you push or pull. It securely integrates with the operating system's credential storage (like Windows Credential Manager or macOS Keychain). 
- **Modern Authentication:** 
	- Supports multi-factor authentication and token-based authentication required by services like GitHub.
## 🔗 Connections & Implementations
- Acts as an intermediary between [[_Git]] commands (`git push`, `git pull`) and remote services like [[GitHub]]. 
- Often automatically configured when installing Git for Windows.