# WoDMaster 🏋️‍♂️

> A native iOS app for CrossFit athletes to manage WODs (Workout of the Day), track personal records, and get personalized scaling suggestions.

**Built with SwiftUI + SwiftData | iOS 17+ | 100% Vibe Coded with AI 🤖**

## ✨ Features

### 🔥 WOD Management
- Browse **classic benchmark WODs** (Fran, Murph, Grace, etc.)
- Create **custom WODs** with support for:
  - For Time, AMRAP, EMOM, Tabata, Chipper, Ladder, Custom types
  - Configurable time caps, rounds, and EMOM intervals
- Full **edit & delete** support for custom WODs

### 💪 Movement Library
- **167 built-in CrossFit movements** across 7 categories:
  - Barbell (35) · Dumbbell (19) · Kettlebell (14) · Gymnastics (26)
  - Monostructural (19) · Weighted Bodyweight (22) · Other/Bodyweight (32)
- Each movement has **smart property flags**: Weight, Distance, Calories, Time
- **Add custom movements** with configurable properties and PR types
- Default movements are **protected** (cannot be edited/deleted)
- Data stored in `DefaultMovements.json` — easy to maintain and extend

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
1. Seeds **167 default CrossFit movements** from `DefaultMovements.json`
2. Creates **classic benchmark WODs** (Fran, Murph, Grace, etc.)
3. Initializes a **default user profile**

## 📁 Project Structure

```
WoDMaster/
├── WoDMasterApp.swift            # App entry point & SwiftData schema
├── ContentView.swift             # Root view
├── Models/
│   ├── WOD.swift                 # WOD & WODMovement models
│   ├── MovementLibraryItem.swift # Movement library model & enums
│   ├── PersonalRecord.swift      # PR model with dynamic types
│   ├── UserProfile.swift         # User profile & settings
│   └── WorkoutResult.swift       # Workout result & round splits
├── Views/
│   ├── MainTabView.swift         # Tab navigation (5 tabs)
│   ├── MovementLibraryView.swift # Movement library management
│   ├── WOD/
│   │   ├── WODListView.swift     # WOD list with classic/custom sections
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
│   ├── DefaultMovements.swift    # Loads defaults from JSON
│   ├── MovementLoader.swift      # JSON parser (DTO → Model)
│   ├── ClassicWODs.swift         # Classic benchmark WOD definitions
│   ├── DataSeeder.swift          # First-launch data initialization
│   └── WorkoutEngine.swift       # Timer engine & scaling logic
├── Resources/
│   └── DefaultMovements.json     # 167 movements as JSON data
└── Utils/
    └── TimeFormatter.swift       # Time formatting utilities
```

## 🤖 AI Development Context

This project was **100% vibe coded** — built entirely through conversational AI pair programming. The full development context is preserved in the `.ai-context/` directory for other developers to continue vibe coding.

See [`.ai-context/DEVELOPMENT_STORY.md`](.ai-context/DEVELOPMENT_STORY.md) for the complete development journey.

## 🔄 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/awesome-feature`)
3. Commit your changes (`git commit -m 'Add awesome feature'`)
4. Push to the branch (`git push origin feature/awesome-feature`)
5. Open a Pull Request

### Vibe Coding Tips
- Read `.ai-context/DEVELOPMENT_STORY.md` to understand the full context
- The project uses **SwiftData** — no Core Data or third-party ORMs
- Movement data lives in `DefaultMovements.json` — add new movements there
- All PR types are dynamically filtered based on movement properties

## 📋 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with ❤️ for the CrossFit community
- Powered by AI pair programming
- Movement data based on official CrossFit movement standards
