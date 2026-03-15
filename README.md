# 🏰 Greenfield

A fantasy RPG with AI-powered narrative, built with Flutter.

## ✨ Features

### Core Gameplay
- **Quest-based Adventure**: Complete main quests, side quests, and daily challenges
- **Company of Heroes**: Interact with companions and build your fellowship
- **Character Progression**: Level up your character, allocate stats, and equip items
- **AI-Powered Dialogue**: Context-aware NPC conversations powered by Claude AI
- **Dynamic Quests**: AI-generated quests tailored to your progress
- **Lumina's Guidance**: Ask the Seer for guidance and lore

### Character System
- **Races**: Hobbit, Human, Elf, Dwarf (each with unique stat bonuses)
- **Classes**: Warrior, Ranger, Wizard, Rogue
- **Fellowship Roles**: Leader, Scout, Healer, Loremaster
- **Stat Allocation**: Distribute points across STR, WIS, AGI, CON
- **XP & Leveling**: Exponential XP scaling up to level 50

### Notifications & Recurring Events
- **Configurable Notifications**: In-app and chat platform notifications
- **Quiet Hours**: Set do-not-disturb times
- **Priority Levels**: Critical, High, Medium, Low
- **Daily Quests**: Auto-reset at configured time
- **Weekly Events**: Recurring fellowship gatherings and challenges

### Chat Platform Integration
- **Multi-Chat Support**: Google Chat, Slack, Discord (via MCP server)
- **Hybrid Mode**: Full game locally + status checks via chat commands
- **Commands**: `!greenfield status`, `!greenfield quests`, `!greenfield inventory`, `!greenfield link`
- **Notifications**: Receive game updates in your chat platforms

### UI/UX
- **16-bit Retro Aesthetic**: Pixel-art inspired with sharp borders and emoji avatars
- **Fantasy Theme**: Dark forest green background, gold accents, brown UI elements
- **Monospace Font**: Courier New for that classic retro feel

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.41.4+ (installed)
- Dart 3.11.1+
- Anthropic Claude API key (optional for AI features)
- Multi-Chat MCP Server (optional for chat integrations)

### Installation

1. **Configure Environment**
   ```bash
   # Copy the example env file
   cp .env.example .env

   # Edit .env and add your API keys
   # At minimum, you'll want to add your Claude API key:
   CLAUDE_API_KEY=sk-ant-your-key-here
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the App**
   ```bash
   # Run on desktop (Linux)
   flutter run -d linux

   # Or run on Android
   flutter run -d android

   # Or run on web
   flutter run -d chrome
   ```

## 📁 Project Structure

```
lib/
├── core/
│   ├── config/         # Configuration (theme, constants, app config)
│   ├── di/             # Dependency injection setup
│   └── utils/          # Utility functions
├── data/
│   ├── datasources/    # Local (SQLite) and remote (Claude API, MCP) data sources
│   ├── models/         # Data models with JSON serialization
│   ├── repositories/   # Repository implementations
│   └── seed/           # Seed data (quests, NPCs, items)
├── domain/
│   ├── entities/       # Business entities
│   ├── repositories/   # Repository interfaces
│   └── usecases/       # Business logic use cases
├── presentation/
│   ├── providers/      # Riverpod state management
│   ├── screens/        # UI screens
│   └── widgets/        # Reusable UI components
└── services/           # High-level services (Claude, notifications, game engine)

assets/
├── data/seed/          # JSON seed data
│   ├── npcs.json       # 6 fellowship members
│   ├── quests.json     # 10 starter quests
│   └── items.json      # 12 items
└── images/             # Game assets (future)
```

## 🗄️ Database Schema

SQLite database with 11 tables:
- **characters**: Player character data
- **fellowship_members**: NPC data with personality traits
- **quests**: Quest definitions with recurrence rules
- **inventory_items**: Player items with stat modifiers
- **dialogue_history**: Conversation logs for RAG context
- **user_progress**: Global game state
- **chat_platform_links**: Link game to chat accounts
- **notification_settings**: Per-platform notification preferences
- **recurring_events**: Scheduled event definitions
- **notification_queue**: Pending notifications
- **chat_commands_log**: Chat command history

## 🤖 RAG Features (Claude AI)

All AI features use Anthropic's Claude API with specialized prompts:

1. **Character Dialogue**: NPCs respond based on personality, relationship level, and quest context
2. **Quest Generation**: Dynamic quests tailored to player level and story progress
3. **Lore Assistant** (Lumina's Guidance): Ask about game lore or guidance
4. **Natural Language Commands**: Parse player text into game actions

### Context Management
- Sliding window of last 10 dialogue messages
- Context summaries stored in database
- Graceful fallback responses when API is unavailable

## 🔧 Configuration

Edit `.env` to configure:

```env
# AI Provider
CLAUDE_API_KEY=your-key-here
CLAUDE_MODEL=claude-3-5-sonnet-20241022

