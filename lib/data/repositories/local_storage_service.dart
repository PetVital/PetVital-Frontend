import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/entities/pet.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/message.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();

  factory LocalStorageService() {
    return _instance;
  }

  LocalStorageService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    String path = await getDatabasesPath();
    String dbPath = join(path, 'pet_vital.db');

    //await deleteDatabase(dbPath); // <- elimina base de datos anterior

    return await openDatabase(
      join(path, 'pet_vital.db'),
      version: 2, // 🔥 Incrementar versión para agregar nueva tabla
      onCreate: (db, version) async {
        print("Creating database tables...");

        await db.execute('''        
          CREATE TABLE IF NOT EXISTS UserCredentials(
            id INTEGER PRIMARY KEY,
            email TEXT,
            password TEXT,
            rememberMe INTEGER
          )
        ''');

        await db.execute(''' 
          CREATE TABLE IF NOT EXISTS User(
            id TEXT PRIMARY KEY, 
            first_name TEXT,
            last_name TEXT,
            email TEXT
          )
        ''');

        await db.execute(''' 
          CREATE TABLE IF NOT EXISTS Pets (
            id INTEGER PRIMARY KEY,
            name TEXT,
            type TEXT,
            breed TEXT,
            gender TEXT,
            age INTEGER,
            timeUnit TEXT,
            weight REAL,
            userId INTEGER,
            isSterilized INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS Messages (
            id INTEGER PRIMARY KEY,
            message TEXT,
            isBot INTEGER,
            timestamp TEXT
          )
        ''');

        // 🔥 Nueva tabla para notificaciones
        await db.execute('''
          CREATE TABLE IF NOT EXISTS ScheduledNotifications (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            notification_id TEXT NOT NULL,
            appointment_id TEXT NOT NULL,
            user_id TEXT NOT NULL,
            scheduled_date TEXT NOT NULL,
            appointment_date TEXT,
            appointment_time TEXT,
            pet_name TEXT,
            appointment_type TEXT,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        print("Database tables created successfully.");
      },
      onOpen: (db) async {
        print("Database opened. Checking tables...");
        var tables = await db.query('sqlite_master', columns: ['name']);
        print("Existing tables: ${tables.map((t) => t['name']).toList()}");
      },
    );
  }

  Future<void> deleteDatabaseFile() async {
    final path = join(await getDatabasesPath(), 'pet_vital.db');
    await deleteDatabase(path);
    print("Database deleted");
  }

  Future<void> clearAllTablesExceptUserCredentials() async {
    final db = await database;
    await db.delete('User');
    await db.delete('Pets');
    await db.delete('Messages');
    await db.delete('ScheduledNotifications'); // 🔥 Limpiar notificaciones
  }

  // === MÉTODOS EXISTENTES (sin cambios) ===
  Future<void> saveCredentials(String email, String password, bool rememberMe) async {
    final db = await database;
    await db.delete('UserCredentials');
    await db.insert('UserCredentials', {
      'email': email,
      'password': password,
      'rememberMe': rememberMe ? 1 : 0,
    });
  }

  Future<Map<String, dynamic>?> getCredentials() async {
    final db = await database;
    var results = await db.query('UserCredentials',
        where: 'rememberMe = ?', whereArgs: [1], limit: 1);
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<void> clearCredentials() async {
    final db = await database;
    await db.delete('UserCredentials');
  }

  Future<void> clearMessages() async {
    final db = await database;
    await db.delete('Messages');
  }

  Future saveUser(User user) async {
    final db = await database;
    await db.delete('User');
    await db.insert(
      'User',
      {
        'id': user.id,
        'first_name': user.firstName,
        'last_name': user.lastName,
        'email': user.email,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getCurrentUser() async {
    final db = await database;
    var results = await db.query('User', limit: 1);

    if (results.isNotEmpty) {
      return User(
        id: results.first['id'] as String,
        firstName: results.first['first_name'] as String,
        lastName: results.first['last_name'] as String,
        email: results.first['email'] as String,
      );
    }
    return null;
  }

  Future<int> getCurrentUserId() async {
    final db = await database;
    var results = await db.query('User', limit: 1);

    if (results.isNotEmpty) {
      var userId = results.first['id'];
      if (userId is int) {
        return userId;
      } else if (userId is String) {
        int parsedUserId = int.tryParse(userId) ?? 0;
        return parsedUserId;
      } else {
        return 0;
      }
    } else {
      return 0;
    }
  }

  Future<String?> getCurrentUserIdAsString() async {
    final db = await database;
    var results = await db.query('User', limit: 1);

    if (results.isNotEmpty) {
      return results.first['id'] as String?;
    }
    return null;
  }

  Future<void> clearUser() async {
    final db = await database;
    await db.delete('User');
  }

  Future<void> clearAllTables() async {
    final db = await database;
    final List<String> tables = ['Pets', 'Messages'];
    for (final table in tables) {
      await db.delete(table);
      print("Tabla $table vaciada.");
    }
    print("Todas las tablas han sido vaciadas.");
  }

  Future<void> clearPets() async {
    final db = await database;
    await db.delete('Pets');
  }

  Future<void> replacePets(List<Pet> pets) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('Pets');
      for (var pet in pets) {
        await txn.insert('Pets', pet.toDbJson());
      }
    });
  }

  Future<void> insertPet(Pet pet) async {
    final db = await database;
    await db.insert('Pets', pet.toDbJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updatePet(Pet pet) async {
    final db = await database;
    await db.update(
      'Pets',
      pet.toDbJson(),
      where: 'id = ?',
      whereArgs: [pet.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool?> isPetSterilized(int petId) async {
    final db = await database;
    final result = await db.query(
      'Pets',
      columns: ['isSterilized'],
      where: 'id = ?',
      whereArgs: [petId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['isSterilized'] == 1;
    } else {
      return null;
    }
  }

  Future<void> setPetSterilized(int petId, bool value) async {
    final db = await database;
    await db.update(
      'Pets',
      {'isSterilized': value ? 1 : 0},
      where: 'id = ?',
      whereArgs: [petId],
    );
  }

  Future<Pet?> getPetById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Pets',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Pet.fromDb(maps.first);
    } else {
      return null;
    }
  }

  Future<void> deletePet(int id) async {
    final db = await database;
    await db.delete('Pets', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Pet>> getAllPets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Pets');
    return maps.map((json) => Pet.fromDb(json)).toList();
  }

  Future<void> insertMessage(Message message) async {
    final db = await database;
    await db.insert(
      'Messages',
      message.toDbJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Message>> getAllMessages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Messages',
      orderBy: 'timestamp ASC',
    );
    return maps.map((json) => Message.fromDb(json)).toList();
  }

  // === 🔥 NUEVOS MÉTODOS PARA NOTIFICACIONES ===

  /// Guarda una notificación programada
  Future<void> saveScheduledNotification({
    required String notificationId,
    required String appointmentId,
    required String userId,
    required String scheduledDate,
    String? appointmentDate,
    String? appointmentTime,
    String? petName,
    String? appointmentType,
  }) async {
    final db = await database;
    await db.insert(
      'ScheduledNotifications',
      {
        'notification_id': notificationId,
        'appointment_id': appointmentId,
        'user_id': userId,
        'scheduled_date': scheduledDate,
        'appointment_date': appointmentDate,
        'appointment_time': appointmentTime,
        'pet_name': petName,
        'appointment_type': appointmentType,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obtiene todas las notificaciones programadas del usuario actual
  Future<List<Map<String, dynamic>>> getScheduledNotificationsByUser(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ScheduledNotifications',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'scheduled_date ASC',
    );
    return maps;
  }

  /// Obtiene una notificación específica por appointment_id
  Future<Map<String, dynamic>?> getScheduledNotificationByAppointment(String appointmentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ScheduledNotifications',
      where: 'appointment_id = ?',
      whereArgs: [appointmentId],
      limit: 1,
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  /// Elimina una notificación por appointment_id
  Future<bool> deleteScheduledNotificationByAppointment(String appointmentId) async {
    final db = await database;
    final int deletedRows = await db.delete(
      'ScheduledNotifications',
      where: 'appointment_id = ?',
      whereArgs: [appointmentId],
    );
    return deletedRows > 0;
  }

  /// Elimina todas las notificaciones de un usuario específico
  Future<void> deleteAllScheduledNotificationsByUser(String userId) async {
    final db = await database;
    await db.delete(
      'ScheduledNotifications',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// Limpia todas las notificaciones programadas
  Future<void> clearAllScheduledNotifications() async {
    final db = await database;
    await db.delete('ScheduledNotifications');
  }

  /// Obtiene todas las notificaciones (para debugging)
  Future<List<Map<String, dynamic>>> getAllScheduledNotifications() async {
    final db = await database;
    return await db.query('ScheduledNotifications', orderBy: 'created_at DESC');
  }
}