---
tags:
  - guide
  - best-practice
  - bash
  - syntax
  - formatting
category: os
status: reference
related: "[[Bash Best Practices and Standards]]"
date: 2026-01-03
---
# Bash Formatting and Syntax Standards
## 📝 One-Sentence Summary
*Strict syntax rules for indentation, line length, and quoting to ensure Bash scripts are readable, consistent, and safe from expansion errors.*

## 💡 Analogy
* **Formatting:** Think of this as the "grammar and punctuation" of your code. Just as a sentence without spaces is hard to read, a script without indentation is impossible to debug.
* **Quoting:** Think of quotes (`" "`) as a "Hazmat Suit" for your variables. Without the suit, your variable might get "contaminated" (split apart) by spaces or unexpected characters in the environment.

## 🔑 1. Visual Formatting
### Indentation & Line Length
- **Indent:** **2 spaces**. No tabs.
- **Width:** Maximum **80 characters** per line.

### Pipelines
- If it fits on one line: Keep it on one line.
- If it doesn't fit: Split one segment per line.
- **Rule:** The pipe `|` (or `&&` / `||`) goes at the **end** of the line. Indent the next line by 2 spaces.

```bash
# Good Pipeline Splitting
command1 \
  | command2 \
  | command3 \
  | command4
  ```

#### 🔑 2. Control Structures

### Loops (`for`, `while`, `if`)

- **Same Line:** `; do` and `; then` must be on the **same line** as the keyword.
    
- **Closing:** `done`, `fi`, and `else` get their own lines.
```bash
# Correct Loop Format
for dir in "${dirs_to_cleanup[@]}"; do
  if [[ -d "${dir}/${ORACLE_SID}" ]]; then
    rm "${dir}/${ORACLE_SID}/"*
  else
    mkdir -p "${dir}/${ORACLE_SID}"
  fi
done
```
### Case Statements
- **Indent:** Alternatives indent 2 spaces.
    
- **Terminator:** `;;` gets its own line (unless the case is a simple one-liner).
    
- **Wildcard:** No open parenthesis needed for patterns (use `*)` not `(*)`).
```bash
case "${flag}" in
  a)
    aflag='true'
    ;;
  *)
    error "Unexpected option ${flag}"
    ;;
esac
```
#### 🔑 3. Variables & Expansion

**Rule:** Consistency and Safety.

1. **Precedence:** `"${var}"` > `"$var"` > `$var`.
    
2. **Braces `${...}`:**
    
    - **Recommended:** For all variables (e.g., `${PWD}`, `${some_var}`).
        
    - **Required:** When appending text (e.g., `${var}_suffix`) or accessing array elements/positional params > 9 (e.g., `${10}`).
        
    - **Discouraged:** For single-character specials unless necessary (use `$!`, `$?`, `$1`).

## 🔑 4. Quoting Rules

**The Golden Rule:** Quote everything unless you specifically _want_ word splitting.

|**Type**|**Rule**|**Example**|
|---|---|---|
|**Strings**|**Always quote** if they contain vars or spaces.|`echo "${flag}"`|
|**Integers**|Never quote literals. Quote vars if unsure.|`value=32`|
|**Command Sub**|**Always quote** `$(...)`.|`files="$(ls)"`|
|**Arrays**|Use `"${arr[@]}"` to preserve elements.|`cmd "${FLAGS[@]}"`|
### Why "$@" vs $*?

- **`"$@"` (Correct):** Keeps arguments separate. ("Arg 1" "Arg 2") -> ("Arg 1" "Arg 2")
    
- **`$*` (Wrong):** Smashes them together. ("Arg 1" "Arg 2") -> ("Arg 1 Arg 2")
    

## 🔗 Connections

- **Formatting** connects directly to **[[Git Diffing]]**; keeping lines short and split properly makes code reviews significantly easier.
    
- **Quoting** is the #1 defense against **Injection Attacks** and whitespace bugs.

## See Also

- [[Bash Best Practices and Standards]] (Comments and I/O)
    
- [[Bash Variables and Quoting]] (Theory behind expansion)