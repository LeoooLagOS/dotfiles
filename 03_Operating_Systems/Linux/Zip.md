---
tags:
  - compression
  - cli
  - tool
  - linux
category: os
status: learning
related: "[[Linux File System]]"
date: 2025-11-22
---
# Zip (and Unzip)
## 📝 One-Sentence Summary
*Zip is a widely compatible utility for packaging and compressing files into a single `.zip` archive, universally readable by Windows, macOS, and Linux.*
## 💡 Analogy
* **Zip** is like a **Standard Travel Suitcase**. It squeezes your clothes (files) to save space, and because it's a standard design, airport handlers in any country (OS) can open it without special tools.
## 🔑 Key Details
- **What it is:** 
	- A compression and file packaging utility. Unlike `tar`, `zip` both archives (groups) and compresses in one step.
- **Scope:** Best for sharing files with Windows users or simple backups.
## ⚙️ Core Commands
* **Compress (Recursive):**
    * `zip -rp archive.zip /path/to/folder`
    * `-r`: Recursive (include subfolders).
    * `-p`: Preserve file paths.
* **Extract:**
    * `unzip archive.zip` (Extracts to current directory).
* **List contents:**
    * `unzip -l archive.zip`
## 🔗 Connections & Implementations
* **Compatibility:** Often preferred over `tar.gz` when sending files to non-technical users.
## See Also
- [[Tar]]
- [[Gzip]]