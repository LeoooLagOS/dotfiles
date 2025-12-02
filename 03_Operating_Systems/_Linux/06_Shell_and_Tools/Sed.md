---
tags:
  - regex
  - text-processing
  - linux
  - bash
  - tool
category: os
status: learning
related: "[[Grep]]"
date: 2025-12-02
---
# Sed (Stream Editor)
## 📝 One-Sentence Summary
*Sed is a non-interactive stream editor used to perform basic text transformations (find, replace, delete, insert) on an input stream (a file or input from a pipeline).*
## 💡 Analogy
* **Word Processor:** You open the file, scroll to page 50, delete a word, and save. (Interactive).
* **Sed:** You tell a robot: "Go through these 1,000 pages. Every time you see 'ClientA', replace it with 'ClientB'. Do it instantly." (Stream).
## 🔑 Key Syntax: Substitution (`s`)
The most common use case is **S**ubstitution.
`sed 's/find/replace/flags' filename`

* **Basic:** `sed 's/apple/orange/' fruits.txt` (Replaces only the *first* apple on each line).
* **Global:** `sed 's/apple/orange/g' fruits.txt` (Replaces *all* apples).
* **Case Insensitive:** `sed 's/apple/orange/I' fruits.txt`.

## ⚙️ In-Place Editing (`-i`)
By default, `sed` prints to the screen. To change the file itself:
* **Safe Mode (Backup):** `sed -i.bak 's/foo/bar/g' config.conf` (Creates `config.conf.bak` first).
* **Live Mode:** `sed -i 's/foo/bar/g' config.conf`.

## 🚀 Common One-Liners
* **Delete lines:** `sed '/error/d' log.txt` (Delete lines containing "error").
* **Print specific lines:** `sed -n '5,10p' log.txt` (Print lines 5 through 10).
* **Replace separators:** `sed 's/,/|/g' data.csv` (Turn CSV into pipe-delimited).

## See Also
- [[Grep]] (Sed finds & changes; Grep only finds)
- [[Awk]]