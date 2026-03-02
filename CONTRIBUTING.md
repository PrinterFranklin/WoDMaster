# Contributing to WoDMaster 🤝

Thank you for your interest in contributing to WoDMaster! This document provides guidelines and workflows to help you get started.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Branch Strategy](#branch-strategy)
- [Development Workflow](#development-workflow)
- [Contributing Methods](#contributing-methods)
- [Commit Convention](#commit-convention)
- [Adding Movements](#adding-movements)
- [Code Style](#code-style)
- [Vibe Coding Tips](#vibe-coding-tips)
- [Issue Guidelines](#issue-guidelines)

---

## Code of Conduct

- Be respectful and constructive in all interactions.
- Focus on the code, not the person.
- Welcome newcomers and help them get started.

---

## Getting Started

### Prerequisites

- **Xcode 15.0+**
- **iOS 17.0+** simulator or device
- macOS Sonoma 14.0+ (for Xcode 15)

### Setup

```bash
# Fork the repository on GitHub, then:
git clone https://github.com/YOUR_USERNAME/WoDMaster.git
cd WoDMaster

# Add upstream remote
git remote add upstream https://github.com/PrinterFranklin/WoDMaster.git

# Open in Xcode
open WoDMaster.xcodeproj
```

> **Note**: No external dependencies — the project uses only Apple frameworks (SwiftUI + SwiftData).

---

## Branch Strategy

We use a **simplified GitHub Flow + Release branches** model:

```
main ──────●────────────────●──────────── (always releasable)
            \              /
develop ─────●────●───●───●───●────────── (integration branch)
              \  /       \
feature/* ─────●          ● ── bugfix/*
```

### Branch Roles

| Branch | Purpose | Lifetime |
|--------|---------|----------|
| `main` | Always releasable; every merge = a release | Permanent |
| `develop` | Daily development integration | Permanent |
| `feature/*` | New feature development | Temporary — delete after merge |
| `bugfix/*` | Bug fixes | Temporary — delete after merge |
| `release/vX.Y.Z` | Release preparation; feature freeze, bug fixes only | Temporary — delete after release |
| `hotfix/*` | Urgent production fixes (branch from `main`) | Temporary — delete after merge |

### Naming Convention

Prefer linking branch names to GitHub Issues:

```
feature/12-movement-history
bugfix/15-unit-conversion-error
hotfix/20-crash-on-launch
release/v0.1.0
```

---

## Development Workflow

### 1. Feature Development

```bash
# Sync with upstream
git fetch upstream
git checkout develop
git merge upstream/develop

# Create feature branch
git checkout -b feature/your-feature-name

# Make changes, then commit
git add .
git commit -m "feat: add your feature description"

# Push and create PR → develop
git push origin feature/your-feature-name
```

Then open a **Pull Request** targeting `develop` on GitHub.

### 2. Release Process

```bash
# Create release branch from develop
git checkout develop
git checkout -b release/v0.1.0

# Update version number, CHANGELOG.md, etc.
# Test thoroughly, fix bugs on this branch

# When ready, merge to main and tag
git checkout main
git merge release/v0.1.0
git tag -a v0.1.0 -m "Release v0.1.0"
git push origin main --tags

# Merge back to develop
git checkout develop
git merge release/v0.1.0
```

### 3. Hotfix (Urgent Production Fix)

```bash
# Branch from main
git checkout main
git checkout -b hotfix/critical-bug

# Fix the issue, then merge to both main and develop
git checkout main
git merge hotfix/critical-bug
git tag -a v0.0.2 -m "Hotfix v0.0.2"

git checkout develop
git merge hotfix/critical-bug
```

---

## Contributing Methods

### Method 1: Fork + Pull Request (Recommended)

This is the standard GitHub collaboration workflow:

1. **Fork** the repository on GitHub
2. **Clone** your fork locally
3. **Create** a feature branch from `develop`
4. **Commit** your changes with clear messages
5. **Push** to your fork
6. **Open a Pull Request** targeting `develop`

### Method 2: Patch Mode (Advanced)

For contributors who prefer working with patches:

```bash
# Generate patch from your changes
git format-patch develop..HEAD --stdout > my-feature.patch

# Send the patch file via GitHub Issue or email

# Maintainer reviews and applies:
git am < my-feature.patch
```

### PR Checklist

Before submitting your Pull Request, please ensure:

- [ ] Code builds without errors or warnings in Xcode
- [ ] New features are tested on iOS 17+ simulator
- [ ] UI follows existing SwiftUI patterns in the project
- [ ] Default movements in `DefaultMovements.json` are not modified (add new movements instead)
- [ ] Commit messages follow the [Commit Convention](#commit-convention)
- [ ] CHANGELOG.md is updated (for feature/bugfix PRs)

---

## Commit Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]
```

### Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation changes |
| `style` | Code style changes (formatting, no logic change) |
| `refactor` | Code refactoring (no feature or fix) |
| `test` | Adding or updating tests |
| `chore` | Build process, CI, or tooling changes |

### Examples

```
feat(movements): add 10 new kettlebell movements
fix(timer): resolve countdown not stopping on background
docs: update README with new project structure
refactor(scaling): extract scaling logic into separate service
```

---

## Adding Movements

To add new CrossFit movements to the default library:

1. Edit `WoDMaster/Resources/DefaultMovements.json`
2. Follow the existing JSON structure:

```json
{
  "name": "Movement Name",
  "category": "Barbell",
  "hasWeight": true,
  "hasDistance": false,
  "hasCalories": false,
  "hasTime": false,
  "prTypes": ["oneRM", "threeRM", "fiveRM"]
}
```

### Available Categories
`Barbell` · `Dumbbell` · `Kettlebell` · `Gymnastics` · `Monostructural` · `Weighted Bodyweight` · `Other`

### PR Types
`oneRM` · `threeRM` · `fiveRM` · `maxReps` · `maxDistance` · `maxCalories` · `maxDuration` · `bestTime`

### Guidelines
- Choose **property flags** (`hasWeight`, `hasDistance`, etc.) based on the movement's real-world characteristics
- Choose **PR types** that make sense — e.g., running movements should have `bestTime`, not `oneRM`
- Movement names must be **unique** and cannot conflict with existing default movements

---

## Code Style

### General

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI (no UIKit unless absolutely necessary)
- **Data Layer**: SwiftData (no Core Data or third-party ORMs)
- **Minimum Target**: iOS 17.0

### Conventions

- Use **SwiftUI property wrappers** (`@State`, `@Bindable`, `@Query`, `@Environment`) appropriately
- Keep Views **declarative** — extract complex logic into helper methods or services
- Use `enum` for finite sets of options (WOD types, movement categories, etc.)
- Prefer **value types** (structs/enums) for data that doesn't need persistence
- Use `@Model` classes only for SwiftData entities

### File Organization

```
Models/          → SwiftData @Model classes
Views/           → SwiftUI views, grouped by feature
Services/        → Business logic, data loading, engines
Resources/       → JSON data files, assets
Utils/           → Helper functions and extensions
```

### Naming

- Views: `SomethingView.swift`
- Models: `SomethingModel.swift` or just `Something.swift`
- Services: `SomethingService.swift` or descriptive name (`WorkoutEngine.swift`)

---

## Vibe Coding Tips

This project was **100% vibe coded** with AI pair programming. If you want to continue in this style:

1. **Read the context first**: Check `.ai-context/DEVELOPMENT_STORY.md` for the full development journey
2. **SwiftData quirks**: Be aware of SwiftData's relationship handling — it can be tricky with arrays and optional relationships
3. **Movement data**: Lives in `DefaultMovements.json` — add new movements there, not in Swift code
4. **Unit system**: The app supports both kg and lb, even mixed within the same WOD — always handle unit conversion
5. **PR types are dynamic**: They're filtered based on movement properties, so make sure new movements have correct flags

---

## Issue Guidelines

### Bug Reports

Please include:
- iOS version and device/simulator
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable

### Feature Requests

Please include:
- Clear description of the feature
- Use case / motivation
- Mockups or examples (if applicable)

### Labels

| Label | Description |
|-------|-------------|
| `bug` | Something isn't working |
| `enhancement` | New feature or improvement |
| `good first issue` | Good for newcomers |
| `movement-data` | Related to movement library |
| `help wanted` | Extra attention needed |

---

## Versioning

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (`1.0.0`): First stable / App Store release
- **MINOR** (`0.1.0`): New features (e.g., workout history, movement search)
- **PATCH** (`0.0.2`): Bug fixes

---

## Questions?

- Open a [GitHub Issue](https://github.com/PrinterFranklin/WoDMaster/issues)
- Check existing issues and discussions before creating new ones

Thank you for helping make WoDMaster better! 💪🏋️‍♂️
