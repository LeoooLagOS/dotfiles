---
tags:
  - algorithm-pattern
  - problem
  - java
  - array
  - data-structure
  - exception-handling
difficulty:
  - easy 
source: '"https://www.hackerrank.com/challenges/java-arraylist/"'
status:
  - solved
related: "[[Arrays]]"
date: 2025-09-23
---

# ArrayList (HackerRank)

## 🧠 Problem Summary
Given several lines of integers, store them and then answer queries for the number at a specific line and position, handling invalid queries gracefully.

## 💡 Key Data Structure / Concept
- - The problem requires a nested data structure, which is perfectly modeled by an `ArrayList<ArrayList<Integer>>`. 
- A core part of the solution is using `try-catch` blocks for robust [[Exception Handling]].

## 📜 Algorithm Explained
1. **Initialize Nested List**: Create an `ArrayList` that will hold other `ArrayList<Integer>` objects. 
2. **Populate Data**: Loop `n` times to read each line. In each iteration, create a new inner `ArrayList`, populate it with the integers for that line, and then add this inner list to the main outer list. 
3. **Process Queries**: Loop `q` times to handle the queries. 
4. **Safe Access**: For each query `(x, y)`, use a `try` block to attempt to access the element at `lines.get(x-1).get(y-1)`. 
5. **Handle Errors**: Use a `catch` block to catch a potential `IndexOutOfBoundsException`. If this exception occurs, print "ERROR!" instead of crashing the program.
## 📊 Complexity Analysis
- **Data Storage**: O(N), where N is the total number of integers across all lines. 
- **Query Time**: O(1) for each query, as `ArrayList.get()` provides constant-time access.

## 💻 Code Implementation (`<Java>`)

```java
import java.util.*;

public class Solution {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        int n = scanner.nextInt();
        
        ArrayList<ArrayList<Integer>> lines = new ArrayList<>();
        
        for (int i = 0; i < n; i++) {
            int d = scanner.nextInt();
            ArrayList<Integer> line = new ArrayList<>();
            for (int j = 0; j < d; j++) {
                line.add(scanner.nextInt());
            }
            lines.add(line);
        }
        
        int q = scanner.nextInt();
        for (int i = 0; i < q; i++) {
            int x = scanner.nextInt();
            int y = scanner.nextInt();
            
            try {
                System.out.println(lines.get(x - 1).get(y - 1));
            } catch (IndexOutOfBoundsException e) {
                System.out.println("ERROR!");
            }
        }
        scanner.close();
    }
}
````

## 🔧 Code Breakdown

- `ArrayList<ArrayList<Integer>>`: Declares a nested `ArrayList`. The outer list holds objects of type `ArrayList<Integer>`.
    
- `lines.get(x - 1)`: The `.get(index)` method retrieves the element at a specific index with O(1) time complexity. We use `x-1` because queries are 1-based while indices are 0-based.
    
- `try { ... } catch (Exception e) { ... }`: 
	- This is Java's mechanism for `[[Exception Handling]]`. The code inside `try` is executed. If it throws an error of the specified type, the program immediately jumps to the `catch` block instead of crashing.
    

## 🔗 See Also

- [[Lists (HackerRank)]]