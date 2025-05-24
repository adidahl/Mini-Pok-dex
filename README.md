# Mini Pokédex

A kid-friendly iOS app that allows families to explore Pokémon together. This application provides a simple and colorful interface for parents to show their children a different Pokémon each day and learn more about their favorite characters from Pokémon GO.

![App Banner](https://via.placeholder.com/800x400.png?text=Mini+Pok%C3%A9dex)

## Features

### For Parents
- **Daily Random Pokémon**: View a randomly selected Pokémon each time you visit the app
- **New Random Button**: Easily generate a new random Pokémon if the current one doesn't interest your child
- **Bookmarking System**: Save your child's favorite Pokémon to revisit later
- **Simple Interface**: Easy-to-use design that focuses on the essential information

### For Kids
- **Colorful UI**: Bright, engaging, and kid-friendly interface
- **Pokémon Library**: Browse and search through Pokémon by name or type
- **Evolution Pathways**: See how Pokémon evolve and what's required for evolution
- **Fuzzy Search**: Find Pokémon even with spelling mistakes

### Technical Features
- Built with Swift and SwiftUI for iOS 16.0+
- Offline support for previously viewed Pokémon
- Image caching to reduce data usage
- Accessibility features including VoiceOver support and Dynamic Type

## Installation

### Requirements
- iOS 16.0+
- Xcode 14.0+
- Swift 5.7+

### Setup Instructions
1. Clone the repository:
   ```bash
   git clone https://github.com/adidahl/mini-pokedex.git
   ```

2. Open the project in Xcode:
   ```bash
   cd mini-pokedex
   open MiniPokedex.xcodeproj
   ```

3. Build and run the application on your device or simulator.

## Usage

### Random Pokémon
- The app opens to the Random Pokémon tab
- Tap the "New Random" button to generate a different Pokémon
- Use the bookmark button to save favorites

### Searching for Pokémon
1. Navigate to the Search tab
2. Type a Pokémon name in the search bar
3. Browse results even with partial or misspelled names
4. Filter by type using the type selector

### Viewing Bookmarks
- Navigate to the Bookmarks tab to see saved Pokémon
- Swipe left on an entry to remove it from bookmarks
- Tap any entry to view detailed information

### Viewing Pokémon Details
- Tap on any Pokémon card to view detailed information
- Scroll to see stats, type information, and evolution details
- Use the evolution chain visualization to see how the Pokémon evolves

## Data Source

This app uses the [PokéAPI](https://pokeapi.co/) (v2) to fetch Pokémon data. The API is free to use and provides comprehensive information about Pokémon species, evolutions, and more.

## Project Structure

```
MiniPokedex/
├── Models/         # Data models for Pokémon and app state
├── Views/          # SwiftUI views for UI components
├── ViewModels/     # Logic for connecting views with data models
├── Services/       # Networking and persistence services
└── Utilities/      # Helper functions and extensions
```

## Contributing

This project is currently in development. If you'd like to contribute, please feel free to submit a pull request or open an issue for discussion.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [PokéAPI](https://pokeapi.co/) for providing the Pokémon data
- Pokémon and Pokémon character names are trademarks of Nintendo
- This app is created for educational and entertainment purposes only

---

*Note: This app is not affiliated with or endorsed by Nintendo, The Pokémon Company, or Game Freak. It is an unofficial, fan-made application designed for educational purposes and to enhance the Pokémon GO experience for families.* 