---
tags:
  - concept
  - data-mining
  - statics
category: Artificial Intelligence
status: learning
related: "[[_Data Mining]]"
date: 2026-01-08
---
# Data Mining Variables

## 📝 One-Sentence Summary
The classification of data attributes into Metric or Non-Metric scales to determine the appropriate mathematical operations and models.

## 💡 Analogy
If a dataset is a recipe, the variables are the ingredients. You measure flour by weight (**Metric**), but you categorize apples by variety (**Non-Metric**).

## 🔑 Key Details
- **Dependent Variable (Target):** The variable we are trying to predict or explain.
- **Metric Variables:**
	- Quantitative/Numerical.
	- Supports arithmetic operations (Mean, Standard Deviation).
	- *Example:* Temperature, Revenue, CPU Usage %.
- **Non-Metric Variables:**
	- Qualitative/Categorical.
	- Includes **Nominal** (Names) and **Ordinal** (Ordered categories).
	- *Example:* Gender, OS Type (Linux/Windows), User Rank (Bronze/Gold).

## 🔗 Connections & Implementations
- **[[IBM SPSS Modeler]]:** Specifically requires users to define "Measurement" (Scale, Ordinal, Nominal) before running nodes.
- **[[Unsupervised Learning]]:** Occurs when no specific variable is flagged as the "Dependent" variable.

## 👍 Pros & 👎 Cons
- **Pros:** Prevents logical errors (e.g., trying to calculate the "average" of Zip Codes).
- **Cons:** Some variables are ambiguous and require manual transformation (Encoding).