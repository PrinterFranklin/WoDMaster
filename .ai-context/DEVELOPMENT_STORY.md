# WoDMaster AI Development Context 🤖

> This document preserves the full development journey of WoDMaster, built entirely through AI pair programming. It serves as context for other developers who want to continue vibe coding on this project.

## 📖 Development Timeline

### Session 1: Project Bootstrapping & Core Architecture

The project started from scratch as a native iOS CrossFit companion app using **SwiftUI + SwiftData** (iOS 17+).

#### Initial Models Created:
- `WOD` — Workout of the Day (name, type, description, time cap, rounds, movements)
- `WODMovement` — Individual movement within a WOD (name, reps, weight, distance, calories)
- `PersonalRecord` — PR tracking (originally with a `LiftType` enum)
- `UserProfile` — User settings (fitness level, gender, weight unit)
- `WorkoutResult` + `RoundSplit` — Workout execution records

#### Initial Views:
- `MainTabView` — 4-tab navigation (WODs, PRs, History, Profile)
- `WODListView` / `WODDetailView` / `AddWODView` — WOD CRUD
- `PRListView` / `AddPRView` — PR management
- `WorkoutTimerView` / `WorkoutReportView` / `WorkoutHistoryView` — Workout execution
- `ProfileView` — User profile management

#### Initial Services:
- `ClassicWODs` — Pre-defined benchmark WODs (Fran, Murph, Grace, etc.)
- `DataSeeder` — First-launch data initialization
- `WorkoutEngine` — Timer management, scaling suggestions
- `TimeFormatter` — Time display utilities

---

### Session 2: Xcode Build Fix

**Problem**: `A build only device cannot be used to run this target`

**Solution**: Changed the run destination from a physical device to an iOS Simulator in Xcode's scheme settings.

---

### Session 3: ObservableObject Conformance Fix

**Problem**: `Type 'WorkoutEngine' does not conform to protocol 'ObservableObject'`

**Solution**: Ensured `WorkoutEngine` uses the `@Observable` macro (iOS 17+) instead of `ObservableObject` protocol, and updated all view references from `@ObservedObject`/`@StateObject` to just using it as an `@State` property.

---

### Session 4: Custom WOD Edit & Weight Unit Support

**Problem**: Custom WODs couldn't be re-edited, and weight only supported kg.

**Changes**:
- Added edit capability to custom WODs (pass `editingWOD` to `AddWODView`)
- Introduced `WeightUnit` enum (`.kg`, `.lb`) with conversion methods
- Added `WeightUnit` to `UserProfile` as user preference
- Each `WODMovement` now stores its own `weightUnit`

---

### Session 5: Runtime Crash Fix

**Problem**: App crashed when tapping "Add Movement" — `Could not cast value of type 'Swift.Optional<Any>' to 'WoDMaster.WeightUnit'`

**Root Cause**: SwiftData migration issue with the new `WeightUnit` property on `WODMovement`. Existing records had `nil` for the new field, and SwiftData couldn't cast it.

**Solution**: Added a safe computed property `movementWeightUnit` that defaults to `.kg` when `weightUnit` is nil, preventing the force-cast crash.

---

### Session 6: Weight Unit UX Improvement

**Question**: User didn't know how to switch between kg and lb in the UI.

**Answer**: Weight unit is set per-movement in the "Add Movement" sheet (segmented picker for kg/lb), and the default comes from Profile → Preferred Weight Unit setting.

---

### Session 7: Mixed kg/lb Support in Same WOD

**Requirement**: Support both kg and lb simultaneously — some movements in kg, others in lb within the same WOD.

**Changes**:
- Each `WODMovement` stores its own `weightUnit` independently
- The movement editor defaults to the user's preferred unit but can be changed per-movement
- Scaling suggestions respect per-movement units
- PR display uses the user's preferred unit
- Internal calculations always convert to kg first, then back to the display unit

---

### Session 8: Movement Library System (Major Refactor) 🏗️

**Requirement**: Movements should come from a library, not free-text input. Different movements have different editable properties (weight, distance, calories, time). PR types should be filtered based on movement characteristics.

This was the **largest single change** in the project's history.

#### New Files Created:
- `Models/MovementLibraryItem.swift` — Core model with:
  - `MovementCategory` enum (7 categories)
  - `AllowedPRType` enum (8 PR types)
  - Property flags: `hasWeight`, `hasDistance`, `hasCalories`, `hasTime`
  - `isDefault` flag for built-in vs custom movements
  - `defaultRxWeightMale/Female` for classic WOD defaults
  
- `Services/DefaultMovements.swift` — Factory with ~67 default CrossFit movements
- `Views/MovementLibraryView.swift` — Movement library management UI

