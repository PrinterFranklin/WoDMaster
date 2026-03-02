# Changelog

All notable changes to WoDMaster will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2026-03-02

### 🎉 Initial Release

The first open-source release of WoDMaster — a native iOS CrossFit companion app built entirely through AI pair programming (vibe coding).

### Added

#### Core Data Models
- `WOD` and `WODMovement` — Workout of the Day with typed movements
- `MovementLibraryItem` — Movement library with property flags and PR type definitions
- `PersonalRecord` — Dynamic PR tracking with movement-specific types
- `UserProfile` — User settings (fitness level, gender, weight unit)
- `WorkoutResult` and `RoundSplit` — Workout execution tracking

#### WOD Management
- Classic benchmark WODs pre-loaded (Fran, Murph, Grace, Helen, etc.)
- Custom WOD creation with full edit support
- Support for 7 WOD types: For Time, AMRAP, EMOM, Tabata, Chipper, Ladder, Custom
- Configurable time caps, rounds, and EMOM intervals

#### Movement Library
- **167 default CrossFit movements** in 7 categories
- Movement data stored in `DefaultMovements.json` (decoupled from code)
- `MovementLoader` service with Codable DTO pattern for JSON parsing
- Each movement defines: `hasWeight`, `hasDistance`, `hasCalories`, `hasTime`
- Each movement specifies allowed PR types (1RM, Max Reps, Best Time, etc.)
- User can add custom movements (with duplicate name protection)
- Default movements are read-only (lock shield icon)
- Custom movements support full edit and delete

#### Personal Records
- PR recording linked to movement library
- Dynamic PR type filtering based on movement properties
- Quick-adjust value input with smart increment buttons
- Support for weight-based, time-based, rep-based, distance-based, and calorie-based PRs

#### Workout Execution
- Countdown timer with audio/visual cues
- Round split recording during workout
- Post-workout report with performance summary

#### Scaling Suggestions
- Personalized scaling based on fitness level and gender
- PR-aware scaling (~65% of 1RM for met-con)
- Supports both kg and lb with per-movement unit selection

#### Weight Unit System
- Full support for both **kg** and **lb**
- Per-movement weight unit selection (mix kg/lb in the same WOD)
- Profile-level default weight unit preference
- Proper conversion for storage (kg internal) and display

#### UI/UX
- 5-tab navigation: WODs, PRs, Movements, History, Profile
- Orange-themed CrossFit aesthetic
- Category filtering with horizontal chip selectors
- Search functionality in movement library and pickers
- Swipe actions for custom movement edit/delete

### Architecture
- **SwiftUI** + **SwiftData** (iOS 17+)
- Zero external dependencies
- JSON-based movement data with `MovementLoader` service
- `DataSeeder` for first-launch initialization
- `WorkoutEngine` for timer management and scaling logic

### Developer Experience
- `.ai-context/` directory with full AI development context
- Comprehensive README with project structure documentation
- MIT License for open-source distribution
