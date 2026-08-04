# Engineering Principles

These principles apply to every system in Project Canvas.

## 1. Simplicity First

Prefer simple, understandable code over clever code.

## 2. One Responsibility

Every module should have one clear purpose.

## 3. Server Authority

The server owns gameplay.

Clients request.

Servers validate.

Servers decide.

## 4. Cosmetics Never Affect Gameplay

Presentation may change.

Gameplay may not.

## 5. Readability Beats Brevity

Future developers should understand the code quickly.

## 6. Modular Architecture

Large scripts should be split into focused modules.

## 7. No Hardcoded Values

Gameplay values belong in Config.

## 8. Reusable Systems

If multiple features can use a module, design it to be reusable.

## 9. Document Public APIs

Every important module should explain:

Purpose

Responsibilities

Public Functions

Dependencies

## 10. Performance Matters

Avoid unnecessary loops.

Avoid unnecessary RemoteEvents.

Avoid unnecessary allocations.

Profile before optimizing.

## 11. Security First

Never trust the client.

Validate every gameplay request.

## 12. Scope Discipline

Implement only the approved task.

Do not expand scope without approval.