---
tags:
  - algorithm-pattern
  - problem
  - java
  - string
difficulty:
  - easy 
source: https://www.hackerrank.com/challenges/java-substring/
status:
  - solved
related: "[[Strings in Java]]"
date: 2025-10-17
---

# Substring (HackerRank)

## 🧠 Problem Summary
Given a string and two indices, `start` and `end`, extract and print the substring contained between them.

## 💡 Key Data Structure / Concept
- This problem focuses on the `.substring()` method of the [[Strings in Java|String]] class.

## 💻 Code Implementation (`<Java>`)
```java
import java.util.*;

public class Solution {
    public static void main(String[] args) {
        Scanner in = new Scanner(System.in);
        String S = in.next();
        int start = in.nextInt();
        int end = in.nextInt();
        
        System.out.println(S.substring(start, end));
    }
}
````

## 🔧 Code Breakdown

- `.substring(int beginIndex, int endIndex)`: This method returns a new string that is a subsequence of the original.
    
    - `beginIndex`: The starting index. This character is **inclusive**.
        
    - `endIndex`: The ending index. This character is **exclusive**.
    
- **Analogy:** Think of it as selecting characters from position `start` up to, _but not including_, position `end`. For example, `"hello".substring(1, 4)` returns `"ell"`.