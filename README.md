# WoDMaster 🏋️‍♂️

> A native iOS app for CrossFit athletes to manage WODs (Workout of the Day), track personal records, and get personalized scaling suggestions.

**Built with SwiftUI + SwiftData | iOS 17+ | 100% Vibe Coded with AI 🤖**

## ✨ Features

### 🔥 WOD Management
- Browse **12 benchmark WODs** (Fran, Murph, Grace, Helen, Diane, etc.)
- Create **custom WODs** with support for:
  - For Time, AMRAP, EMOM, Tabata, Chipper, Ladder, Custom types
  - Configurable time caps, rounds, and EMOM intervals
- Full **edit & delete** support for custom WODs
- WoD movements **reference the movement library** — validated at seed time

### 💪 Movement Library
- **167 built-in CrossFit movements** across 3 categories:
  - **Lift** (90) — Barbell, dumbbell, kettlebell, and loaded movements
  - **Gym** (58) — Bodyweight and gymnastics movements
  - **Cardio** (19) — Running, rowing, cycling, jump rope, etc.
- **20 filterable tags**: Barbell, Dumbbell, Kettlebell, Olympic, Squat, Pull, Push, Hinge, Core, Overhead, Bar, Ring, Rope, Box, Machine, Jump Rope, Sled, Sandbag, Wall Ball, Carry
- Each movement has **smart property flags**: Weight, Distance, Calories, Time
- **Add custom movements** with configurable properties, PR types, and tags
- Default movements are **protected** (cannot be edited/deleted)
- Data stored in `DefaultMovements.json` — easy to maintain and extend

### ☁️ CloudKit Sync (Optional)
- **CloudKit Public Database** integration for remote content updates
- New movements and WoDs pushed via CloudKit Dashboard
- **Version-tracked incremental sync** — only fetches what's new
- **Graceful local-only mode** — app works perfectly without CloudKit configured
- iCloud account availability check before sync

### 🏆 Personal Records (PR)
- Record PRs for any movement from the library
- **Dynamic PR types** based on movement characteristics:
  - 1RM / 3RM / 5RM for strength movements
  - Best Time for cardio/distance movements
  - Max Reps, Max Distance, Max Calories, Max Duration
- Smart input with quick-adjust buttons and unit-aware display

### ⏱️ Workout Timer
- Built-in **countdown timer** with round tracking
- **Round split recording** for detailed performance tracking
- Post-workout **report generation** with scaling suggestions

### 📊 Scaling Suggestions
- **AI-powered scaling** based on your fitness level and PRs
- Uses ~65% of 1RM for metabolic conditioning recommendations
- Gender-aware scaling factors
- Supports both **kg and lb** — even mixed within the same WOD

### 👤 User Profile
- Configurable fitness level (Beginner → Elite)
- Gender and preferred weight unit settings
- Profile-driven personalized experience

## 📱 Screenshots

*Coming soon*

## 🛠️ Tech Stack

| Component | Technology |
|-----------|-----------|
| UI Framework | SwiftUI |
| Data Persistence | SwiftData |
| Minimum iOS | 17.0 |
| Architecture | MVVM-ish (Views + Models + Services) |
| Language | Swift 5.9+ |
| Movement Data | JSON resource file with Codable DTO |

## 🚀 Getting Started

### Prerequisites
- **Xcode 15.0+**
- **iOS 17.0+** simulator or device
- macOS Sonoma 14.0+ (for Xcode 15)

### Build & Run
```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/WoDMaster.git
cd WoDMaster

# Open in Xcode
open WoDMaster/WoDMaster.xcodeproj

# Build & Run (⌘+R) on a simulator or device
```

> **Note**: No external dependencies — the project uses only Apple frameworks (SwiftUI + SwiftData).

### First Launch
On first launch, the app automatically:
1. Seeds **167 default CrossFit movements** (3 categories, 20 tags) from `DefaultMovements.json`
2. Seeds **12 benchmark WoDs** (Fran, Murph, Grace, etc.) from `BenchmarkWODs.json`
3. Initializes a **default user profile**
4. Optionally syncs new content from **CloudKit Public Database** (if configured)

## 📁 Project Structure

```
WoDMaster/
├── WoDMasterApp.swift            # App entry point, SwiftData schema & version management
├── ContentView.swift             # Root view
├── Models/
│   ├── WOD.swift                 # WOD & WODMovement models (isBenchmark flag)
│   ├── MovementLibraryItem.swift # Movement library: 3 categories + 20 tags
│   ├── PersonalRecord.swift      # PR model with dynamic types
│   ├── UserProfile.swift         # User profile & settings
│   └── WorkoutResult.swift       # Workout result & round splits
├── Views/
│   ├── MainTabView.swift         # Tab navigation (5 tabs) + CloudKit sync
│   ├── MovementLibraryView.swift # Movement library with tag filtering
│   ├── WOD/
│   │   ├── WODListView.swift     # WOD list with benchmark/custom sections
│   │   ├── WODDetailView.swift   # WOD detail with scaling suggestions
│   │   └── AddWODView.swift      # Create/edit WOD with movement picker
│   ├── PR/
│   │   ├── PRListView.swift      # PR list grouped by movement
│   │   └── AddPRView.swift       # Add PR with dynamic type filtering
│   ├── Workout/
│   │   ├── WorkoutTimerView.swift    # Workout timer & execution
│   │   ├── WorkoutReportView.swift   # Post-workout report
│   │   └── WorkoutHistoryView.swift  # Workout history
│   └── Profile/
│       └── ProfileView.swift     # User profile settings
├── Services/
│   ├── DefaultMovements.swift    # Loads movements & WoDs from JSON
│   ├── MovementLoader.swift      # JSON parser (DTO → Model) for movements & WoDs
│   ├── CloudKitSyncService.swift # CloudKit Public DB sync (optional)
│   ├── DataSeeder.swift          # First-launch data initialization
│   └── WorkoutEngine.swift       # Timer engine & scaling logic
├── Resources/
│   ├── DefaultMovements.json     # 167 movements (3 categories, 20 tags)
│   └── BenchmarkWODs.json        # 12 benchmark WoDs as JSON data
└── Utils/
    └── TimeFormatter.swift       # Time formatting utilities
```

## 🤖 AI Development Context

This project was **100% vibe coded** — built entirely through conversational AI pair programming. The full development context is preserved in the `.ai-context/` directory for other developers to continue vibe coding.

See [`.ai-context/DEVELOPMENT_STORY.md`](.ai-context/DEVELOPMENT_STORY.md) for the complete development journey.

## 🔄 Contributing

We welcome contributions! Please read our **[Contributing Guide](CONTRIBUTING.md)** for detailed information on:

- 🌿 **Branch strategy** — GitHub Flow + Release branches
- 🔀 **Development workflow** — feature, release, and hotfix processes
- 🤝 **How to contribute** — Fork + PR or Patch mode
- 📝 **Commit convention** — Conventional Commits standard
- 💡 **Code style** — SwiftUI + SwiftData best practices
- 🏋️ **Adding movements** — how to extend the movement library

### Quick Start

```bash
# Fork → Clone → Branch → Code → PR
git checkout develop
git checkout -b feature/awesome-feature
# Make your changes...
git commit -m "feat: add awesome feature"
git push origin feature/awesome-feature
# Open a PR → develop
```

## 📋 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with ❤️ for the CrossFit community
- Powered by AI pair programming
- Movement data based on official CrossFit movement standards
