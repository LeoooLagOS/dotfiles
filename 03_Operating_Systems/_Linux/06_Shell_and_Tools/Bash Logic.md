---
tags:
  - concept
  - linux
  - bash
  - logic
  - loops
category: os
status: learning
related: "[[Exit Codes]]"
date: 2025-11-28
---
# Bash Logic (Conditionals & Loops)
## 📝 One-Sentence Summary
*Bash logic controls the flow of execution using conditionals (`if`, `case`) to make decisions and loops (`for`, `while`) to iterate over tasks.*
## ⚖️ Conditionals (If/Else)
Structure relies on the **Exit Code** of the command being tested.
```bash
if [ condition ]; then
    # commands
elif [ other_condition ]; then
    # commands
else
    # commands
fi
```
### The Test Command (`[ ]` vs `[[ ]]`)

- **`[ ]` (Single Bracket):** The classic POSIX `test` command. Strict and brittle.
    
- **`[[ ]]` (Double Bracket):** The modern Bash keyword. Safer, supports regex (`=~`) and logical operators (`&&`, `||`) inside the brackets. **Use this.**
### Comparison Operators

|**Type**|**Flag**|**Meaning**|**Example**|
|---|---|---|---|
|**File**|`-f`|File exists|`[[ -f config.yaml ]]`|
|**File**|`-d`|Directory exists|`[[ -d /tmp/logs ]]`|
|**String**|`-z`|Zero length (Empty)|`[[ -z "$VAR" ]]`|
|**String**|`==`|Equal|`[[ "$USER" == "root" ]]`|
|**Int**|`-eq`|Equal|`[[ $COUNT -eq 5 ]]`|
|**Int**|`-gt`|Greater Than|`[[ $VAL -gt 10 ]]`|

## 🔄 Loops

### 1. `for` Loop (Iteration)

Best for lists of items (files, servers).
```bash
# C-Style
for ((i=0; i<5; i++)); do echo $i; done

# List Style (DevOps standard)
for server in app1 app2 db1; do
    ssh $server "uptime"
done
```

### 2. `while` Loop (Condition)

Runs as long as the condition is true.
```bash
while [[ $COUNT -gt 0 ]]; do
    echo "Countdown: $COUNT"
    ((COUNT--))
done
```

## 🔀 Case Statement

Cleaner than many `elif`s.
```bash
case "$1" in
    start)
        systemctl start nginx ;;
    stop)
        systemctl stop nginx ;;
    *)
        echo "Usage: $0 {start|stop}" ;;
esac
```

## See Also

- [[Exit Codes]] (Logic relies on 0 vs non-zero)
    
- [[Bash Variables and Quoting]]
