---
tags:
  - algorithm-pattern
  - problem
  - java
  - string
difficulty:
  - easy 
source: https://www.hackerrank.com/challenges/java-strings-introduction/
status:
  - solved
related: "[[Strings in Java]]"
date: 2025-10-16
---

# Strings Introduction (Java)

## 🧠 Problem Summary
Given two strings, perform three tasks: calculate their combined length, determine their lexicographical order, and print them with their first letters capitalized.

## 💡 Key Data Structure / Concept
- This problem is a direct exercise in using the fundamental methods of the [[Strings in Java|String]] class.

## 💻 Code Implementation (`<Java>`)
```java
import java.util.*;

public class Solution {
    public static void main(String[] args) {
        Scanner sc=new Scanner(System.in);
        String A=sc.next();
        String B=sc.next();
        
        System.out.println(A.length() + B.length());
        
        if (A.compareTo(B) > 0) {
            System.out.println("Yes");
        } else {
            System.out.println("No");
        }
        
        String capA = A.substring(0, 1).toUpperCase() + A.substring(1);
        String capB = B.substring(0, 1).toUpperCase() + B.substring(1);
        System.out.println(capA + " " + capB);
    }
}
````

## 🔧 Code Breakdown

- `.length()`: A method that returns the number of characters in the string.
    
- `.compareTo(anotherString)`: Compares two strings lexicographically (dictionary order). It returns a **positive integer** if the first string comes alphabetically _after_ the second.
    
- **Capitalization**: `A.substring(0, 1).toUpperCase() + A.substring(1);`
    
    - `A.substring(0, 1)`: Extracts the first character.
        
    - `.toUpperCase()`: Converts it to uppercase.
        
    - `+ A.substring(1)`: Concatenates the capitalized first letter with the rest of the string (from index 1 to the end).