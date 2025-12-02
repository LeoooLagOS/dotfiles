---
tags:
  - concept
  - language
  - configuration
  - data-serialization
category: languages
related: "[[JSON]]"
date: 2025-12-02
---
# YAML (YAML Ain't Markup Language)

## 📝 One-Sentence Summary

YAML is a human-readable data serialization standard that uses indentation (whitespace) to define structure, primarily used for configuration files in [[_DevOps]] and infrastructure tools.

## 💡 Analogy

**The Clean To-Do List vs. The Grocery Receipt.**

- **[[JSON]]/[[XML]] (The Receipt):** Full of brackets `{}`, quotes `""`, and closing tags `</>`. It is messy for humans to read but great for machines.
    
- **YAML (The To-Do List):** It looks like a natural outline. You just use a dash `-` for a list item and indentation to show hierarchy. It focuses on the _content_, not the _syntax characters_.

## 🔑 Key Details

- **What it is:** A data format (not a programming language) used to store key-value pairs and lists.
    
- **Why it exists:** To provide a configuration format that is easy for humans to read and edit without syntax errors caused by missing brackets.
    
- **The Golden Rule:** **Indent with spaces, NEVER tabs.** (Using a tab character will break almost every YAML parser).  

### Core Syntax

1. **Key-Value:** `key: value` (Space after colon is mandatory).
    
2. **Lists:** Indicated by a dash `-`.
    
3. **Hierarchy:** Indicated by 2 spaces of indentation.
   ```yaml
# Example: A Server Configuration
server:
  host: localhost
  port: 8080
  # A List of allowed users
  users:
    - alice
    - bob
```

## 🔗 Connections & Implementations

- **DevOps Dominance:** It is the native language of **[[_DevOps]]**.
    
    - **[[GitHub Actions]]**: Uses `.yaml` for workflow definitions.
        
    - **[[Docker]]**: Uses `docker-compose.yml` to define multi-container applications.
        
    - **[[Kubernetes]]**: Uses YAML manifest files to define cluster resources.
        
- **Data Serialization:** It is often compared to **[[JSON]]**. In fact, YAML is a superset of JSON (valid JSON is also valid YAML).

## 👍 Pros & 👎 Cons

|Feature|Impact|
|---|---|
|**👍 Readability**|Very clean visual layout; comments (`#`) are supported (unlike JSON).|
|**👍 Conciseness**|No closing tags or braces reduces file size and visual noise.|
|**👎 Whitespace Sensitivity**|A single accidental extra space can break the entire file structure.|
|**👎 Ambiguity**|"No" can be interpreted as the boolean `false` in older versions (The "Norway Problem").|

## See Also

- [[GitHub Actions]]
    
- [[Docker]]
    
- [[_CI-CD]]