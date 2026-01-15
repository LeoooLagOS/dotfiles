---
tags:
  - concept
  - database
  - data-integrity
category: Databases
status: learning
related: "[[_Databases]]"
date: 2026-01-14
---
# Database Integrity Constraints

## 📝 One-Sentence Summary
Rules applied to database columns to ensure the accuracy, validity, and reliability of the data.

## 🔑 Key Details
- **Domain Integrity:** Restricts the values allowed in a column (e.g., "Age" must be a positive integer).
- **Entity Integrity (Identity):** Ensures every row is unique via a **Primary Key**. No nulls allowed in PK.
- **Referential Integrity:** Ensures relationships between tables remain consistent via **Foreign Keys**.
- **User-Defined Integrity:** Custom business rules (e.g., a "Balance" cannot drop below $-\$500$).

## 🔗 Connections & Implementations
- **SQL Implementation:** `NOT NULL`, `UNIQUE`, `PRIMARY KEY`, `FOREIGN KEY`, `CHECK`.