# Chat Integrations (optional)
MCP_SERVER_URL=http://localhost:3000
GOOGLE_CHAT_WEBHOOK_URL=your-webhook-url
DISCORD_BOT_TOKEN=your-bot-token
SLACK_APP_TOKEN=your-slack-token

# Feature Flags
ENABLE_QUEST_GENERATION=true
ENABLE_CHAT_BOTS=false
ENABLE_NOTIFICATIONS=true
ENABLE_RECURRING_EVENTS=true

# Game Settings
MAX_FELLOWSHIP_SIZE=8
XP_MULTIPLIER=1.0
DAILY_QUEST_RESET_HOUR=0
DEBUG_MODE=true
```

## 🎮 MVP Roadmap

### ✅ Phase 1: Foundation (COMPLETED)
- [x] Flutter project setup with Clean Architecture
- [x] SQLite database with all tables
- [x] Seed data (6 NPCs, 10 quests, 12 items)
- [x] Configuration system (.env, theme, constants)
- [x] Dependency injection setup
- [x] 16-bit retro theme

### ✅ Phase 2: Character System (COMPLETED)
- [x] Character entity and data models
- [x] Character creation wizard UI
  - [x] Race selection
  - [x] Class selection
  - [x] Stat allocation
  - [x] Fellowship role
- [x] Character persistence
- [x] Leveling and XP system

### 📋 Phase 3: Quest System (PLANNED)
- [ ] Quest entities and models
- [ ] Quest lifecycle (available → active → completed)
- [ ] Home screen with quest list
- [ ] Quest detail screen
- [ ] Quest completion with XP rewards

### 📋 Phase 4: Fellowship & Inventory (PLANNED)
- [ ] Fellowship member management
- [ ] Inventory system
- [ ] Equipment with stat effects
- [ ] Basic NPC dialogue UI

### 📋 Phase 5: Claude RAG Integration (PLANNED)
- [ ] Claude API client
- [ ] RAG repository with prompt templates
- [ ] Lumina's Guidance chat UI
- [ ] Dynamic NPC dialogue
- [ ] Quest generation

### 📋 Phase 6: Notifications & Recurrence (PLANNED)
- [ ] Notification service
- [ ] Recurring event service
- [ ] Settings screen
- [ ] Daily quest reset logic

### 📋 Phase 7: Multi-Chat MCP Integration (PLANNED)
- [ ] MCP chat client
- [ ] Chat command handlers
- [ ] User linking flow
- [ ] Notification delivery to chat platforms

### 📋 Phase 8: Polish & Testing (PLANNED)
- [ ] Bug fixes and UI polish
- [ ] Unit tests
- [ ] Integration tests
- [ ] Documentation

### 📋 Phase 9: Advanced Features (FUTURE)
- [ ] **Profile/Character Image Generation**: AI-generated character artwork based on race, class, and appearance choices
- [ ] **Skill Trees**: Progression system with character abilities and passive bonuses
- [ ] **Ad-Hoc Mini-Games**: Quest-relevant mini-games (combat, puzzles, debates) with outcome impact

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/domain/usecases/quest/complete_quest_test.dart

# Run with coverage
flutter test --coverage
```

## 🛠️ Development

### Code Generation
```bash
# Generate JSON serialization code
flutter pub run build_runner build --delete-conflicting-outputs
```

### Database Management
```bash
# Reset database (for development)
# Add this to your debug menu in the app
DatabaseHelper.instance.resetDatabase()
```

## 📚 Architecture

This project follows Clean Architecture principles:

- **Domain Layer**: Pure Dart, no Flutter dependencies. Contains entities, repository interfaces, and use cases.
- **Data Layer**: Implements repositories. Handles SQLite, Claude API, and MCP server communication.
- **Presentation Layer**: Flutter UI with Riverpod for state management.
- **Service Layer**: Cross-cutting concerns like notifications and game engine logic.

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development workflow and branch protection setup.

## 📄 License

This project is for educational and personal use.

## 🎉 Acknowledgments

- Anthropic Claude for AI-powered narrative
- Flutter team for the amazing framework
- Multi-Chat MCP Server for chat integrations

---

**Made with ❤️ and 🤖 AI**
