---
tags:
  - concept
  - git
  - vcs
  - devops
category: git
status:
  - learning
related: "[[Version Control Systems]]"
date: 2025-10-01
---

# _Git_

## 📝 One-Sentence Summary
Git is a distributed **version control system** designed to track changes in source code, enabling non-linear, collaborative workflows with a focus on speed, data integrity, and support for distributed teams.

## 💡 Analogy
Git is like a **time machine for your code**. It allows you to take "snapshots" of your project at any moment. If you make a mistake, you can instantly travel back to a previous, working version. It's the ultimate "undo" button for your entire project.

## 📜 History & Creator 
Git was created in **2005** by **Linus Torvalds**, the same architect behind the [[Linux]] [[_Operating Systems|Operating System]] [[Kernel|kernel]]. 
The [[Linux Kernel]] project, with its thousands of contributors worldwide, needed a version control system that was fast, distributed, and could handle a massive scale of parallel development. When their previous proprietary tool was no longer available, Torvalds developed the initial version of Git in about two weeks to meet this specific need.
## 🔑 Core Philosophy & Design 
Git's design is a direct reflection of the needs of the [[Linux Kernel]] development. Its philosophy can be summarized as "Trust the programmer" and is built on several key principles: 
* ***Speed is Paramount:** 
	* Every operation, from committing to branching to merging, is optimized to be extremely fast. Most operations are performed locally, avoiding network latency. 
- **A Distributed Model is Essential:**  
	* Unlike centralized systems, every developer has a full, complete copy of the repository's history on their local machine. This provides incredible data redundancy and enables robust offline work. 
- **Unyielding Data Integrity:** 
	* The content of every file and the relationship between commits are secured using a cryptographic hash algorithm (SHA-1). It is impossible to change any file or commit in the history without Git knowing about it. 
- **Branching and Merging are First-Class Citizens:**  
	* Branching in Git is incredibly lightweight. It was designed from the ground up to support and encourage frequent branching and merging, allowing for flexible, non-linear development workflows. 
- **It Tracks Snapshots, Not Differences:**  
	* Git thinks of its data as a stream of snapshots of the entire project. When you commit, Git stores a snapshot of what all your files look like at that moment, which is what makes it so fast and powerful.
## 🔗 Connections & Implementations
The entire Git workflow revolves around a few core concepts and commands.
- **Hosting Platforms:** Git is the engine that powers platforms like [[GitHub]], [[GitLab]], and [[Bitbucket]]. 
- **Core Workflow:** 
	1. Modify files in your **Working Directory**. 
	2. Selectively add changes to the **[[Staging Area]]** using [[git add]]. 
	3. Save a permanent snapshot of the staging area to the **Repository** using [[git commit]]. 
- **Key Concepts:** 
	- [[Git Branch]]: 
		- Allows for developing features in isolated, parallel timelines. 
	- [[Git Merge]]: 
		- Integrates changes from one branch into another.

## 👍 Pros & 👎 Cons
- **✅ Strengths:** 
	- Unmatched performance, powerful branching model, distributed nature makes it robust for collaboration, ensures data integrity. 
- **❌ Cons:** 
	- Can have a steep learning curve for beginners due to its command-line nature and the number of concepts to master.
## See Also
- [[Version Control Systems]]