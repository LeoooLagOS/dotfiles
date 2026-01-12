---
tags:
  - concept
  - mobile-dev
  - logs
category: 22_Mobile_Development
status: learning
related: "[[_Mobile Apps Development]]"
date: 2026-01-12
---
# Event-Driven Programming

## 📝 One-Sentence Summary
A programming paradigm where the flow of the program is determined by events such as user actions (clicks, swipes), sensor outputs, or messages from other programs.

## 💡 Analogy
It is like a **Restaurant**: The chef (the program) doesn't just cook food in a random loop; they wait for a specific "event" (a customer placing an order) before executing a specific "callback" (cooking that specific dish).

## 🔑 Key Details
- **What it is:** A paradigm where an "Event Loop" waits for triggers and dispatches them to "Event Handlers."
- **Why it exists:** In mobile environments, apps stay idle to save battery and only respond when the user interacts with the screen or a sensor triggers.

## 🔗 Connections & Implementations
- **App Maker/Inventor:** Represented by "When [Button.Click]" blocks.
- **Java/Android:** Implemented via `View.OnClickListener` interfaces.
- **JavaScript:** Utilized via `addEventListener`.

## 👍 Pros & 👎 Cons
- **Pros:** Highly responsive; excellent for [[GUI]]s; power-efficient.
- **Cons:** Can lead to "Callback Hell" if logic is nested too deeply; harder to follow sequentially than Procedural code.

## See Also
* [[_Mobile Apps Development]]
* [[Object-Oriented Programming]]