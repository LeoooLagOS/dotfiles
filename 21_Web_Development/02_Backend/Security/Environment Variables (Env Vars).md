---
tags: concept
category: security, deployment
status: learning
related: "[[Configuration Management]]"
date: 2025-12-13
---
# Environment Variables (Env Vars)
## 📝 One-Sentence Summary
Environment Variables are external configuration values used to inject secrets and settings into an application at runtime, ensuring sensitive data is never hardcoded in the source code.

## 💡 Analogy
Env Vars are like the **combination to a safe**. The blueprints for the safe (the source code) are public and shared with the manufacturers. However, the specific combination to open it (the API keys/Passwords) is never written on the blueprints; it is set specifically by the owner when the safe is installed in their office (the deployment environment).
## 🔑 Key Details
- **What it is:** 
	- Key-value pairs (e.g., `DB_PASSWORD=secret`) that live in the Operating System or container environment. In development, they are often loaded from a `.env` file.
- **Why it exists:** 
	- To adhere to the **Twelve-Factor App** methodology, decoupling configuration from code and preventing the leakage of secrets in Version Control Systems ([[_Git]]).
## 🔗 Connections & Implementations
- **`.env` File:** The local file for dev secrets. **Crucially**, this file must be in `.gitignore`.
- **[[CI-CD Pipelines|CI/CD Pipelines]]:** [[GitHub Actions]] or [[Jenkins]] inject these variables during the build/test process.
- **Runtime Access:** Accessed via `process.env` in Node.js or `$_ENV`/`env()` in PHP/Laravel.
## 👍 Pros & 👎 Cons
- **👍 Pros:** 
	- Critical security layer; flexible configuration across stages (Dev, Staging, Prod).
- **👎 Cons:** 
	- Mismanagement (forgetting to set a var in Prod) causes runtime crashes; keeping `.env` files synced across a team can be tedious.
## See Also
- [[.gitignore]]
- [[Security Best Practices]]