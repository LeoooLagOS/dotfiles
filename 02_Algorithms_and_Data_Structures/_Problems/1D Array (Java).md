---
tags:
  - algorithm-pattern
  - problem
  - java
  - array
difficulty:
  - easy 
source: https://www.hackerrank.com/challenges/java-1d-array-introduction/
status:
  - solved
related: "[[Arrays]]"
date: 2025-10-09
---

# 1D Array (Java)

## 🧠 Problem Summary
Create an array of a given size, read that many integers from standard input to populate it, and then print each element on a new line.
## 💡 Key Data Structure / Concept
-   This problem is a fundamental exercise in the lifecycle of a [[_Java]] [[Arrays|Array]]: **declaration, instantiation, and population**.

## 💻 Code Implementation (`Java`)
```java
import java.util.*;

public class Solution {
    public static void main(String[] args) {
        Scanner scan = new Scanner(System.in);
        int n = scan.nextInt();
        
        // 1. Declare and Instantiate the array
        int[] a = new int[n];
        
        // 2. Populate the array
        for (int i = 0; i < n; i++) {
            a[i] = scan.nextInt();
        }
        
        scan.close();

        // 3. Iterate and print from the array
        for (int element : a) {
            System.out.println(element);
        }
    }
}
````

## 🔧 Code Breakdown

- `int[] a = new int[n];`: This single line performs two crucial actions:
    
    - `int[] a`: **Declares** a variable `a` that holds a reference to an "array of integers."
        
    - `new int[n]`: **Instantiates** (creates) a new array object in memory with enough space for `n` integer elements and assigns its memory address to `a`.
        
- `for (int i = 0; i < n; i++)`: A traditional `for` loop is used to **populate** the array by iterating from index `0` to `n-1` and assigning a value to each slot `a[i]`.
    
- `for (int element : a)`: An **enhanced for-loop** is a cleaner way to read from an array when you don't need the index.