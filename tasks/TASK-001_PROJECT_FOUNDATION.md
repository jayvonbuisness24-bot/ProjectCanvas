# TASK-001 — Project Foundation

Status: Approved

Milestone: First Playable

Priority: Critical

---

# Objective

Build the project's technical foundation.

No gameplay should be implemented.

The objective is to create a scalable architecture that all future systems will use.

Project Canvas is expected to grow for years.

Every system should be built with maintainability, readability, and modularity in mind.

---

# Scope

Create only the project's framework.

Do NOT implement:

- Weapons
- Camera
- Movement
- UI
- Cases
- Trading
- Inventory
- Cosmetics
- Progression
- Saving
- Audio
- Animations
- Round gameplay

Only create the architecture.

---

# Required Folder Structure

Create an organized project architecture under src.

Example:

src/

client/
Controllers/
Camera/
Input/
UI/
Viewmodels/

server/
Services/
Networking/
Round/
Weapons/
Data/

shared/
Config/
Constants/
Network/
Types/
Utilities/
Weapons/

Folders may contain placeholder ModuleScripts where appropriate.

---

# Architecture Goals

The project should follow a Service / Controller architecture.

Client

Responsible for:

- Input
- Camera
- HUD
- Viewmodels
- Local effects
- Audio playback

Server

Responsible for:

- Gameplay authority
- Round state
- Weapons
- Networking validation
- Data
- Anti-cheat

Shared

Responsible for:

- Types
- Configurations
- Constants
- Utilities
- Shared definitions

---

# Configuration System

Create a configuration structure for future systems.

Examples:

RoundConfig

WeaponConfig

PlayerConfig

CameraConfig

CrosshairConfig

Do not populate gameplay values beyond placeholders.

---

# Type Definitions

Create shared Luau type definitions for future systems.

Examples:

WeaponDefinition

Loadout

PlayerState

RoundState

HitResult

DamageRequest

NetworkPayload

Use strict typing where practical.

---

# Networking

Create the basic networking structure.

Include:

Remote definitions

Remote registry

Networking utility module

Do not implement gameplay networking.

---

# Logging

Create a lightweight logging module.

Support:

Info

Warn

Error

Debug

Avoid raw print statements throughout the project.

---

# Code Standards

Every new module should include:

Purpose

Responsibilities

Public API

Future Notes (if applicable)

Avoid giant scripts.

Each module should have one responsibility.

---

# Naming Standards

Prefer names such as:

RoundService

WeaponService

ViewmodelController

CameraController

InputController

NetworkDefinitions

WeaponDefinitions

Avoid names like:

Manager

Main

Handler

Stuff

System2

---

# Acceptance Criteria

Project compiles successfully.

Folder architecture exists.

Placeholder modules load without errors.

No gameplay implemented.

Networking framework exists.

Configuration framework exists.

Logging exists.

Types exist.

Architecture is easy to extend.

---

# Deliverables

Claude should provide:

Summary

Files created

Files modified

Architecture explanation

Testing instructions

Known limitations

Suggested next task

---

# Out of Scope

Anything related to gameplay.

This task exists only to build the foundation for future milestones.