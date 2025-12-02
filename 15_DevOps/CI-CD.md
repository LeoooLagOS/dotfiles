---
tags:
  - concept
  - automation
  - devops
category: software-engineering
status:
  - learning
related: "[[_DevOps]]"
date: 2025-12-01
---
# CI/CD (Continuous Integration / Continuous Deployment)

## 📝 One-Sentence Summary

CI/CD is the practice of automating the integration of code changes from multiple contributors into a single software project, followed by the automated delivery or deployment of that software to production environments.

## 💡 Analogy

**The Modern Car Factory Assembly Line.**

- **Without CI/CD (Manual):** A craftsman builds a car by hand in a garage. It takes months. If a part doesn't fit, they have to tear the whole car apart to fix it.
    
- **With CI (Continuous Integration):** As soon as a worker makes a door, a robot immediately scans it to ensure it fits the frame (Automated Testing). If it fails, the line stops instantly.
    
- **With CD (Continuous Deployment):** Once the car is assembled and painted, a conveyor belt automatically drives it onto the truck and delivers it to the dealership without a human ever touching the steering wheel.

## 🔑 Key Details

### 1. Continuous Integration (CI)

- **The Goal:** Stop "Merge Conflict Hell."
    
- **The Action:** Developers merge their changes back to the main branch (`main` or `master`) as often as possible (usually daily).
    
- **The Check:** An automated system builds the application and runs unit tests to confirm the new code didn't break existing functionality.

### 2. Continuous Delivery vs. Deployment (CD)

- **Continuous Delivery:** The code is built, tested, and pushed to a staging environment. It is _ready_ to go live, but requires a human to press a "Deploy" button.
    
- **Continuous Deployment:** The entire process is automated. If the code passes all tests, it is pushed directly to the customers in production.

![Imagen de CI/CD pipeline stages](https://encrypted-tbn3.gstatic.com/licensed-image?q=tbn:ANd9GcTqFGVH2ZcAePA1EJWWCor_U1qNUPsNqnbLGJZ8FcgeiuZsNemYZsRS0AdiGYyEuqd1O-_Qmu0jGXb37pH7UAZh_HkOBHwqSyrbntmi96sG-O9gbfM)
### 3. The Pipeline

A series of steps the code must pass through. Common steps:

Build -> Test -> Security Scan -> Package (Docker Image) -> Deploy

## 🔗 Connections & Implementations

- **Tools:** **[[Jenkins]]** (Legacy/Enterprise), **[[GitHub Actions]]** (Modern/Integrated), **[[GitLab CI]]**, **[[CircleCI]]**.
    
- **Git Strategy:** CI/CD relies heavily on **[[_Git]]**. It is triggered by events like `git push` or `pull request`.
    
- **Artifacts:** The output of a CI pipeline is often a "build artifact" or a **[[Docker]]** image.
    

## 👍 Pros & 👎 Cons

|**Feature**|**Impact**|
|---|---|
|**👍 Speed**|Features get to users faster (hours instead of weeks).|
|**👍 Safety**|Automated tests catch bugs _before_ they reach production.|
|**👎 Complexity**|Setting up a pipeline requires significant initial effort and maintenance.|
|**👎 Cost**|Running build servers (runners) costs money/resources.|

## See Also

- [[_DevOps]]
    
- [[Docker]]
    
- [[Environment Variables and .env Files]] (Crucial for pipeline security)