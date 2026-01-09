---
tags:
  - university
course: Applied Distributive Programming
professor: Orato
date: 2026-01-09
status: raw
---
# 📝 Class: [[class-2]]

## 🎯 Main Goal of Today
Installing and understanding Hercules, RealTerm and PIPE and how that work together 
## 📓 Live Lecture Notes
- **Point 1:** Serial port COM1 opened
- **Point 2:** Create a Python program that see both terminals inside Hercules
- Realterm speed: 9600
	- in the terminal anex CR and LF
	- In the right terminal Display as: Hexispace
	- In both terminal check 'port' 
		- XON and XOFF 'full buffer'? (explain) 
		- Petri Nets model for XON and XOFF (explain)
- What is an ASCII table ? and how it work in this programs and why it is used
	- in windows use 0A 
	- in Linux use just 0
- **Warning/Tip:** (Teacher mentioned this will be on the exam/project)

## 🛠️ Code Snippets / Whiteboard Sketches
(Drop raw code blocks or descriptions of diagrams here)
pyserial on windows
``` python
port = COM1

```
## 📂 Follow-up Tasks (Librarian/COO Action)
- [ ] Create Atomic Note for: `[[Concept Name]]`
- [ ] Refactor Code into: `[[pyserial - windows]]`
- [ ] Review during Commute: (German translation of a key term)
- [ ] create the python program using XON and XOFF protocol 'pyserial python'
	- [ ] RT -> XON/XOFF -> Python with buffer-limit
- [ ] ble terminal with port 'ble-serial'
- [ ] first work(practice): a python program that in distributed system resolve an 'accident and emergency unit' with rabbitMQ