#### Major Refactors:
- **`WOD.swift`** — Removed old `MovementCategory` and `Movement` model (replaced by `MovementLibraryItem`)
- **`PersonalRecord.swift`** — Replaced `LiftType` enum with `movementName: String` linking to library. Added new PR types: `maxCalories`, `maxDuration`
- **`AddWODView.swift`** — Complete rewrite: movement selection via `MovementPickerView`, conditional fields based on movement properties
- **`AddPRView.swift`** — Complete rewrite: movement selection from library, dynamic PR type filtering
- **`PRListView.swift`** — Grouped by movement name instead of `LiftType`
- **`WorkoutEngine.swift`** — Updated scaling to match by `movementName` instead of `liftType`
- **`DataSeeder.swift`** — Added `seedMovementLibrary()` method
- **`MainTabView.swift`** — Added "Movements" tab (now 5 tabs)
- **`WoDMasterApp.swift`** — Updated Schema to include `MovementLibraryItem`

#### Shared Component:
- `MovementPickerView` (in `AddPRView.swift`) — Reusable movement picker with category filter, search, and visual selection

---

### Session 9: Expand Default Movement Library (67 → 167)

**Requirement**: Add more common CrossFit movements. Default movements cannot be edited/deleted. Custom movement names cannot duplicate defaults.

#### Movements Added (by category):
| Category | Before | After |
|----------|--------|-------|
| Barbell | 23 | 35 |
| Dumbbell | 6 | 19 |
| Kettlebell | 4 | 14 |
| Gymnastics | 15 | 26 |
| Monostructural | 13 | 19 |
| Weighted Bodyweight | 9 | 22 |
| Other/Bodyweight | 13 | 32 |
| **Total** | **67** | **167** |

#### UI Protection Added:
- Default movements: 🔒 lock shield icon, no swipe actions
- Custom movements: 👤 person icon, swipe to edit/delete
- `EditCustomMovementView` — New view for editing custom movements
- Name duplicate validation (case-insensitive) in both Add and Edit views

---

### Session 10: Movement Data Architecture Discussion

**Question**: Is hardcoding 167 movements in Swift a good practice?

**Three options discussed**:
1. **JSON/Plist resource files** ⭐ Recommended — data/logic separation
2. **Remote configuration** — for post-launch dynamic updates
3. **Keep hardcoding** — acceptable for prototype phase

**Decision**: Proceed with JSON refactoring (Session 11).

---

### Session 11: JSON Resource File Refactor

**Requirement**: Migrate all 167 default movements from hardcoded Swift to JSON.

#### New Files:
- `Resources/DefaultMovements.json` — 1520-line JSON file with all 167 movements
- `Services/MovementLoader.swift` — JSON parser with `MovementDTO` (Codable) + `MovementLoader` service

#### Modified Files:
- `Services/DefaultMovements.swift` — Reduced from 407 lines to 24 lines, now delegates to `MovementLoader`

#### Architecture:
```
DefaultMovements.json → MovementLoader (DTO → Model) → DefaultMovements.all() → DataSeeder
```

#### Key Design:
- `MovementDTO` — Pure Codable struct for JSON decoding
- `MovementLoader.loadDefaultMovements(from: Bundle)` — Supports custom bundle for testing
- Zero API change — `DefaultMovements.all()` interface unchanged, `DataSeeder` unaffected

---

### Session 12: Movement Taxonomy Overhaul & WoD Data Externalization (Major Refactor) 🏗️

**Requirement**: Three-part refactor:
1. Simplify Movement categories from 7 → 3 (Lift/Gym/Cardio) with tag-based filtering
2. Externalize WoD data from hardcoded Swift to JSON
3. Integrate CloudKit Public Database for remote content updates

#### Refactor 1: Movement Classification (7 → 3 categories + 20 tags)

**Old categories**: Barbell, Dumbbell, Kettlebell, Gymnastics, Monostructural, Weighted Bodyweight, Other
**New categories**: Lift (90), Gym (58), Cardio (19)

**New `MovementTag` enum** added with 20 tags:
- Equipment: Barbell, Dumbbell, Kettlebell, Bar, Ring, Rope, Box, Machine, Jump Rope, Sled, Sandbag, Wall Ball
- Movement patterns: Squat, Pull, Push, Hinge, Core, Overhead, Carry, Olympic

All 167 movements in `DefaultMovements.json` were programmatically re-categorized with a Python migration script that:
- Mapped old categories to new ones (e.g., Barbell → Lift, Gymnastics → Gym, Monostructural → Cardio)
- Auto-assigned tags based on movement names and properties
- `MovementLibraryItem` gained a `tagsRaw` (stored as comma-separated String) + computed `tags` property

**UI update**: `MovementLibraryView` now shows a tag filter row below the category selector.

#### Refactor 2: WoD Data Externalization

