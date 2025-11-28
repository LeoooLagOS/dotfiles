---
tags:
  - software-management
  - sysadmin
  - linux
  - tool
category: os
status: learning
related: "[[Linux Package Management]]"
date: 2025-11-23
---
# Alternatives
## 📝 One-Sentence Summary
*Alternatives is a system utility that creates and manages symbolic links to handle multiple installed versions of the same software (like Java 8 vs Java 11) under a single generic command name.*
## 💡 Analogy
*Think of a **Railway Switch**.*
* The generic command `java` is the main track.
* You have multiple destinations: `java-8`, `java-11`, `java-17`.
* The **Alternatives** command is the lever you pull to decide which destination the train goes to when it enters the main track.
## 🔑 Key Details
- **Purpose:** Solves the problem of having multiple programs providing the same functionality (e.g., `/usr/bin/vim` vs `/usr/bin/nano` both providing `editor`, or multiple JDKs).
- **Mechanism:** It uses a chain of **Symbolic Links** ([[Hard Link vs Soft Link]]).
    - The user types `java`.
    - `java` -> `/etc/alternatives/java`
    - `/etc/alternatives/java` -> `/usr/lib/jvm/java-11-openjdk...` (The actual binary).
- **Priority:** Each alternative has a priority number. In "auto" mode, the system picks the one with the highest number.
## ⚙️ Core Commands
* **Interactive Configuration (The Switch):**
    ```bash
    alternatives --config java
    ```
    *Displays a menu to select the active version manually.*
* **Install a New Alternative:**
    ```bash
    alternatives --install <link> <name> <path> <priority>
    # Example:
    alternatives --install /usr/bin/java java /usr/java/latest/bin/java 5
    ```
* **Display Info:**
    ```bash
    alternatives --display java
    ```
## 🚀 Example: Switching Java
When you run `alternatives --config java`, you see a menu:
```text
There are 5 programs which provide 'java'.
  Selection    Command
-----------------------------------------------
   1           /usr/lib/jvm/jre-1.4.2-gcj/bin/java
*+ 4           /usr/lib/jvm/jre-1.6.0-openjdk.x86_64/bin/java
   5           /usr/java/latest/bin/java

Enter to keep the current selection[+], or type selection number: 5
```
_Result:_ The system now points the generic `java` command to option 5.

## 🔗 Connections & Implementations

- **Debian/Ubuntu:** The command is named `update-alternatives`.
    
- **Red Hat/Fedora:** The command is `alternatives`.

## See Also

- [[Hard Link vs Soft Link]]
    
- [[Linux Package Management]]
    
- [[Path]]