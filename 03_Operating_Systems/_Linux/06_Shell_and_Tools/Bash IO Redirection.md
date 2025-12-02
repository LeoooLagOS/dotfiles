---
tags:
  - guide
  - linux
  - bash
  - io
  - streams
category: os
status:
  - learning
related: "[[Shell Scripting]]"
date: 2025-12-02
---
## 📝 One-Sentence Summary 
*I/O Redirection captures the input/output streams of commands (Stdin, Stdout, Stderr) and routes them to files, other commands, or special devices.* 
## 🔑 The Three Streams 
| Name       | Descriptor | Default             |
| :--------- | :--------- | :------------------ |
| **Stdin**  | `0`        | Keyboard            |
| **Stdout** | `1`        | Screen4             |
| **Stderr** | `2`        | Screen (Error msgs) |
## ⚙️ Redirecting Output (`>`) 
* **`>` (Overwrite):** `ls > file.txt` (Creates or truncates file). 
* **`>>` (Append):** `echo "log" >> file.txt` (Adds to end of file). 
* **`2>` (Redirect Error):** `ls invalid_file 2> errors.txt`. 
* **`&>` (Redirect All):** `command &> all_output.txt` (Both Stdout and Stderr). 
	* *Classic Equivalent:* `command > file.txt 2>&1` (Point 2 to where 1 is pointing). 
## ⚙️ Redirecting Input (`<`) 
* **File Input:** `grep "search" < file.txt` 
* **Here Doc (`<<EOF`):** Feeds a block of text into a command. 
```bash 
cat <<EOF > config.ini 
[Server] 
Port=80 
EOF 
``` 
* **Here String (`<<<`):** Feeds a single string. 
	* `grep "foo" <<< "$VAR"` (Avoids `echo $VAR | grep "foo"`). 
## 🔗 Pipes (`|`) 
Connects **Stdout** of Command A to **Stdin** of Command B. 
* `cat *.txt | sort | uniq` 
* **Note:** Pipes do NOT pass Stderr by default. 
## 🚀 Advanced Tips 
* **Silence:** `command &> /dev/null` (Throw output away). 
* **Tee:** `command | tee file.txt` (Print to screen AND write to file). 
* **Network:** Bash can write to TCP/UDP ports! `echo "GET /" > /dev/tcp/google.com/80`. 
## See Also 
- [[Bash Script Structure]] 
- [[Linux File System]] (/dev/null)