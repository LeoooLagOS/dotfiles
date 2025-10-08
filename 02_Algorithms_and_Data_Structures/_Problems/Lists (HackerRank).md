---
tags:
  - algorithm-pattern
  - problem
  - python
  - list
  - data-structure
difficulty:
  - easy 
source: '"https://www.hackerrank.com/challenges/python-lists/"'
status:
  - solved
related: "[[Arrays]]"
date: 2025-09-23
---

# Lists (HackerRank)

## 🧠 Problem Summary
Given a series of string commands, parse each command and use it to perform the corresponding manipulation on a Python list.

## 💡 Key Data Structure / Concept
- This problem is a direct exercise in using Python's built-in `list` methods, which is the language's implementation of a dynamic [[Arrays|Array]].

## 📜 Algorithm Explained
1. **Initialize**: Create an empty list. 
2. **Loop**: Iterate `N` times to read each command. 
3. **Parse Command**: In each iteration, read the line of input and use the `.split()` method to separate the command word from its arguments (e.g., `'insert 0 5'` becomes `['insert', '0', '5']`). 
4. **Conditional Execution**: Use an `if/elif` structure to check the command word. 
5. **Type Conversion & Execution**: Inside each block, convert any string arguments to integers using `int()` and then call the corresponding list method (`.insert()`, `.remove()`, etc.).
## 📊 Complexity Analysis
- The complexity depends on the specific list operations performed, but each command is typically between O(1) (like `append`) and O(n) (like `insert` or `remove`).
## 💻 Code Implementation (`<Python>`)

```python
if __name__ == '__main__':
    N = int(input())
    my_list = []
    
    for _ in range(N):
        command = input().split()
        cmd = command[0]
        
        if cmd == "insert":
            position = int(command[1])
            value = int(command[2])
            my_list.insert(position, value)
        elif cmd == "print":
            print(my_list)
        elif cmd == "remove":
            my_list.remove(int(command[1]))
        elif cmd == "append":
            my_list.append(int(command[1]))
        elif cmd == "sort":
            my_list.sort()
        elif cmd == "pop":
            my_list.pop()
        elif cmd == "reverse":
            my_list.reverse()
````

## 🔧 Code Breakdown

- `my_list = []`: Creates an empty list.
    
- `input().split()`: Reads a line of text and splits it by spaces into a list of strings.
    
- `my_list.insert(pos, val)`: Inserts `val` at index `pos`, shifting other elements. An O(n) operation.
    
- `my_list.append(val)`: Adds `val` to the end of the list. An amortized O(1) operation.
    
- `my_list.sort()`: Sorts the list in-place. An O(n log n) operation.
    

## 🔗 See Also

- [[ArrayList (HackerRank)]]