---
name: h2a:os:gen.cognitive-mapping
description: "Generate a cognitive map for a file or a set of files or a folder"
---

## Role
You are claude-code's senior analyst and understand the internal workings of the claude code and how it processes the markdown files. 

You will Ultrathink and do cognitive map analysis.

You **must** ask the user to give you the file or folder location to generate the path. **DO NOT** assume the location, and unless you have the path, you do not proceed forward.

## Steps
Output should include:
0. Analze the structural setup of the map, and report in the following 3 categories
    - Blockers (red): anything that is blocked and doesn't have a path forward
    - Shaky (yellow): anything that may lead to inconsistencies
    - Strong foundation (green): parts of the map which have a strong founddation
1. Simple and crisp visual concept. refer to the template as described in the file below.
    - Do not report red/yellow/green for this section
2. Create a decision tree
    - Do not report red/yellow/green for this section


## Guideliens
For Structural Analysis, if you find hard termination, you should check if we are seeking inputs from user? if we are then this can't be blocker. Move this to Shaky (yellow)

Outputs **must** use the templates given in this file.


### Template: Cognitive Map Template
```
┌─────────────────────────────────────────────────────────┐
│                 PHOENIX OS MEMORY                       │
│              Three-Layer Decision System                │
└─────────────────────────────────────────────────────────┘

┌───────────────────┐
│   PRINCIPLES      │ ◄── Constitutional Rules
│   (What MUST be)  │
│                   │     • API-first (MUST)
│   ✓ SOLID         │     • No monoliths (NEVER)
│   ✓ DRY/KISS      │     • Microservices (REQUIRED)
│   ✓ 80% Coverage  │     • Containers (MANDATORY)
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│   LAYERED ARCH    │ ◄── Structure Blueprint  
│   (How to build)  │
│                   │     • Frontend → Experience → Services → Data
│   Frontend        │     • One-way dependencies only
│   Experience      │     • JWT authentication required
│   Services        │     • Domain entities (if DDD)
│   Data            │
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│   TDD PROCESS     │ ◄── Implementation Method
│   (Step by step)  │
│                   │     Two choices:
│   Story-level:    │     • Story-level: Design all interfaces first
│   Interface-first │     • Inside-Out: Start from core, build outward
│                   │
│   Inside-Out:     │     Three phases:
│   Core-first      │     • DESIGN → RED → GREEN
└───────────────────┘

┌─────────────────────────────────────────────────────────┐
│                    DECISION FLOW                        │
└─────────────────────────────────────────────────────────┘

START → Role Check → Architecture Fit → TDD Choice → Build
   │        │             │               │          │
   │    Architect?    Multi-channel?   Story vs     Layer
   │    Developer?    Simple CRUD?     Inside-Out   by Layer
   │                                                  │
   └──────────────────────────────────────────────────┴── DONE

┌─────────────────────────────────────────────────────────┐
│                  VALIDATION GATES                       │
└─────────────────────────────────────────────────────────┘

Constitutional ✓ → Structural ✓ → Process ✓ → Success
      │               │              │
   Must follow    Layers correct   Tests pass
   all rules      Dependencies     >80% coverage
                  one-way only
```


### Template: Detailed Decision Tree 

