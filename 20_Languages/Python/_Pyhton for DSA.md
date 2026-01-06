---
tags:
  - overview
  - language
  - python
  - dsa
category: language
status: learning
related: "[[Arrays]]"
date: <% tp.date.now("YYYY-MM-DD") %>
---
# _Pyhton for DSA_
## 📝 One-Sentence Summary
A tactical guide to Python's standard library features specifically optimized for algorithmic problem solving.

## ⚙️ Key Details
- **Philosophy:** Python is "executable pseudocode." Brevity is speed.

### 1. Essential Imports
```python
from collections import defaultdict, deque, Counter
import heapq
import bisect
import math
```

## 2. 
### Common Patterns

**Frequency Map (The "Counter" Trick):**
```python
# Old way
count = {}
for n in nums:
    count[n] = count.get(n, 0) + 1

# Pro way
count = Counter(nums) 
# Returns: Counter({'a': 2, 'b': 1})
```

**Sorting Custom Objects:**
```python
# Sort by second element of tuple
arr = [(1, 3), (4, 1), (2, 2)]
arr.sort(key=lambda x: x[1]) 
# Result: [(4, 1), (2, 2), (1, 3)]
```

**Infinity (for Min/Max comparisons):**
```python
min_val = float('-inf')
max_val = float('inf')
```

### 3. Complexity Gotchas

- **`len(str)`**: $O(1)$
    
- **`str + str`**: $O(N^2)$ in a loop! (Strings are immutable, use `.join()` instead).
    
- **`item in list`**: $O(N)$
    
- **`item in set/dict`**: $O(1)$
## 🔗 Connections

- [[Hash Maps]] -> Use `dict` or `defaultdict`.
    
- [[Queue]] -> Use `deque`.
    
- [[Heaps]] -> Use `heapq`.