---
tags:
  - tool
  - linux
  - dns
  - troubleshooting
category: os
status: learning
related: "[[DNS Configuration]]"
date: 2025-11-24
---
# DNS Tools (Dig, Nslookup, Host, Whois)
## 📝 One-Sentence Summary
*A suite of tools used to query DNS servers for records (`dig`, `nslookup`, `host`) and retrieve domain registration details (`whois`).*
## ⚙️ Core Tools
### 1. `nslookup` (Name Server Lookup)
* **Status:** Legacy/Interactive (widely used in Windows too).
* **Usage:**
    * `nslookup epam.com`: Standard forward lookup.
    * `nslookup 174.128.60.201`: **Reverse DNS Lookup** (IP to Name).
* **Output:** Distinguishes between "Authoritative" (from the source) and "Non-authoritative" (cached) answers.

### 2. `dig` (Domain Information Groper)
* **Status:** The modern standard for troubleshooting.
* **Usage:**
    * `dig ya.ru`: Detailed lookup.
    * `dig -x 213.180.204.8`: Reverse lookup.
    * `dig +short google.com`: Just show the IP.
* **Why it's better:** It shows the exact query flags and answer section, making it ideal for debugging propagation issues.

### 3. `host` (Simple Lookup)
* **Status:** Simple utility.
* **Usage:**
    * `host ya.ru`: Translates name to IP.
    * `host 213.180.204.8`: Translates IP to name.

### 4. `whois` (Registration Info)
* **Purpose:** Queries the databases of Network Information Centers (NICs).
* **Usage:** `whois google.com`
* **Data:** Shows the **Registrant** (Owner), **Creation Date**, **Expiration Date**, and Admin contacts.

## See Also
- [[DNS Configuration]]
- [[Network Troubleshooting]]