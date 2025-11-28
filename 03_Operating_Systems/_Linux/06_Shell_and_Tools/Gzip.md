---
tags:
  - compression
  - streams
  - tool
  - linux
category: os
status: learning
related: "[[Tar]]"
date: 2025-11-22
---
# Gzip (GNU Zip)
## 📝 One-Sentence Summary
*Gzip is a stream-based compression utility designed to compress single files or data streams, often used in conjunction with `tar`.*
## 🔑 Key Details
- **What it is:** Replaces a file with a compressed version (`.gz`).
- **Important Distinction:** Gzip compresses *files*, not directories. To compress a directory, you must `tar` it first.
## ⚙️ Core Commands
* **Compress:**
    * `gzip filename` -> Creates `filename.gz`, removes original.
    * `gzip -c file1 > foo.gz` -> Keeps original, writes output to `foo.gz`.
* **Concatenate Compressed Files:**
    * `gzip -c file2 >> foo.gz` (Appends compressed data).
* **Decompress:**
    * `gunzip foo.gz` OR `gzip -d foo.gz`
* **View Compressed Content (Without extracting):**
    * `zcat foo.gz` (Displays text).
    * `zgrep "error" foo.gz` (Searches text inside the archive).
## 🔗 Connections & Implementations
* **Log Rotation:** System logs are typically rotated and compressed (e.g., `syslog.2.gz`). Sysadmins use `zcat` and `zgrep` constantly to debug old logs without extracting them.
* **Better Compression:** `cat file1 file2 | gzip > foo.gz` creates a smaller archive than compressing them individually because the algorithm can find patterns across both files.
## See Also
- [[Tar]]
- [[Grep]]