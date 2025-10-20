---
tags:
  - concept
  - html
  - frontend
category: web-development
status:
  - learning
related: "[[PHP Form Handling]]"
date: 2025-10-19
---

# HTML Forms

## 📝 One-Sentence Summary
HTML forms are used to collect user input on the client-side and send it to a server for processing.

## 💡 Analogy
Think of an HTML form as a paper application. You fill out different fields (text boxes, checkboxes). 
The `<form>` tag is the envelope, the `action` attribute is the mailing address you're sending it to, and the `method` attribute is how you send it (like regular mail vs. a private courier).

## 🔑 Key Details
The `<form>` element is a container for different types of input elements. Its two most important attributes define where and how the data is sent. 
- **`action` attribute**: 
	- Specifies the URL of the server-side script (e.g., a PHP file) that will process the form data. 
- **`method` attribute**: 
	- Specifies the HTTP method to use. The two main methods are `GET` and `POST`.
### Core Form Elements
- **`<input>`**: The most versatile element. Its behavior is defined by its `type` attribute:
    - `type="text"`: A single-line text field.
    - `type="password"`: A text field that masks the input.
    - `type="checkbox"`: Allows selecting zero or more options.
    - `type="radio"`: Allows selecting one option from a group (all radios in the group must share the same `name`).
    - `type="submit"`: A button that submits the form.
- **`<textarea>`**: A multi-line text input field.
- **`<select>`**: A dropdown list of options, where each option is defined by an `<option>` tag.
- **`<label>`**: A caption for an item in a form. Crucial for accessibility, as it links the text description to the input field via the `for` attribute.

### Example from P2
This form collects various types of user input and sends it to `prueba1.php` using the GET method.
```html
<form action="prueba1.php" method="get">
    <label for="nom">Nombre:</label><br>
    <input type="text" id="nom" name="nom"><br>

    <label for="pass">Password:</label><br>
    <input type="password" id="pass" name="pass"><br>

    <label for="area">Comentario:</label><br>
    <textarea name="area" id="area"></textarea><br>

    <label for="caja">Lenguaje:</label><br>
    <select name="caja" id="caja">
        <option value="1">java</option>
        <option value="2">php</option>
    </select><br>

    <input type="submit" value="Enviar">
</form>
````

## See Also

- [[PHP Form Handling]]
    
- [[HTTP Methods]]