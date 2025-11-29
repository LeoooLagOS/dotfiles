---
tags:
  - concept
  - tool
  - devops
  - web-development
  - windows
  - php
  - mysql
category: dev-ops
status:
  - learning
related: "[[Apache HTTP Server]]"
date: 2025-11-16
---
# XAMPP
## 📝 One-Sentence Summary
*XAMPP is a free, open-source, and cross-platform web server solution stack that bundles all the necessary components ([[Apache HTTP Server|Apache]], [[_MariaDB]], [[_PHP]], [[_Perl]]) into a single, easy-to-install package for local development.*
## 💡 Analogy
*If building a web server is like building a car, XAMPP is a **"car-in-a-box" kit**. Instead of having to source the engine (Apache), the fuel system (MySQL), and the electronics (PHP) separately, XAMPP gives you all the parts in one box with a simple instruction manual and a control panel to turn it on and off.*
## 🔑 Key Details
- **What it is:** 
	- A local server stack. The acronym stands for **X** (Cross-platform), **A**pache, **M**ariaDB (a fork of MySQL), **P**HP, and **P**erl.
- **Why it exists:** 
	- To provide developers with a fast and simple way to set up a full-featured local development environment without configuring each component individually.
## 🔗 Connections & Implementations
* The **XAMPP Control Panel** is the main interface used to start and stop services like Apache (web server) and MySQL (database server).
* It's a direct alternative to [[Laragon]], which serves a similar purpose.
* By default, it serves files from the `C:\xampp\htdocs` folder.
* Its configuration files (`httpd.conf`, `php.ini`, `my.ini`) are all accessible through the "Config" buttons on the control panel.
## 👍 Pros & 👎 Cons
-   **✅ Pros:**
	- Very easy to install, includes all major components (even Tomcat), great for PHP/MySQL beginners.
-   **❌ Cons:** 
	- Can have port conflicts, and its file system can become corrupted from improper shutdowns,  requiring a data backup/restore.
## See Also
- [[Laragon]
- [[Apache HTTP Server]]
- [[MySQL]]
- [[_PHP]]