---
tags:
  - concept
  - tool
  - automation
  - ci-cd
category: devops
status:
  - learning
related: "[[_CI-CD]]"
date: 2025-12-02
---
# GitHub Actions

## 📝 One-Sentence Summary

GitHub Actions is an automation platform built directly into GitHub that allows you to define custom workflows (pipelines) to build, test, and deploy your code whenever a specific event (like a push or pull request) occurs.

## 💡 Analogy

The "If This, Then That" Butler.

Imagine you have a butler standing guard over your code repository.

- **Trigger (Event):** You drop a new package of code at the front door (`git push`).
    
- **Workflow:** The butler has a specific checklist (YAML file) taped to the wall.
    
- **Action:** He sees the package, immediately runs a security scan, checks for bugs, and if everything looks good, he drives it to the server room and plugs it in. You didn't have to lift a finger after dropping the package.
    

## 🔑 Key Details

- **What it is:** A CI/CD tool integrated into your GitHub repository.
    
- **Why it exists:** To eliminate the need for external CI servers (like Jenkins) and keep your configuration right next to your code.
    
- **Configuration:** Workflows are defined in **YAML** files located in the `.github/workflows/` directory of your project.
    

### Core Vocabulary

1. **Workflow:** The automated process (the entire `.yaml` file).
    
2. **Event:** The trigger that starts the workflow (e.g., `on: push`, `on: pull_request`, `on: schedule`).
    
3. **Job:** A set of steps that execute on the same runner (server).
    
4. **Step:** An individual task (e.g., "Run script", "Checkout code").
    
5. **Runner:** The server that actually executes the code (hosted by GitHub or self-hosted).
    
6. **Action:** A reusable piece of code (like a plugin) that performs a complex task (e.g., `actions/checkout@v3`).
    

## 🔗 Connections & Implementations

- **Structure:** It relies strictly on **[[_Git]]**. If the YAML file isn't committed to the repository, the action won't exist.
    
- **Security:** It uses **[[Environment Variables and .env Files]]** (via Repository Secrets) to access things like AWS keys or Docker Hub passwords without revealing them in the code.
    
- **Containerization:** It is often used to build **[[Docker]]** images and push them to a registry.
    

## 👍 Pros & 👎 Cons

|**Feature**|**Impact**|
|---|---|
|**👍 Integrated**|No need to set up a separate server; it's already in your repo.|
|**👍 Marketplace**|Thousands of pre-built actions (e.g., "Deploy to Azure") are available for free.|
|**👍 Free Tier**|Generous free minutes for public (and some private) repositories.|
|**👎 Vendor Lock-in**|The YAML syntax is specific to GitHub; migrating to GitLab CI later would require rewriting.|

## See Also

- [[_CI-CD]]
    
- [[Environment Variables and .env Files]]
- [[YAML]]