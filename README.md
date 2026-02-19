<div align="center">

# ♠️ حاسبة بنت السبيت

# SbeetCalc

A sleek, modern score-tracking app for the popular **(بنت السبيت)** card game — built with Flutter.

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20|%20iOS%20|%20Web%20|%20Desktop-brightgreen)]()
[![License](https://img.shields.io/badge/License-Private-red)]()

</div>

---

## Overview
(SbeetCalc)
is a beautifully crafted score-keeping companion for the classic card game widely played in the Arab world. It eliminates the need for pen-and-paper scoring with an intuitive interface designed for quick, accurate score tracking during live gameplay.

---

## Features

### Game Setup
- Support for **4 or 5 players**
- Custom **player names** with Arabic/English input
- Configurable **point limit** (default: 152)

### Dual Scoring Modes

| Mode | Description |
|------|-------------|
| **Card Mode**  | Tap or drag to select specific hearts, بنت السبيت (Queen of Spades), عشرة الديمن (10 of Diamonds). Scores are calculated automatically. |
| **Manual Mode**  | Directly enter numeric scores per player for quick input. |

### Live Dashboard
- Real-time **round-by-round** score table
- **Running totals** per player
- Automatic **game-over detection** when a player reaches the point limit
  
---

##  Architecture

```
lib/
├── main.dart                          # App entry, theme configuration, routing
└── features/
    └── scoring/
        ├── data/                      # Data layer (models)
        └── presentation/
            ├── providers/
            │   └── game_provider.dart # State management (ChangeNotifier + Provider)
            ├── screens/
            │   ├── main_menu_screen.dart       # Landing screen with logo & theme toggle
            │   ├── home_screen.dart            # Game setup (players, point limit)
            │   ├── player_selection_screen.dart # Select player to score
            │   ├── score_entry_screen.dart      # Card/manual score entry
            │   └── dashboard_screen.dart        # Live scoreboard
            ├── widgets/
            │   └── keyboard_action_bar.dart    # Custom keyboard toolbar
            └── utils/
                └── number_utils.dart          # Arabic/English numeral parsing
```

**State Management:** [Provider](https://pub.dev/packages/provider) with a single `GameProvider` (ChangeNotifier) managing game state, scoring logic, and theme preference.

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) `^3.10.7`
- Dart SDK `^3.x`

### Installation

```bash
# Clone the repository
git clone https://github.com/AkhmDev/bent_al_sabeet.git
cd bent_al_sabeet/bent_al_sabeet

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Build for Production

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```
---

## Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform UI framework |
| **Provider** | State management |
| **Material 3** | Design system |
| **Camel Font** | Custom Arabic typography |

---

## 📄 License

This project is private and not licensed for redistribution.

---

<div align="center">

</div>
