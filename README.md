# Sputify

A modern Flutter music streaming app that delivers an exceptional music discovery and playback experience. Built with **MVVM architecture** and **GetX** for state management, featuring animated gradients, glassmorphism effects, and seamless navigation.

## 💡 App Idea

**Sputify** is a music streaming application that allows users to discover, search, and play music from the iTunes catalog. Features include:

- Music discovery across multiple genres (rock, pop, love, dance, jazz, classical, electronic)
- Real-time search for songs, artists, and albums
- Full-featured audio player with advanced controls
- Favorites management with persistent storage
- Customizable themes, audio quality, and playback preferences

## 🏗️ Architecture

**MVVM Pattern:**
- **Models**: Data structures (SongModel)
- **Views**: UI components
- **Controllers**: GetX Controllers managing business logic and state
- **Services**: API calls and local storage

```
Views → Controllers → Services
```

**Controllers:**
- `MusicController`: Song search, favorites, and music data
- `PlayerController`: Audio playback, playlist, and player state
- `ThemeController`: Theme preferences and switching
- `SettingsController`: App settings and preferences

## ✨ Features

### 🎨 UI/UX Design
- **Modern Interface**: Animated gradients, glassmorphism cards, wave effects
- **Theme System**: Dark/light mode with persistent preferences
- **Responsive**: Optimized for various screen sizes
- **Smooth Animations**: Hero animations, fade transitions, rotating artwork

### 🎵 Music Features
- **Search & Discovery**: Real-time search with iTunes API integration
- **Audio Player**: Full-featured player with play/pause, seek, volume control
- **Playback Controls**: Repeat modes, shuffle, next/previous navigation
- **Mini Player**: Compact bottom player with quick access
- **Favorites**: One-tap favorites with real-time sync across views

### ⚙️ Settings
- Audio quality settings (Low, Medium, High, Very High)
- Playback preferences (repeat, shuffle)
- Theme customization
- Cache management

## 🛠️ Technical Stack

### State Management & Routing
- **GetX (^4.6.6)**: Reactive state management and routing
  - `Obx` widgets for automatic UI updates
  - Dependency injection with `Get.put()` and `Get.find()`
  - Simple navigation methods

### Data & Storage
- **http (^1.1.0)**: HTTP client for API requests
- **shared_preferences (^2.2.2)**: Local data persistence

### Media & UI
- **audioplayers (^5.2.1)**: Audio playback
- **cached_network_image (^3.3.0)**: Image caching for album artwork

## 🔌 Backend Integration

**iTunes Search API:**
- **Base URL**: `https://itunes.apple.com`
- **Endpoint**: `/search?term={query}&media=music&entity=song&limit=50`
- **Features**: Real-time search, error handling, timeout management (30s)
- **Data Flow**: API → Service → Controller → View (reactive updates)

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point & theme config
├── models/
│   └── song_model.dart      # Song data model
├── routes/
│   └── app_pages.dart       # GetX route definitions
├── services/
│   ├── api_service.dart     # iTunes API integration
│   └── storage_service.dart # Local storage (SharedPreferences)
├── controllers/
│   ├── music_controller.dart    # MusicController
│   ├── player_controller.dart   # PlayerController
│   ├── theme_controller.dart    # ThemeController
│   └── settings_controller.dart # SettingsController
├── views/
│   ├── splash_view.dart     # Splash screen
│   ├── home_view.dart       # Home with top songs
│   ├── search_view.dart     # Search interface
│   ├── player_view.dart     # Full-screen player
│   ├── favorites_view.dart  # Favorites collection
│   ├── settings_view.dart   # Settings
│   └── about_view.dart      # App information
└── widgets/
    ├── app_drawer.dart      # Navigation drawer
    └── mini_player.dart     # Compact player widget
```

## 📱 UI/UX Walkthrough

1. **Splash Screen**: Centered logo with gradient background, auto-navigates to home
2. **Home View**: Top songs with animated tiles, gradient header with wave effects, mini player
3. **Search View**: Real-time search with instant results, clickable "Sputify" text for navigation
4. **Player View**: Rotating artwork, full controls (play/pause, seek, repeat, shuffle), gradient background
5. **Favorites View**: Saved songs collection with animated list, empty states
6. **Settings View**: Audio quality, playback preferences, theme selection, cache management
7. **Navigation Drawer**: Quick navigation, theme toggle, app logo

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.10.4 or higher)
- Dart SDK
- iOS Simulator / Android Emulator or physical device
- Internet connection

### Installation

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the application**
   ```bash
   flutter run
   ```

## 🎯 Key Features Summary

- ✅ MVVM architecture with GetX
- ✅ Reactive state management
- ✅ iTunes API integration
- ✅ Local favorites storage
- ✅ Modern animated UI
- ✅ Dark/light theme support
- ✅ Full-featured audio player
- ✅ Real-time search
- ✅ Error handling & retry logic

## 👥 Project Members

1. **Didar Ibrahim**
2. **Ayad Lateef**
3. **Sahand Salih**
