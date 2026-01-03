---
tags:
  - guide
  - best-practice
  - bash
  - error-handling
  - performance
category: os
status: reference
related: "[[Bash Best Practices and Standards]]"
date: 2026-01-03
---
# Bash Execution and Reliability Standards
## 📝 One-Sentence Summary
*Guidelines for robust error handling (using `PIPESTATUS` for pipelines) and performance optimization (preferring shell built-ins over external binaries).*

## 💡 Analogy
* **Checking Return Values:** Think of this like checking a receipt. Just because the cashier handed you a bag doesn't mean everything you bought is inside. You must check the "status" (the receipt) to confirm.
* **PIPESTATUS:** 
	* Imagine a relay race. If the first runner trips but the last runner finishes, the team still failed. Standard Bash only looks at the last runner (`$?`). `PIPESTATUS` looks at the whole team.
* **Built-ins vs External:** 
	* Think of built-ins as doing math in your head. Think of external commands (`sed`, `awk`, `expr`) as walking to a library to look up the answer. Doing it in your head is always faster.

## 🔑 1. Checking Return Values
**Rule:** Always check if a command succeeded. Never assume.

### Unpiped Commands
Use `if` directly or check `$?` immediately.
```bash
# Preferred (Direct Check)
if ! mv "${file_list[@]}" "${dest_dir}/"; then
  echo "Error: Unable to move files." >&2
  exit 1
fi

# Alternative (Explicit Return Check)
mv "${file_list[@]}" "${dest_dir}/"
if (( $? != 0 )); then
  echo "Error: Unable to move files." >&2
  exit 1
fi
```
### Piped Commands (`PIPESTATUS`)

**The Problem:** In `cmd1 | cmd2`, `$?` only tells you if `cmd2` succeeded. If `cmd1` failed, you wouldn't know. **The Solution:** Check `${PIPESTATUS[@]}`.

**Critical Warning:** The `PIPESTATUS` array is **volatile**. It is overwritten by _any_ subsequent command (even a simple `[ test ]`). You must capture it immediately.
```bash
# Capture status of ALL commands in the pipe
tar -cf - ./* | ( cd "${DIR}" && tar -xf - )
return_codes=( "${PIPESTATUS[@]}" )

# Check individual stages
if (( return_codes[0] != 0 )); then
  echo "Error: Tar creation failed." >&2
fi
if (( return_codes[1] != 0 )); then
  echo "Error: Extraction failed." >&2
fi
```
#### 🔑 2. Built-ins vs. External Commands

**Rule:** If Bash can do it natively, do not call an external program. **Why:** Calling an external program (like `sed`, `awk`, `expr`, `cut`) requires the OS to "fork" a new process, which is slow and resource-heavy. Built-ins happen inside the current memory space.
### Examples

|**Task**|**❌ External (Slow)**|**✅ Built-in (Fast)**|
|---|---|---|
|**Math**|`val=$(expr 1 + 2)`|`val=$(( 1 + 2 ))`|
|**String Sub**|`echo "$s" \| sed 's/a/b/'`|`${s/a/b}`|
|**Sequence**|`seq 1 10`|`{1..10}`|
|**Basename**|`basename "$path"`|`${path##*/}`|
```bash
# ❌ Avoid: Spawns 'echo' process, pipes to 'sed' process 

substitution="$(echo "${string}" | sed -e 's/^foo/bar/')"

# ✅ Prefer: Pure Bash Parameter Expansion

substitution="${string/#foo/bar}"
```
## ## 🔗 Connections

- **Performance:** In tight loops, replacing `cut` or `sed` with bash string manipulation can speed up scripts by 100x.
    
- **Reliability:** External commands might differ between OS versions (BSD sed vs GNU sed). Built-ins are standard across Bash versions.
## See Also

- [[Bash Variables and Quoting]] (For Parameter Expansion syntax)
    
- [[Bash Loops]]