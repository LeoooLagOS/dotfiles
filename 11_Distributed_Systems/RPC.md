---
tags:
  - concept
  - distributed-systems
  - implementation
category: Distributed Systems
status: learning
related: "[[_Distributed Systems]]"
date: 2026-01-04
---
# RPC (Remote Procedure Call)

## 📝 One-Sentence Summary
A protocol that allows a program to execute a procedure (subroutine) in a different address space (commonly on another computer) as if it were a local call.

## 💡 Analogy
**The Ghost Chef:** You are in a restaurant and want a specific dish. Instead of going into the kitchen yourself, you tell the waiter (the **Client Stub**). The waiter takes your order, disappears into the kitchen (the **Network**), tells the chef (the **Server**), and brings you back the finished plate. You never saw the kitchen; to you, the food just appeared on your table.

## 🔑 Key Details
- **What it is:** 
	- A form of Inter-Process Communication ([[IPC]]).
- **Why it exists:** 
	- To abstract the complexity of network programming (sockets, data serialization) away from the developer.
- **Core Components:**
    - **Client Stub:** Marshals (packs) parameters into a message.
    - **RPCRuntime:** Handles the actual transmission of the message.
    - **Server Stub:** Unmarshals (unpacks) parameters and calls the local procedure.

## 🔗 Connections & Implementations
- **IDL (Interface Definition Language):** Used to define the service interface (e.g., Protobuf in gRPC).
- **gRPC:** A modern high-performance framework by Google.
- **VHDL/Architecture:** Concepts of latency and "stalling" while waiting for the remote return.

## 👍 Pros & 👎 Cons
- **Pros:** 
	- Simplifies distributed software development; highly modular.
- **Cons:** 
	- Introduces "Points of Failure" (Network lag, Server crashes) that local calls don't have.

## See Also
- [[gRPC]]
- [[Serialization_Marshalling]]