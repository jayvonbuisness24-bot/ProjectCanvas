# TASK-002 — Framework Bootstrap

Status: Approved

Milestone: First Playable

Priority: Critical

Depends On: TASK-001 — Project Foundation

---

# Objective

Create the startup and initialization framework for Project Canvas.

The purpose of this task is to make the client and server architecture created in TASK-001 initialize in a predictable, testable order.

No gameplay should be implemented.

---

# Gameplay Purpose

This task does not directly add gameplay.

It creates the framework that future gameplay services and controllers will use to start correctly.

---

# Technical Purpose

Create a structured bootstrap process for:

- Server services
- Client controllers
- Shared modules
- Initialization order
- Startup error reporting
- Dependency validation

The framework must be easy to extend without editing one giant startup script whenever a new system is added.

---

# Requirements

## Server Bootstrap

Create a server startup entry point that:

- Loads only approved server services
- Initializes services in a predictable order
- Starts services after initialization completes
- Prevents one failed service from silently breaking startup
- Logs startup success and failure
- Contains no gameplay logic

## Client Bootstrap

Create a client startup entry point that:

- Loads only approved client controllers
- Initializes controllers in a predictable order
- Starts controllers after initialization completes
- Logs startup success and failure
- Contains no gameplay logic

## Lifecycle Convention

Services and controllers may support:

- `Init()`
- `Start()`
- `Destroy()`

Not every module must implement every lifecycle method.

The framework must safely check whether each method exists before calling it.

## Registration

Use explicit or controlled registration.

Do not automatically execute every ModuleScript found anywhere in the repository.

Only approved services and controllers should be loaded.

## Error Handling

If a module fails during startup:

- Log the module name
- Log the lifecycle stage
- Preserve the original error
- Stop dependent startup when necessary
- Do not hide failures with empty protected calls

## Logging

Use the existing project Logger module.

Do not use raw `print()` statements.

---

# Required Files

Claude may adjust exact names to match the TASK-001 architecture, but the implementation should include equivalents of:

```text
src/server/Bootstrap.server.luau
src/client/Bootstrap.client.luau
src/shared/Framework/ServiceLoader.luau
src/shared/Framework/ControllerLoader.luau
src/shared/Framework/LifecycleTypes.luau