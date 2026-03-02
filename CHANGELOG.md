# Changelog

All notable changes to WoDMaster will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-03-02

### 🚀 Major Refactor — Movement Taxonomy, Benchmark WoDs & CloudKit

A major architecture overhaul that simplifies movement classification, externalizes WoD data, and adds CloudKit Public Database support for remote content updates.

### Changed

#### Movement Category Simplification (7 → 3)
- **Replaced 7 categories** (Barbell, Dumbbell, Kettlebell, Gymnastics, Monostructural, Weighted Bodyweight, Other) **with 3 clear categories**:
  - **Lift** (90 movements) — Barbell, dumbbell, kettlebell, and other loaded movements
  - **Gym** (58 movements) — Bodyweight and gymnastics movements
  - **Cardio** (19 movements) — Running, rowing, cycling, jump rope, etc.

#### Movement Tag System (New)
- Added **20 equipment & movement-pattern tags**: Barbell, Dumbbell, Kettlebell, Olympic, Squat, Pull, Push, Hinge, Core, Overhead, Bar, Ring, Rope, Box, Machine, Jump Rope, Sled, Sandbag, Wall Ball, Carry
- Tags support **multi-select filtering** in the Movement Library UI
- Each movement in `DefaultMovements.json` now includes a `tags` array

#### WoD Data Externalization
- **Removed `ClassicWODs.swift`** — benchmark WoDs are no longer hardcoded in Swift
- **Added `BenchmarkWODs.json`** — 12 benchmark WoDs defined as pure JSON data
- WoD movements now **reference the movement library by name** (validated at seed time)
- Renamed `isClassic` → `isBenchmark` throughout all models and views

### Added

#### CloudKit Public Database Integration
- **`CloudKitSyncService`** — async actor-based service for remote content updates
- Fetches new movements and WoDs from CloudKit Public Database
- **Version-tracked incremental sync** — only fetches records newer than last known version
- **Graceful degradation** — app runs in local-only mode when CloudKit is not configured
- iCloud account availability check before attempting sync
- Movement name validation for remotely synced WoDs

#### Schema Version Management
- Added schema version tracking in `WoDMasterApp.swift`
- Automatic data store reset on breaking schema changes (v1 → v2)
- `UserDefaults`-based version persistence

#### Data Validation
- `DataSeeder.seedBenchmarkWODs()` validates that all WoD movement names exist in the movement library
- CloudKit sync validates remote WoD movements against local library before importing

### Removed
- `Services/ClassicWODs.swift` — replaced by `Resources/BenchmarkWODs.json`
- `MovementCategory` cases: `.barbell`, `.dumbbell`, `.kettlebell`, `.gymnastics`, `.monostructural`, `.weightedBodyweight`, `.other`

### Migration Notes
- ⚠️ **Breaking schema change** — first launch on v0.1.0 will reset local data (movements, WoDs re-seeded from updated JSON)
- Users should back up any custom WoDs before upgrading
- CloudKit sync is disabled by default until a container identifier is configured

---

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
