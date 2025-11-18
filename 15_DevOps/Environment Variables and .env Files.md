---
tags:
  - concept
  - devops
  - security
  - configuration
category: dev-ops
status:
  - learning
related: "[[_Laravel]]"
date: 2025-11-17
---
# Environment Variables and .env Files
## 📝 One-Sentence Summary
*An `.env` (environment) file stores configuration variables that are specific to the environment (local, staging, production) in which an application is running.*
## 💡 Analogy
*An `.env` file is like the **"settings panel"  on your phone**. Your phone's apps (the code) are the same on every phone, but your *settings* (Wi-Fi password, screen brightness, database password) are unique to your device. The `.env` file holds these unique settings *outside* of the main application code.*
## 🔑 Key Details
- **What it is:** 
	- A plain text file in the project's root directory named `.env`. It contains key-value pairs (e.g., `DB_DATABASE=proyectofinal_db`).
- **Why it exists:** 
	- For **Security & Portability**. It separates sensitive credentials (like database passwords, API keys) from the application's source code. This is crucial because the `.env` file is **never committed to Git** (it's listed in `.gitignore`).
## 🔗 Connections & Implementations
* In Laravel, you edited `.env` to set `DB_DATABASE`, `DB_USERNAME`, and `DB_PASSWORD`.
* Laravel reads these values and uses them to configure the application (e.g., in the `config/database.php` file).
* This is a core principle of the [Twelve-Factor App](https://12factor.net/config) methodology.
## 👍 Pros & 👎 Cons
-   **✅ Pros:** 
	- Keeps secrets out of source control ([[_Git]]). Allows one codebase to run in multiple environments (dev, prod) with different settings.
-   **❌ Cons:** 
	- Requires careful management; a missing variable in `.env` can crash the application.
## See Also
- [[_Laravel]]