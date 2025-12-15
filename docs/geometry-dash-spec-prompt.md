# Prompt: Design a Comprehensive Specification for a Geometry Dash Clone

## Context

You are being asked to write a detailed technical specification for a Geometry Dash clone game. This specification will be used by a developer working with **Claude Code**, an AI-powered coding assistant with enhanced autonomous capabilities.

Before writing the spec, please read the attached document **"Claude Code Enhanced Capabilities"** which describes the development environment. Your specification should be designed to leverage these capabilities for maximum development efficiency and code quality.

---

## Your Task

Write a comprehensive game design and technical specification document for a Geometry Dash clone. The specification should be detailed enough that a developer working with Claude Code can implement the game incrementally, with clear milestones, testable components, and well-defined data structures.

---

## About Geometry Dash (Reference)

Geometry Dash is a rhythm-based platformer where:
- The player controls a cube (or other shapes) that automatically moves forward
- The player's only input is jumping (tap/click/spacebar)
- Obstacles are synchronized to music
- One hit = death, restart from beginning (or checkpoint)
- Levels are user-created and can be shared
- Different game modes change how the character moves (cube, ship, ball, UFO, wave, robot, spider)
- Practice mode allows checkpoints for learning levels
- Levels have varying difficulty ratings
-To give you guidance about the dynamics of the gameplay, Please watch and use the following video, showing the Game play for a popular level in GEometry Dash, called “Stereo Madness” - https://youtu.be/jPqVXbKNoLk

---

## Specification Requirements

Your specification document should include the following sections:

### 1. Executive Summary
- Project overview and goals
- Target platforms (web-based using HTML5 Canvas or WebGL)
- Tech stack recommendations (consider TypeScript, a game framework like Phaser/PixiJS, or vanilla Canvas)
- Development phases and milestones

### 2. Core Gameplay Mechanics
- Player movement physics (gravity, jump force, velocity)
- Collision detection system
- Game modes (start with cube, plan for extensibility)
- Death and respawn mechanics
- Checkpoint system (practice mode)
- Scoring and progress tracking

### 3. Level System
- **Level file format specification** (JSON schema) - This is critical for the Spec-to-Implementation Bridge capability
- Object types (blocks, spikes, portals, pads, orbs, decorations)
- Timing and positioning system (grid-based or pixel-based)
- Music synchronization approach
- Level metadata (name, author, difficulty, song)

### 4. Data Structures & Schemas
Define these as formal schemas (JSON Schema format preferred) so they can be used with the Spec-to-Implementation Bridge:
- Level format schema
- Player state schema
- Game configuration schema
- Save data schema (progress, settings, custom levels)

### 5. Architecture Design
- Game loop structure
- State management (menu, playing, paused, dead, level complete)
- Scene/screen management
- Asset loading pipeline
- Audio system (music playback, sound effects, sync)

### 6. Rendering System
- Camera/viewport behavior (follows player, look-ahead)
- Layer system (background, gameplay, foreground, UI)
- Object rendering (sprites vs. geometric shapes)
- Visual effects (particles, trails, screen shake)
- Performance considerations (object pooling, culling)

### 7. Input System
- Input sources (keyboard, mouse, touch)
- Input buffering for responsive controls
- Key binding configuration

### 8. Level Editor (Future Phase)
- Editor UI requirements
- Object placement system
- Playtest-from-editor flow
- Level export/import

### 9. Audio System
- Music playback with precise timing
- Sound effect triggers
- Music-to-gameplay synchronization strategy
- Audio asset requirements

### 10. User Interface
- Main menu
- Level select
- In-game HUD (progress bar, attempts)
- Pause menu
- Settings screen
- Results/completion screen

### 11. Progression System
- Level completion tracking
- Stars/rewards
- Unlockables (icons, colors)
- Statistics (attempts, play time)

### 12. Testing Strategy
- Unit tests for physics/collision
- Integration tests for level loading
- Visual regression tests (optional)
- Performance benchmarks

### 13. Project Structure
Recommend a folder structure that aligns with the Living Documentation system:
```
geometry-dash-clone/
├── CLAUDE.md
├── docs/
│   ├── adr/
│   ├── chronicle/
│   ├── specs/
│   ├── onboarding/
│   └── ...
├── specs/
│   ├── level-format.schema.json
│   ├── player-state.schema.json
│   └── ...
├── src/
└── ...
```

### 14. Development Phases
Break the project into clear phases:

**Phase 1: Core Engine**
- Basic game loop
- Player physics (cube mode only)
- Simple collision detection
- Single test level (hardcoded)

**Phase 2: Level System**
- Level file format implementation
- Level parser
- Multiple object types
- Level select screen

**Phase 3: Polish & Feel**
- Audio integration
- Visual effects
- Smooth camera
- UI polish

**Phase 4: Extended Features**
- Additional game modes
- Practice mode with checkpoints
- Progress saving
- More object types

**Phase 5: Level Editor** (Optional)
- In-game editor
- Level sharing

### 15. Quality Gates & Acceptance Criteria
Define what "done" looks like for each phase, knowing that Claude Code will autonomously verify:
- Test coverage requirements
- Performance benchmarks (60 FPS target)
- Complexity thresholds for critical code
- Required documentation

---

## Special Considerations for Claude Code Environment

When writing this spec, keep in mind:

1. **Spec-to-Implementation Bridge**: Define schemas formally (JSON Schema) so types can be auto-generated. The level format schema is especially important.

2. **Knowledge Graph**: Structure the architecture so relationships between systems are clear and queryable (e.g., "What affects player movement?").

3. **Code Tours**: Identify which systems should have guided code tours (game loop, collision, level loading, audio sync).

4. **Technical Debt Radar**: Define complexity thresholds for performance-critical code (physics, rendering, game loop).

5. **Autonomous Testing**: Design components to be testable in isolation. Physics calculations should be deterministic and unit-testable.

6. **Session Continuity**: Structure phases so each represents a coherent chunk of work that can be completed and documented in a session.

7. **ADRs**: Identify decisions that should be recorded as Architecture Decision Records (framework choice, collision algorithm, level format design).

---

## Output Format

Structure your specification as a single comprehensive markdown document with:
- Clear hierarchical headings
- Code blocks for schemas and examples
- Tables for structured data
- Diagrams described in text (or ASCII art)
- Cross-references between sections

The document should be immediately usable as a development guide, not a vague wishlist.

---

## Attached Reference Document

[Insert the contents of `claude-code-enhanced-capabilities.md` here, or reference it as an attachment]

---

Begin writing the specification.
