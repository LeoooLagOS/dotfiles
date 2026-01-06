---
tags:
  - algorithm-pattern
  - problem
  - hashing
  - string
difficulty: medium
source: https://leetcode.com/problems/group-anagrams/
status: solved
related: "[[Hash Maps]]"
date: 2026-01-06
---
# Group Anagrams (Python)
## 🧠 Problem Summary
Given an array of strings, group the anagrams together. (e.g., "eat", "tea", "ate" -> `["eat", "tea", "ate"]`).

## 📋 Constraints & Edge Cases
- **Constraint:** $1 <= strs.length <= 10^4$.
- **Constraint:** Strings consist of lowercase English letters.
- **Edge Case:** Empty strings or single-character strings.

## 💡 Key Data Structure / Concept
- The optimal solution uses: **[[Hash Maps]]**.
- **The Concept:** Anagrams have the same "Fingerprint" when sorted. We use this sorted version as the **Key**.

## 📜 Algorithm Explained
1.  Initialize a `defaultdict(list)` to map keys to groups of words.
2.  Iterate through each string in the input list.
3.  **Generate Key:** Sort the characters of the string (e.g., "tea" -> "aet").
4.  Append the original string to the list corresponding to that key in the map.
5.  Return the `.values()` of the map converted to a list.

## 📊 Complexity Analysis
- **Optimal**:
    - Time: [[Time Complexity|O(N * K log K)]] 
        - $N$ is the number of strings.
        - $K$ is the length of the longest string.
        - Sorting each string takes $K \log K$.
    - Space: [[Time complexity|O(N * K)]] 
        - We store every string in the map.

## 💻 Code Implementation (Python)
```python
from collections import defaultdict

def groupAnagrams(strs):
    # Map to store sorted_string -> list_of_anagrams
    anagram_map = defaultdict(list)
    
    for word in strs:
        # Create the key: Sort characters and join them
        # "eat" -> ['a', 'e', 't'] -> "aet"
        key = "".join(sorted(word))
        
        # Group the original word under this key
        anagram_map[key].append(word)
        
    return list(anagram_map.values())
```

### 🔧 Code Breakdown

- `defaultdict(list)`: Prevents "KeyError". If a key doesn't exist, it automatically creates an empty list `[]`.
    
- `"".join(sorted(word))`: The standard Python idiom for sorting a string. `sorted()` returns a list, `join` stitches it back.
### 🔗 See Also

- [[Two Sum (Python)]] (Simple HashMap usage)
    
- [[Valid Anagram (Python)]] (The foundation of this problem)