**Deleted**: `Services/ClassicWODs.swift` (148-line hardcoded WoD definitions)
**Created**: `Resources/BenchmarkWODs.json` (12 benchmark WoDs as JSON data)

New types in `MovementLoader.swift`:
- `BenchmarkWODDTO` — Codable struct for WoD JSON parsing
- `BenchmarkMovementDTO` — Codable struct for WoD movement entries

Renamed throughout codebase: `isClassic` → `isBenchmark`

Key validation: `DataSeeder.seedBenchmarkWODs()` checks that every WoD movement name exists in the movement library.

#### Refactor 3: CloudKit Public Database

**Created**: `Services/CloudKitSyncService.swift` — async actor-based service

Design:
- Uses `CKContainer.publicCloudDatabase` for shared content (free, no auth)
- Version-tracked incremental sync via `UserDefaults` keys
- Two record types: `RemoteMovement`, `RemoteWOD`
- Movement name validation for remote WoDs
- Integrated into `MainTabView.onAppear`

---

### Session 13: CloudKit Availability & Local-Only Mode

**Requirement**: App should work without CloudKit configured. User doesn't have a container identifier yet.

**Changes to `CloudKitSyncService`**:
- Added `isEnabled` computed property — checks if container identifier is the placeholder
- Added `container.accountStatus()` check before sync
- `syncAll()` gracefully skips with log message when CloudKit is unavailable
- Static `containerIdentifier` property allows configuration without code changes

Result: App logs `"☁️ [CloudKit] Sync disabled — container identifier not configured. Running in local-only mode."` and continues normally.

---

### Session 14: v0.1.0 Release Preparation

**Version bump**: MARKETING_VERSION 1.0 → 0.1.0 (in project.pbxproj)

**Files updated**:
- `CHANGELOG.md` — added comprehensive v0.1.0 section
- `README.md` — updated features, project structure, first-launch description
- `CONTRIBUTING.md` — updated categories, tags, JSON examples, coding guidelines
- `.ai-context/DEVELOPMENT_STORY.md` — added Sessions 12-14, updated architecture
- `project.pbxproj` — version number update

---

## 🏗️ Architecture Overview

```
┌──────────────────────────────────────────────┐
│                 WoDMasterApp                 │
│     (SwiftData ModelContainer + Schema v2)   │
├──────────────────────────────────────────────┤
│                                              │
│  ┌─────────┐ ┌──────┐ ┌──────────┐ ┌──────┐│
│  │  WODs   │ │ PRs  │ │Movements │ │ More ││
│  │  Tab    │ │ Tab  │ │   Tab    │ │ Tabs ││
│  └────┬────┘ └──┬───┘ └────┬─────┘ └──┬───┘│
│       │         │          │           │    │
│  ┌────▼────┐ ┌──▼───┐ ┌───▼────┐          │
│  │WODList  │ │PRList│ │MovLib  │           │
│  │  View   │ │ View │ │ View   │           │
│  └────┬────┘ └──┬───┘ └───┬────┘           │
│       │         │         │                 │
│  ┌────▼─────────▼─────────▼──────┐          │
│  │     MovementPickerView        │  (shared)│
│  └───────────────────────────────┘          │
│                                              │
├──────────────────────────────────────────────┤
│  Models:                                     │
│  ├── WOD + WODMovement (isBenchmark flag)   │
│  ├── MovementLibraryItem (3 cats + tags)    │
│  ├── PersonalRecord                         │
│  ├── UserProfile                            │
│  └── WorkoutResult + RoundSplit             │
├──────────────────────────────────────────────┤
│  Services:                                   │
│  ├── MovementLoader (JSON → Model)          │
│  ├── DefaultMovements (factory)             │
│  ├── CloudKitSyncService (remote updates)   │
│  ├── DataSeeder (first-launch init)         │
│  └── WorkoutEngine (timer + scaling)        │
├──────────────────────────────────────────────┤
│  Resources:                                  │
│  ├── DefaultMovements.json (167 movements)  │
│  └── BenchmarkWODs.json (12 benchmark WoDs) │
├──────────────────────────────────────────────┤
│  Remote (Optional):                          │
│  └── CloudKit Public DB                     │
│      ├── RemoteMovement records             │
│      └── RemoteWOD records                  │
└──────────────────────────────────────────────┘
```

## 🔑 Key Design Decisions

### 1. SwiftData over Core Data
- Chosen for modern Swift-native API
- `@Model` macro simplifies model definitions
- Requires iOS 17+ (acceptable for new project)

### 2. Per-Movement Weight Unit
- Each `WODMovement` stores its own `weightUnit`
- Allows mixing kg/lb in the same WOD (common in international gyms)
- Internal calculations always normalize to kg

### 3. Movement Library as Source of Truth
- All movements (in WODs and PRs) reference `MovementLibraryItem` by name
- Property flags (`hasWeight`, `hasDistance`, etc.) drive dynamic UI
- PR types are filtered based on movement's `allowedPRTypes`

