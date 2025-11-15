---
tags:
  - concept
  - api
  - networking
  - backend
  - microservices
category: web-development
status:
  - learning
related: "[[_Web Apis]]"
date: 2025-11-07
---
# gRPC (google Remote Procedure Call)
## 📝 One-Sentence Summary
*gRPC is a high-performance, open-source Remote Procedure Call (RPC) framework that uses a binary data format (Protobuf) and HTTP/2, ideal for high-speed internal communication between microservices.*
## 💡 Analogy
*If REST is like sending a **text message** (plain text, a bit slow), gRPC is like a **direct, high-fidelity phone call**. The connection is persistent, and messages are sent in a super-optimized binary format ([[Protocol Buffers|Protobuf]]) instead of text. It's much faster, but both sides must have the same tech to talk.*
## 🔑 Key Details
- **What it is:** 
	- A high-performance [[RPC]] framework created by Google.
- **Why it exists:** 
	- For low-latency, high-throughput communication, especially between internal microservices in large-scale systems.
## 🔗 Connections & Implementations
* Uses [[Protocol Buffers]] (Protobuf) by default, a binary serialization format that is much faster and smaller than JSON or XML.
* Built on HTTP/2, which allows for features like bidirectional streaming and request multiplexing.
## 👍 Pros & 👎 Cons
-   **✅ Pros:** Extremely fast, low latency, built-in streaming, strongly-typed (schema-defined).
-   **❌ Cons:** Not human-readable (binary), less flexible than REST, limited browser support (requires a proxy).
## See Also
- [[_Web Apis]]
- [[Protocol Buffers]]
- [[Microservices]]