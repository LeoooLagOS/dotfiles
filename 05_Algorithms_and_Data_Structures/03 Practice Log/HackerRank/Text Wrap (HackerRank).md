---
tags:
  - algorithm-pattern
  - problem
  - python
  - string
  - module
difficulty:
  - easy 
source: https://www.hackerrank.com/challenges/text-wrap/
status:
  - solved
related: "[[textwrap module]]"
date: 2025-10-16
---

# Text Wrap (HackerRank)

## 🧠 Problem Summary
Given a string and a specified maximum width, wrap the string so that each line is no longer than the given width.
## 💡 Key Data Structure / Concept
- The best and simplest solution for this problem is to use [[_Python]]'s built-in **[[Textwrap Module]]**, which is specifically designed for this task.

## 📜 Algorithm Explained
1. **Import the Module**:
	* Begin by importing the `textwrap` module from Python's standard library. 
2. **Read Inputs**:
	* Read the input string and the integer for the maximum width. 
3. **Use `textwrap.fill()`**:
	* Call the `textwrap.fill()` function, passing it the string and the width. This single function handles all the logic of breaking the string into lines of the correct length and joining them together with newline characters (`\n`). 
4. **Print the Result**:
	* Print the string returned by the `fill()` function.

## 📊 Complexity Analysis
- **Time**: O(N), where N is the length of the string, as the function must process the entire string. 
- **Space**: O(N), as a new string containing the wrapped text is created.

## 💻 Code Implementation (`<Python>`)
```python
import textwrap

def wrap(string, max_width):
    # The textwrap.fill() function does all the work.
    return textwrap.fill(string, max_width)

if __name__ == '__main__':
    string, max_width = input(), int(input())
    result = wrap(string, max_width)
    print(result)
````

## 🔧 Code Breakdown

- `import textwrap`: 
	- This line makes all the functions within the `textwrap` module available for use in the script.
    
- `textwrap.fill(string, max_width)`: 
	- This is the core function. It takes a string and a width as arguments and returns a new string that has been wrapped to that width, with newline characters inserted at the appropriate places. It's the professional-grade tool for this job.

## 🔗 See Also
