---
tags:
  - guide
  - linux
  - bash
  - loops
  - control-flow
category: os
status: learning
related: "[[Bash Control Flow]]"
date: 2025-12-02
---
# Bash Loops (For, While, Until)
## 📝 One-Sentence Summary
*Loops allow a block of code to run repeatedly, either for a set list of items (`for`), while a condition is true (`while`), or until a condition becomes true (`until`).*
## 🔄 For Loop (Iterate a List)
Best for processing a known list of files, strings, or numbers.
```bash
# Standard Syntax
for arg in [list]; do
    command "$arg"
done

# Example: Process output of another command
for file in $(ls *.txt); do
    echo "Processing $file"
done
```
## ⏳ While Loop (True Condition)
Keeps running **as long as** the condition returns `0` (Success/True).
- **Use Case:** Waiting for a server to come online, or reading a file line-by-line.
```bash
LIMIT=10
while [ "$a" -le $LIMIT ]; do
    echo -n "$a "
    ((a++))
done
```

## 🛑 Until Loop (False Condition)
Keeps running **until** the condition becomes True (Opposite of While).
- **Use Case:** Retry logic ("Keep trying until the ping succeeds").
```bash
until ping -c 1 8.8.8.8; do
    echo "Waiting for internet..."
    sleep 1
done
```

## 🎛️ Loop Control

- **`break`**: Exits the loop completely.
    
- **`continue`**: Skips the rest of the current iteration and jumps to the next one.
## See Also

- [[Bash Control Flow]]
    
- [[Bash Tests and Comparisons]]