---
tags:
  - cli
  - piping
  - backup
  - linux
  - tool
category: os
status: learning
related: "[[Shell]]"
date: 2025-11-22
---
# Tar (Tape Archive)
## 📝 One-Sentence Summary
*Tar is the primary archiving utility in Linux used to group many files into a single "tarball" file, preserving file permissions and hierarchy.*
## 💡 Analogy
* **Tar** is like a **Moving Truck**. It takes hundreds of boxes (files) and puts them into one big container (the `.tar` file) so they can be moved easily.
* **Note:** The truck itself doesn't squash the boxes (compression); it just holds them. To squash them, you need to add a compactor like [[Gzip]] (the `-z` flag).
## 🔑 The "Flag" Mnemonic
* **c** - **C**reate a new archive.
* **x** - e**X**tract an archive.
* **v** - **V**erbose (Show me what's happening).
* **f** - **F**ile (The filename follows immediately after).
* **z** - g**Z**ip (Compress the archive using gzip).
* **t** - **T**able of contents (List files without extracting).

## ⚙️ Core Commands
* **Create:** `tar -cvf archive.tar /path/to/source`
* **Create + Compress:** `tar -cvzf archive.tar.gz /path/to/source`
* **Extract:** `tar -xvf archive.tar`
* **List:** `tar -tf archive.tar`

## 🚀 Advanced: Piping & SSH
* **Copy Directory Structure (Local):**
    * `tar cf - dir1 | (cd dir2 && tar xf -)`
    * *Explanation:* Tars `dir1` to `stdout` (`-`), pipes it to a subshell that changes to `dir2`, and untars from `stdin` (`-`). Faster than `cp -r` for huge directories.
* **Copy Over Network (SSH):**
    * `ssh root@host1 "cd /src && tar -cf - ." | ssh root@host2 "cd /dest && tar -xf -"`
    * *Power Move:* Moves an entire filesystem between two remote servers through your machine without creating intermediate files.
## See Also
- [[Gzip]]
- [[SSH]]