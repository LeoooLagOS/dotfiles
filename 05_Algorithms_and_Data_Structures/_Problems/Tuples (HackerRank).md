---
tags:
  - algorithm-pattern
  - problem
  - python
  - tuple
  - hashing
difficulty:
  - easy 
source: https://www.hackerrank.com/challenges/python-tuples/
status:
  - solved
related: "[[Tuples in Python]]"
date: 2025-10-01
---

# Tuples (HackerRank)

## 🧠 Problem Summary
Given a string of space-separated integers, create a tuple from them and print the result of its `hash()`.

## 💡 Key Data Structure / Concept
- This problem tests the creation and properties of [[Tuples in Python]]. - It specifically leverages the fact that tuples are immutable and therefore **hashable**, a core concept of [[Hashing]].
## 📜 Algorithm Explained
1. **Read Input**: 
	1. Read the line of space-separated numbers. 
2. **Process Input**: 
	1. Use `input().split()` to turn the string into a list of number strings. Then, use the `map()` function to efficiently convert each string element into an integer. 
3. **Create Tuple**: 
	1. Pass the `map` object to the `tuple()` constructor to create the final tuple of integers. 
4. **Compute Hash**: 
	1. Call the built-in `hash()` function on the tuple and print the resulting integer.

## 📊 Complexity Analysis
- **Time**: O(n), where `n` is the number of integers in the input, to read and process the data. 
- **Space**: O(n), to store the `n` integers.w

## 💻 Code Implementation (`<Python>`)

```Python
if __name__ == '__main__': 
n = int(input()) 

# Read the line, split it, and map each element to an integer 
integer_list = map(int, input().split()) 

# Create a tuple from the map object 
t = tuple(integer_list) 

# Compute and print the hash of the immutable 
tuple print(hash(t))
```

## 🔧 Code Breakdown

- `map(int, input().split())`: 
	- A highly efficient and "Pythonic" line. It takes a function (`int`) and applies it to every item of an iterable (`input().split()`). This is more memory-efficient than a list comprehension for this task.
    
- `t = tuple(integer_list)`: 
	- The `tuple()` constructor consumes an iterable (like our map object) and builds a tuple from its elements.
    
- `hash(t)`: 
	- A built-in Python function that returns the hash value of an object. This only works on **immutable** types like tuples, strings, and numbers. It would raise a `TypeError` if you tried to call it on a list.
    

## 🔗 See Also

- [[Hashing]]
    
- [[Tuples in Python]]