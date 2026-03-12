import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logger/logger.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  final _logger = Logger();

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('shire.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    _logger.i('Initializing database at: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    _logger.i('Creating database tables...');

    // Characters table
    await db.execute('''
      CREATE TABLE characters (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        race TEXT NOT NULL CHECK(race IN ('Hobbit', 'Human', 'Elf', 'Dwarf')),
        class TEXT NOT NULL CHECK(class IN ('Warrior', 'Ranger', 'Wizard', 'Rogue')),
        fellowship_role TEXT NOT NULL CHECK(fellowship_role IN ('Leader', 'Scout', 'Healer', 'Loremaster')),
        level INTEGER DEFAULT 1,
        current_xp INTEGER DEFAULT 0,
        xp_to_next_level INTEGER DEFAULT 100,
        strength INTEGER NOT NULL,
        wisdom INTEGER NOT NULL,
        agility INTEGER NOT NULL,
        constitution INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Fellowship members table (NPCs)
    await db.execute('''
      CREATE TABLE fellowship_members (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        race TEXT NOT NULL,
        class TEXT NOT NULL,
        description TEXT,
        personality_traits TEXT,
        relationship_level INTEGER DEFAULT 0 CHECK(relationship_level BETWEEN -100 AND 100),
        is_unlocked INTEGER DEFAULT 0,
        avatar_emoji TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    // Quests table
    await db.execute('''
      CREATE TABLE quests (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        quest_type TEXT NOT NULL CHECK(quest_type IN ('main', 'side', 'daily', 'generated')),
        difficulty TEXT NOT NULL CHECK(difficulty IN ('easy', 'medium', 'hard')),
        status TEXT DEFAULT 'available' CHECK(status IN ('available', 'active', 'completed', 'failed')),
        xp_reward INTEGER NOT NULL,
        objectives TEXT NOT NULL,
        required_level INTEGER DEFAULT 1,
        prerequisites TEXT,
        is_generated INTEGER DEFAULT 0,
        generation_context TEXT,
        recurrence_rule TEXT,
        accepted_at INTEGER,
        completed_at INTEGER,
        created_at INTEGER NOT NULL
      )
    ''');

    // Inventory table
    await db.execute('''
      CREATE TABLE inventory_items (
        id TEXT PRIMARY KEY,
        character_id TEXT NOT NULL,
        item_name TEXT NOT NULL,
        item_type TEXT NOT NULL CHECK(item_type IN ('weapon', 'armor', 'consumable', 'quest_item', 'misc')),
        description TEXT,
        quantity INTEGER DEFAULT 1,
        stat_modifiers TEXT,
        is_equipped INTEGER DEFAULT 0,
        rarity TEXT CHECK(rarity IN ('common', 'uncommon', 'rare', 'epic', 'legendary')),
        emoji_icon TEXT,
        acquired_at INTEGER NOT NULL,
        FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE
      )
    ''');

    // Dialogue history table
    await db.execute('''
      CREATE TABLE dialogue_history (
        id TEXT PRIMARY KEY,
        character_id TEXT NOT NULL,
        npc_id TEXT NOT NULL,
        message TEXT NOT NULL,
        sender TEXT NOT NULL CHECK(sender IN ('player', 'npc', 'galadriel')),
        context_summary TEXT,
        quest_context TEXT,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
        FOREIGN KEY (npc_id) REFERENCES fellowship_members(id)
      )
    ''');

    // User progress table (singleton)
    await db.execute('''
      CREATE TABLE user_progress (
        id TEXT PRIMARY KEY DEFAULT '1',
        current_character_id TEXT,
        total_playtime_seconds INTEGER DEFAULT 0,
        quests_completed INTEGER DEFAULT 0,
        story_flags TEXT,
        last_played_at INTEGER,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (current_character_id) REFERENCES characters(id)
      )
    ''');

    // Chat platform links table
    await db.execute('''
      CREATE TABLE chat_platform_links (
        id TEXT PRIMARY KEY,
        platform TEXT NOT NULL CHECK(platform IN ('google_chat', 'slack', 'discord')),
        platform_user_id TEXT NOT NULL,
        character_id TEXT NOT NULL,
        link_code TEXT,
        linked_at INTEGER NOT NULL,
        FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
        UNIQUE(platform, platform_user_id)
      )
    ''');

    // Notification settings table
    await db.execute('''
      CREATE TABLE notification_settings (
        id TEXT PRIMARY KEY DEFAULT '1',
        in_app_enabled INTEGER DEFAULT 1,
        chat_platforms_enabled TEXT,
        notification_types TEXT,
        quiet_hours_enabled INTEGER DEFAULT 1,
        quiet_hours_start TEXT DEFAULT '22:00',
        quiet_hours_end TEXT DEFAULT '08:00',
        updated_at INTEGER NOT NULL
      )
    ''');

    // Recurring events table
    await db.execute('''
      CREATE TABLE recurring_events (
        id TEXT PRIMARY KEY,
        event_type TEXT NOT NULL CHECK(event_type IN ('quest_refresh', 'fellowship_checkin', 'galadriel_insight', 'custom')),
        event_name TEXT NOT NULL,
        recurrence_rule TEXT NOT NULL,
        trigger_time TEXT,
        enabled INTEGER DEFAULT 1,
        notify_on_trigger INTEGER DEFAULT 1,
        notification_message TEXT,
        last_triggered_at INTEGER,
        next_trigger_at INTEGER,
        created_at INTEGER NOT NULL
      )
    ''');

    // Notification queue table
    await db.execute('''
      CREATE TABLE notification_queue (
        id TEXT PRIMARY KEY,
        notification_type TEXT NOT NULL,
        priority TEXT NOT NULL CHECK(priority IN ('critical', 'high', 'medium', 'low')),
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        target_character_id TEXT,
        created_at INTEGER NOT NULL,
        sent_at INTEGER,
        read_at INTEGER,
        FOREIGN KEY (target_character_id) REFERENCES characters(id) ON DELETE CASCADE
      )
    ''');

    // Chat commands log table
    await db.execute('''
      CREATE TABLE chat_commands_log (
        id TEXT PRIMARY KEY,
        platform TEXT NOT NULL CHECK(platform IN ('google_chat', 'slack', 'discord')),
        user_id TEXT NOT NULL,
        character_id TEXT,
        command TEXT NOT NULL,
        response TEXT,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (character_id) REFERENCES characters(id)
      )
    ''');

    // Create indexes for performance
    await db.execute('CREATE INDEX idx_quests_status ON quests(status)');
    await db.execute('CREATE INDEX idx_quests_type ON quests(quest_type)');
    await db.execute(
      'CREATE INDEX idx_inventory_character ON inventory_items(character_id)',
    );
    await db.execute(
      'CREATE INDEX idx_dialogue_character_npc ON dialogue_history(character_id, npc_id)',
    );
    await db.execute(
      'CREATE INDEX idx_dialogue_timestamp ON dialogue_history(timestamp DESC)',
    );
    await db.execute(
      'CREATE INDEX idx_chat_commands_user ON chat_commands_log(user_id, timestamp DESC)',
    );
    await db.execute(
      'CREATE INDEX idx_notification_queue_character ON notification_queue(target_character_id, created_at DESC)',
    );

    _logger.i('Database tables created successfully');

    // Initialize default data
    await _initializeDefaults(db);

    // Load seed data
    await _loadSeedData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    _logger.i('Upgrading database from version $oldVersion to $newVersion');
    // Handle database migrations here
  }

  Future<void> _initializeDefaults(Database db) async {
    _logger.i('Initializing default data...');

    // Initialize user progress
    await db.insert('user_progress', {
      'id': '1',
      'total_playtime_seconds': 0,
      'quests_completed': 0,
      'story_flags': json.encode({}),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });

    // Initialize notification settings with defaults
    await db.insert('notification_settings', {
      'id': '1',
      'in_app_enabled': 1,
      'chat_platforms_enabled': json.encode({
        'google_chat': true,
        'slack': false,
        'discord': true,
      }),
      'notification_types': json.encode({
        'quest_complete': {'enabled': true, 'priority': 'high'},
        'level_up': {'enabled': true, 'priority': 'critical'},
        'new_quest': {'enabled': true, 'priority': 'medium'},
        'daily_reminder': {'enabled': false, 'priority': 'low'},
        'fellowship_message': {'enabled': true, 'priority': 'medium'},
      }),
      'quiet_hours_enabled': 1,
      'quiet_hours_start': '22:00',
      'quiet_hours_end': '08:00',
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });

    // Initialize default recurring events
    final now = DateTime.now().millisecondsSinceEpoch;

    // Daily quest reset
    await db.insert('recurring_events', {
      'id': 'event_daily_quest_reset',
      'event_type': 'quest_refresh',
      'event_name': 'Daily Quest Reset',
      'recurrence_rule': 'FREQ=DAILY;INTERVAL=1',
      'trigger_time': '00:00',
      'enabled': 1,
      'notify_on_trigger': 1,
      'notification_message': 'New daily quests are available!',
      'created_at': now,
    });

    // Weekly fellowship gathering
    await db.insert('recurring_events', {
      'id': 'event_weekly_fellowship',
      'event_type': 'fellowship_checkin',
      'event_name': 'Weekly Fellowship Gathering',
      'recurrence_rule': 'FREQ=WEEKLY;BYDAY=SU',
      'trigger_time': '12:00',
      'enabled': 1,
      'notify_on_trigger': 1,
      'notification_message': 'Time for the weekly Fellowship gathering!',
      'created_at': now,
    });

    _logger.i('Default data initialized');
  }

  Future<void> _loadSeedData(Database db) async {
    _logger.i('Loading seed data...');

    try {
      // Load fellowship members (NPCs)
      final npcsJson = await rootBundle.loadString(
        'assets/data/seed/npcs.json',
      );
      final npcsData = json.decode(npcsJson);
      final fellowshipMembers = npcsData['fellowship_members'] as List;

      for (final npc in fellowshipMembers) {
        await db.insert('fellowship_members', {
          'id': npc['id'],
          'name': npc['name'],
          'race': npc['race'],
          'class': npc['class'],
          'description': npc['description'],
          'personality_traits': json.encode(npc['personality_traits']),
          'relationship_level': npc['relationship_level'],
          'is_unlocked': npc['is_unlocked'],
          'avatar_emoji': npc['avatar_emoji'],
          'created_at': DateTime.now().millisecondsSinceEpoch,
        });
      }
      _logger.i('Loaded ${fellowshipMembers.length} fellowship members');

      // Load quests
      final questsJson = await rootBundle.loadString(
        'assets/data/seed/quests.json',
      );
      final questsData = json.decode(questsJson);
      final quests = questsData['quests'] as List;

      for (final quest in quests) {
        await db.insert('quests', {
          'id': quest['id'],
          'title': quest['title'],
          'description': quest['description'],
          'quest_type': quest['quest_type'],
          'difficulty': quest['difficulty'],
          'status': quest['status'],
          'xp_reward': quest['xp_reward'],
          'objectives': json.encode(quest['objectives']),
          'required_level': quest['required_level'],
          'prerequisites': json.encode(quest['prerequisites']),
          'is_generated': quest['is_generated'],
          'recurrence_rule': quest['recurrence_rule'],
          'created_at': DateTime.now().millisecondsSinceEpoch,
        });
      }
      _logger.i('Loaded ${quests.length} quests');

      // Note: Items are not loaded into inventory yet - they'll be added when a character is created
      // or acquired through quests. We could load them into a separate items_catalog table if needed.

      _logger.i('Seed data loaded successfully');
    } catch (e) {
      _logger.e('Error loading seed data: $e');
      rethrow;
    }
  }

  // Helper method to reset database (useful for development/testing)
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'shire.db');

    await deleteDatabase(path);
    _database = null;

    _logger.w('Database reset completed');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    _logger.i('Database closed');
  }
}