### 4. JSON for Default Movement Data
- 167 movements in `DefaultMovements.json`
- `MovementDTO` (Codable) → `MovementLibraryItem` (@Model) conversion
- Bundle-based loading supports testing with custom fixtures
- Easy to extend without code changes

### 5. Scaling Algorithm
- Base: fitness level multiplier × gender factor × Rx weight
- PR-aware: if user has relevant PR, use ~65% of 1RM
- Per-movement unit conversion for display

### 6. Movement Tag System
- Tags stored as comma-separated string in SwiftData (`tagsRaw`)
- Computed `tags` property provides `[MovementTag]` array
- Equipment tags (Barbell, Dumbbell...) replace old fine-grained categories
- Pattern tags (Squat, Pull, Push...) enable cross-category filtering

### 7. WoD Data as JSON
- Benchmark WoDs in `BenchmarkWODs.json`, not hardcoded in Swift
- Movement names validated against `DefaultMovements.json` at seed time
- Same DTO→Model pattern as movements (`BenchmarkWODDTO` → `WOD`)

### 8. CloudKit Graceful Degradation
- `CloudKitSyncService` is an `actor` (thread-safe)
- Container identifier check skips sync when unconfigured
- `accountStatus()` check handles no-iCloud scenarios
- All sync failures are non-fatal (log + skip)

## 🔧 Common Patterns

### Adding a New Default Movement
Edit `Resources/DefaultMovements.json`:
```json
{
  "name": "New Movement",
  "category": "Barbell",
  "hasWeight": true,
  "hasDistance": false,
  "hasCalories": false,
  "hasTime": false,
  "allowedPRTypes": ["1RM", "3RM"],
  "defaultRxWeightMale": 60,
  "defaultRxWeightFemale": 40
}
```

### Available Categories (3)
| Category | Description |
|----------|-------------|
| `Lift` | Barbell, dumbbell, kettlebell, weighted movements |
| `Gym` | Bodyweight, gymnastics movements |
| `Cardio` | Running, rowing, cycling, jump rope, etc. |

### Available Tags (20)
**Equipment**: `Barbell`, `Dumbbell`, `Kettlebell`, `Bar`, `Ring`, `Rope`, `Box`, `Machine`, `Jump Rope`, `Sled`, `Sandbag`, `Wall Ball`
**Pattern**: `Squat`, `Pull`, `Push`, `Hinge`, `Core`, `Overhead`, `Carry`, `Olympic`

### Available PR Types
`1RM`, `3RM`, `5RM`, `Max Reps`, `Max Distance`, `Best Time`, `Max Calories`, `Max Duration`

### Adding a New WOD Type
1. Add case to `WODType` enum in `WOD.swift`
2. Add icon mapping
3. Handle in `AddWODView` settings section
4. Handle in `WorkoutEngine` timer logic

### Adding a Benchmark WoD
Edit `Resources/BenchmarkWODs.json`:
```json
{
  "name": "WoD Name",
  "type": "forTime",
  "description": "Description here",
  "timeCap": 600,
  "movements": [
    {
      "movementName": "Thruster",
      "reps": 21,
      "weight": 43.0,
      "weightUnit": "kg"
    }
  ]
}
```
> Note: `movementName` must match an entry in `DefaultMovements.json`.

## ⚠️ Known Limitations (v0.1.0)

1. **Schema version management added** — v0.1.0 will reset data on upgrade from v0.0.1
2. **CloudKit not yet configured** — requires Apple Developer account and container setup
3. **No image assets** — App icon and screenshots not yet designed
4. **No localization** — English only
5. **No unit tests** — Test files exist but are placeholder only
6. **Movement name-based linking** — PRs and WODs reference movements by name string, not ID (fragile if names change)

## 💡 Future Ideas (discussed but not implemented)

- Remote movement library updates (Firebase Remote Config or custom API)
- Localized movement names (`DefaultMovements_zh.json`)
- HealthKit integration for workout data
- Social features (share WODs, compare PRs)
- WOD generator / randomizer
- Apple Watch companion for timer
- Offline-first with CloudKit sync
- iCloud Private Database for user data sync (PR records, workout results)
- Monthly subscription model for premium content

## 🤝 Continuing Development

To continue vibe coding on this project:

1. **Read this document** to understand the full context
2. **Explore the codebase** — it's well-structured and commented
3. **Check `CHANGELOG.md`** for the latest state
4. **Use the JSON files** to add/modify default movements and benchmark WoDs
5. **Follow the patterns** — SwiftData models, SwiftUI views, service layer
6. **CloudKit setup**: See `CloudKitSyncService.swift` for configuration instructions

The project has zero external dependencies and builds with just Xcode 15+.
