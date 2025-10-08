---
tags:
  - concept
  - formal-methods
category: <cs-fundamental>
status:
  - learning
related: "[[Data Depency]]"
date: 2025-09-25
---

# Bernstein's Conditions

## 📝 One-Sentence Summary
*Bernstein's Conditions are a formal set of three rules that can be used to mathematically prove whether two blocks of code can be executed in parallel without causing data conflicts.*

## 💡 Analogy

Imagine two office workers, **Ivanka** ($S_i$​) and **John** ($S_j​$), who need to process documents.

- **Read Set $L(S)$**: The documents a worker needs to read.
    
- **Write Set $E(S)$**: The documents a worker needs to write or update. A supervisor uses Bernstein's Conditions to decide if they can work simultaneously:
    

1. **"Don't read my draft!"**: The documents Alice reads $(L(S_i​))$ must not overlap with the documents Bob plans to write $(E(S_j​))$.
    
2. **"Don't read my draft! (vice-versa)"**: The documents Bob reads $(L(S_j​))$ must not overlap with what Alice plans to write $(E(S_i​))$.
    
3. **"Don't write on the same page!"**: Alice and Bob cannot write to the same document $(E(S_i​)$ and $E(S_j​)$ must not overlap). If all three rules are met, they are independent and can work in parallel.    

## 🔑 Key Details

- **What it is:** A test to determine if two sets of instructions, $S_i$​ and $S_j$​, can be executed concurrently. The test involves analyzing their
    
    **Read Sets** and **Write Sets**.
    
    - **Read Set $L(S_k​)$**: The set of all variables whose values are read by instructions in $S_k$​.
        
    - **Write Set $E(S_k​)$**: The set of all variables whose values are updated (written) by instructions in $S_k$​.
        
- **Why it exists:** To provide a precise, analytical method for compilers and programmers to identify parts of a sequential program that can be safely parallelized. It formalizes the concept of data independence.
    

## 🔗 Connections & Implementations

- **The Three Conditions:** For two segments $S_i$​ and $S_j$​ (i$\neq$j) to execute concurrently, all three of the following intersection checks must result in an empty set (∅):
    
    1. $L(S_i​)∩E(S_j​)=∅$ (Prevents Read-After-Write hazards).
        
    2. $E(S_i​)∩L(S_j​)=∅$ (Prevents Write-After-Read hazards).
        
    3. $E(S_i​)∩E(S_j​)=∅$ (Prevents Write-After-Write hazards).
        
- If any of these conditions fail, a data dependency exists, and the segments cannot be executed concurrently without some form of synchronization.
    

## 👍 Pros & 👎 Cons

- **Pros:**
    
    - Provides a mathematically sound and deterministic way to detect potential parallelism.
        
    - Can be automated and used by parallelizing compilers.
- **Cons:**
    
    - It can be overly conservative, as it only considers data dependencies, not the logic of the program.
        
    - The analysis is static and does not account for runtime behavior.

## See Also

- [[Data Dependency]]
    
- [[Precedence Graph]]
    
- [[Race Conditions]]