---
tags:
  - language
  - text-processing
  - linux
  - bash
  - tool
category: os
status: learning
related: "[[Sed]]"
date: 2025-12-02
---
# Awk
## 📝 One-Sentence Summary
*Awk is a powerful data-driven scripting language designed for text processing, specifically effective at handling structured data organized in **rows and columns** (like CSVs or log files).*
## 💡 Analogy
* **Sed** is a **Correcting Pen**. It fixes typos across the page.
* **Awk** is Excel in the Terminal. It understands "Column 3" and "Row 5" and can do math on them ("Sum all values in Column 4").
## 🔑 Core Concept: Fields (`$`)
Awk automatically splits input lines into fields (columns) based on whitespace (default) or a specific delimiter (`-F`).
* **`$0`**: The entire line.
* **`$1`**: The first column.
* **`$NF`**: The **Last** column (Number of Fields).

## ⚙️ Syntax
`awk 'pattern { action }' file`

### 🚀 Common Examples
1.  **Print specific columns:**
    ```bash
    ps aux | awk '{print $1, $11}'
    # Prints User ($1) and Command ($11) of running processes.
    ```
2.  **Filter by value (Logical):**
    ```bash
    awk '$3 > 500 {print $0}' data.txt
    # Print line if Column 3 is greater than 500.
    ```
3.  **Custom Delimiter (CSV):**
    ```bash
    awk -F "," '{print $2}' data.csv
    # Uses comma as separator, prints 2nd column.
    ```
4.  **Math/Summing:**
    ```bash
    ls -l | awk '{sum += $5} END {print sum}'
    # Sums the file sizes (Column 5) and prints the total at the end.
    ```

## See Also
- [[Sed]]
- [[Bash Variables and Quoting]]