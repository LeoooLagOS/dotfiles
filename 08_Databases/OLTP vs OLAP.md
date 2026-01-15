---
tags:
  - concept
  - database
  - architecture
category: databases
status:
  - learning
related: "[[Data Warehouse]]"
date: 2026-01-14
---
# OLTP vs OLAP

## 📝 One-Sentence Summary
OLTP manages operational, real-time transactions, while OLAP manages historical data analysis and complex querying.

## 💡 Analogy
**OLTP** is like a bank teller processing your deposit right now. **OLAP** is the bank's annual report analyzing the spending habits of everyone in the city over the last five years.

## 🔑 Key Details
| Feature | OLTP (Online Transactional Processing) | OLAP (Online Analytical Processing) |
| :--- | :--- | :--- |
| **Focus** | Efficiency of daily operations | Insights for decision making |
| **Data Source** | Operational databases | Data Warehouses / Data Marts |
| **Queries** | Simple (SELECT, INSERT, UPDATE) | Complex (Aggregations, Joins) |
| **Users** | Clerks, Clients, IT | Analysts, Managers, Executives |
| **Unit of Work** | Short, atomic transactions | Long, complex batch processes |

## 🔗 Connections & Implementations
- **[[ETL]]:** The bridge that moves data from OLTP to OLAP.
- **Normalization:** OLTP is highly normalized ($3NF$); OLAP often uses **Star Schema** (denormalized).

## 👍 Pros & 👎 Cons
- **Pros:** OLTP provides data integrity; OLAP provides strategic vision.
- **Cons:** Running OLAP queries on an OLTP database can "lock" production tables.