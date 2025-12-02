---
tags:
  - cli
  - text-processing
  - linux
  - bash
  - tool
category: os
status: learning
related: "[[Awk]]"
date: 2025-12-02
---
# Data Slicing (Cut, Sort, Uniq)
## 📝 One-Sentence Summary
*A set of lightweight utilities for slicing lines (`cut`), ordering data (`sort`), and removing duplicates (`uniq`), often chained together in pipelines.*
## ⚙️ Cut (The Simple Slicer)
Used when data has a strict delimiter. Simpler/faster than Awk for basic tasks.
* **Syntax:** `cut -d "delimiter" -f "fields"`
* **Example:** `cut -d ":" -f 1 /etc/passwd`
    * *Action:* Uses colon (`:`) as delimiter, extracts Field 1 (Usernames).

## ⚙️ Sort (The Organizer)
* **Default:** Sorts alphabetically (A-Z).
* **Flags:**
    * `-n`: **Numeric** sort (so 10 comes after 2, not before).
    * `-r`: **Reverse** (Z-A).
    * `-k 2`: Sort by **Column 2**.

## ⚙️ Uniq (The Filter)
Removes **adjacent** duplicate lines.
* ⚠️ **Rule:** You must **Sort** data before piping to `uniq`, or it won't catch duplicates that aren't touching.
* **Count Duplicates:** `uniq -c` (Shows how many times a line appeared).

## 🚀 The "Frequency Analysis" Pipeline
One of the most useful commands in DevOps (e.g., finding who is attacking your web server).
```bash
cat access.log | cut -d " " -f 1 | sort | uniq -c | sort -nr
```
1. **Cut:** Extract IP address (Column 1).
    
2. **Sort:** Group identical IPs together.
    
3. **Uniq -c:** Count occurrences of each IP.
    
4. **Sort -nr:** Sort the results numerically descending (Top attackers first).
## See Also

- [[Awk]]
    
- [[Shell Scripting]]