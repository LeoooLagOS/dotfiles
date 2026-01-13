---
tags:
  - overview
  - concept
  - stadistics
category: Artificial Intelligence
status: learning
related: "[[_Data Mining]]"
date: 2026-01-13
---
# _Regression Models

## 📝 One-Sentence Summary
Regression models are statistical techniques used to predict a continuous outcome variable based on one or more predictor variables by establishing mathematical relationships.

## 💡 Analogy
Think of regression like predicting the "final score" of a video game based on hours practiced. The more you input (practice), the higher the output (score) moves along a predictable trajectory.

## 🔑 Core Philosophy & Design
The goal is to minimize the error (residual) between actual data points and the predicted value, usually through the **Ordinary Least Squares (OLS)** method.

## ⚙️ Key Details

### 1. Simple Linear Regression
- **What it is:** Predicts a dependent variable using a single independent variable.
- **Formula:** $y = \beta_0 + \beta_1x + \epsilon$ 
- **Example:** Predicting a person's **Weight** based solely on their **Height**.

### 2. Multiple Linear Regression
- **What it is:** Uses two or more independent variables to predict a single outcome.
- **Example:** Predicting the **Price of a House** based on **Square footage, Location, and Year Built**.

### 3. Logistic Regression
- **What it is:** Used when the dependent variable is categorical (Binary: 0 or 1). It predicts the probability of membership in a class.
- **Example:** Predicting if a bank transaction is **Fraudulent or Legitimate**.

### 4. Polynomial Regression
- **What it is:** Models non-linear relationships by fitting an $n^{th}$ degree polynomial to the data.
- **Example:** Predicting the **Growth Rate of a Virus** which often follows a curved path rather than a straight line.

## 🔗 Connections & Implementations
- **[[_Data Mining]]:** Essential for the "Modeling" phase of CRISP-DM.
- **[[_Machine Learning]]:** Serves as the foundation for Supervised Learning.

## See Also
- [[Data Mining Variables]]
- [[KDD Process]]