```
START
│
├── ROLE ASSESSMENT
│   ├── Architect Role
│   │   ├── Ask: Multi-channel needed? ────┬── YES → MUST use layered
│   │   ├── Ask: Microservices required? ──┤
│   │   ├── Ask: Team separation needed? ──┤
│   │   └── Ask: Simple CRUD only? ────────┼── YES → AVOID layered (CONFLICT!)
│   │                                      └── NO → CONSIDER layered
│   └── Developer Role
│       └── Assume architecture needed → Continue
│
├── ARCHITECTURE VALIDATION
│   ├── Constitutional Check (principles.md)
│   │   ├── API-first? ─────────────── MUST be YES or TERMINATE
│   │   ├── Anti-monolith? ─────────── MUST be YES or TERMINATE
│   │   ├── Microservices? ─────────── REQUIRED for distributed
│   │   └── Container deployment? ──── MANDATORY
│   │
│   ├── Structural Assessment (layered.md)
│   │   ├── Multi-channel + Microservices ─── MUST use layered
│   │   ├── Contract-based teams ──────────── CONSIDER layered
│   │   ├── Simple CRUD ───────────────────── AVOID layered
│   │   └── Rapid prototype ───────────────── AVOID layered
│   │
│   └── Domain-Driven Decision
│       ├── Domain unclear ──────────────── Skip DDD → Continue
│       ├── Domain clear + DDD selected ─── Require entities
│       │   ├── Entities available ──────── Save to specs → Continue
│       │   └── Entities missing ────────── TERMINATE (no fallback!)
│       └── DDD not selected ────────────── Continue
│
├── TDD MODEL SELECTION (MANDATORY CHOICE)
│   ├── Project Characteristics Analysis
│   │   ├── Size: XS/S ─────────── Recommend: Story-level
│   │   ├── Size: M/L/XL ───────── Recommend: Inside-Out
│   │   ├── Team: Junior ───────── Recommend: Story-level
│   │   ├── Team: Senior ───────── Either choice available
│   │   ├── Domain: Simple ─────── Recommend: Story-level
│   │   └── Domain: Complex ────── Recommend: Inside-Out
│   │
│   ├── Story-Level TDD (Interface-First)
│   │   ├── DESIGN Phase
│   │   │   ├── Define all interfaces ── GATE: Must compile
│   │   │   ├── Create DTOs/exceptions ─ GATE: Must compile
│   │   │   └── Create method stubs ──── GATE: Must compile
│   │   │
│   │   ├── RED Phase
│   │   │   ├── Write ALL story tests ─ GATE: Must compile using stubs
│   │   │   └── Verify meaningful fails  GATE: Must fail correctly
│   │   │
│   │   └── GREEN Phase
│   │       ├── Implement ALL methods ── GATE: All tests pass
│   │       └── Verify coverage >80% ─── GATE: Must achieve threshold
│   │
│   └── Inside-Out TDD (Core-First)
│       ├── DESIGN Phase
│       │   └── Define domain entities ─ GATE: Must follow layered.md
│       │
│       ├── Build by Layer (Inside → Out)
│       │   ├── Infrastructure Layer ─── Can use mocks if needed
│       │   ├── Core Domain Layer ───── NO external dependencies
│       │   ├── Service Layer ─────── Use cases, app services
│       │   ├── Experience Layer ────── BFF, orchestration
│       │   └── Presentation Layer ──── Controllers, UI
│       │
│       └── Each Layer: RED → GREEN → EXPAND
│
├── VALIDATION GATES (All Must Pass)
│   ├── Constitutional Gates
│   │   ├── API-first compliance ─── FAIL → TERMINATE
│   │   ├── Anti-monolith rule ────── FAIL → TERMINATE
│   │   ├── Microservices (if req) ─ FAIL → TERMINATE
│   │   └── Container deployment ──── FAIL → TERMINATE
│   │
│   ├── Structural Gates
│   │   ├── Layer dependencies ────── FAIL → Fix dependencies
│   │   ├── Unidirectional flow ──── FAIL → Refactor
│   │   ├── JWT authentication ────── FAIL → Add auth
│   │   └── Domain entities (if DDD) ─ FAIL → Define entities
│   │
│   └── Process Gates
│       ├── Phase 0: Interface compile ─ FAIL → Fix interfaces
│       ├── Phase 1: Test compile ───── FAIL → Fix tests
│       ├── Phase 2: Implementation ─── FAIL → Fix code
│       └── Coverage >80% + ratios ──── FAIL → Add tests
│
└── SUCCESS / FAILURE OUTCOMES
    ├── All Gates Pass ─────── SUCCESS → Development complete
    ├── Constitutional Fail ─── TERMINATE → Cannot proceed
    ├── Structural Fail ────── FIX → Return to structural validation
    └── Process Fail ────────── RETRY → Return to failed phase

CONFLICT RESOLUTION PATHS:
├── Simple CRUD vs Constitutional Rules
│   ├── Problem: CRUD wants to avoid layered, but principles require API-first
│   └── Resolution: Use minimal layered (Frontend → API → Data only)
│
├── DDD Selected but No Domain Entities
│   ├── Problem: Current rule = TERMINATE
│   └── Suggested: Fallback to service-oriented approach
│
└── TDD Model Selection Uncertainty
    ├── Problem: No clear decision criteria
    └── Resolution: Use project characteristics matrix above
```
