---
tags:
  - algorithm-pattern
  - problem
  - java
  - array
difficulty:
  - easy 
source: https://leetcode.com/problems/best-time-to-buy-and-sell-stock/
status:
  - solved
related: "[[Arrays]]"
date: 2025-09-16
---

# Best Time to Buy and Sell Stock (Java)

## 🧠 Problem Summary
Given an array of stock prices, find the maximum profit that can be achieved by buying on one day and selling on a future day.

## 📋 Constraints & Edge Cases
-   If no profit can be made (prices are always decreasing), the maximum profit is 0.
-   You must buy before you can sell.

## 💡 Key Data Structure / Concept
-   The optimal solution uses a single pass, tracking a minimum price, a core pattern for `[[Arrays]]`.

## 📜 Algorithm Explained
1.  **Initialize Variables**: Set `minPrice` to the largest possible integer value and `maxProfit` to 0.
2.  **Single Pass**: Iterate through the `prices` array once.
3.  **Find New Minimum**: If the `current price` is lower than `minPrice`, update `minPrice`. This is a new best day to buy.
4.  **Check for New Max Profit**: Otherwise, calculate the potential profit (`current price - minPrice`). If this is greater than `maxProfit`, update `maxProfit`.
5.  **Return Result**: After the loop finishes, `maxProfit` will hold the highest possible profit.

## 📊 Complexity Analysis
-   **Optimal**:
    -   Time: [[Time Complexity|O(n)]]
    -   Space: [[Time Complexity|O(1)]]

## 💻 Code Implementation (`Java`)
```java
class Solution {
    public int maxProfit(int[] prices) {
        // Initialize minPrice to the largest possible value.
        int minPrice = Integer.MAX_VALUE;
        int maxProfit = 0;

        // Use an enhanced for-loop to iterate through each price.
        for (int price : prices) {
            // If we find a new, lower price, it's a better time to buy.
            if (price < minPrice) {
                minPrice = price;
            } 
            // Otherwise, check if selling at the current price gives a better profit.
            else if (price - minPrice > maxProfit) {
                maxProfit = price - minPrice;
            }
        }
        
        return maxProfit;
    }
}
````

## 🔧 Code Breakdown

- `Integer.MAX_VALUE`: A constant representing the largest possible integer. It's a perfect starting value for finding a minimum.
    
- `for (int price : prices)`: This is an example of an [[For-Loops in Java|enhanced for-loop]], which is used for simple, forward-only iteration over a collection.
    

## 🔗 See Also

- [[Two Sum (Java)]]