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

    // 🔥 Usamos una versión alta para forzar siempre onUpgrade
    return await openDatabase(
      dbPath,
      version: 100, // Versión alta para forzar upgrade
      onCreate: (db, version) async {
        print("Creating database tables...");
        await _createAllTables(db);
        print("Database tables created successfully.");
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        print("Upgrading database from version $oldVersion to $newVersion");
        print("Auto-detecting and creating missing tables...");

        // 🔥 Siempre verificar y crear tablas faltantes
        await _ensureAllTablesExist(db);

        print("Database upgrade completed.");
      },
      onOpen: (db) async {
        print("Database opened. Checking tables...");
        var tables = await db.query('sqlite_master', columns: ['name']);
        print("Existing tables: ${tables.map((t) => t['name']).toList()}");

        // 🔥 Verificación adicional: crear tablas faltantes si no existen
        await _ensureAllTablesExist(db);
      },
    );
  }

  // 🔥 Método para crear todas las tablas (usado en onCreate)
  Future<void> _createAllTables(Database db) async {
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
  }

  // 🔥 Método simplificado - siempre verifica y crea tablas faltantes
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    print("Auto-detecting missing tables and creating them...");

    // 🔥 Simplemente aseguramos que todas las tablas existan
    // No importa de qué versión venga
    await _ensureAllTablesExist(db);

    print("All required tables are now present.");
  }

  // 🔥 Método para asegurar que todas las tablas y columnas existan
  Future<void> _ensureAllTablesExist(Database db) async {
    // Obtener lista de tablas existentes
    var tables = await db.query('sqlite_master',
        columns: ['name'],
        where: 'type = ?',
        whereArgs: ['table']);

    List<String> existingTables = tables.map((t) => t['name'] as String).toList();
    print("Existing tables: $existingTables");

    // 🔥 Definir TODAS las tablas que debe tener la app
    Map<String, String> requiredTables = {
      'UserCredentials': '''        
        CREATE TABLE IF NOT EXISTS UserCredentials(
          id INTEGER PRIMARY KEY,
          email TEXT,
          password TEXT,
          rememberMe INTEGER
        )
      ''',
      'User': ''' 
        CREATE TABLE IF NOT EXISTS User(
          id TEXT PRIMARY KEY, 
          first_name TEXT,
          last_name TEXT,
          email TEXT
        )
      ''',
      'Pets': ''' 
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
      ''',
      'Messages': '''
        CREATE TABLE IF NOT EXISTS Messages (
          id INTEGER PRIMARY KEY,
          message TEXT,
          isBot INTEGER,
          timestamp TEXT
        )
      ''',
      'ScheduledNotifications': '''
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
      '''
      // 🔥 Agregar aquí cualquier nueva tabla que necesites en el futuro
      // 'NewTable': '''CREATE TABLE IF NOT EXISTS NewTable(...)'''
    };

    // 🔥 Crear todas las tablas que falten
    int tablesCreated = 0;
    for (String tableName in requiredTables.keys) {
      if (!existingTables.contains(tableName)) {
        print("🔥 Creating missing table: $tableName");
        await db.execute(requiredTables[tableName]!);
        tablesCreated++;
      } else {
        print("✅ Table $tableName already exists");
      }
    }

    if (tablesCreated > 0) {
      print("✅ Created $tablesCreated missing tables successfully");
    } else {
      print("✅ All required tables already exist");
    }

    // 🔥 Verificar y agregar columnas faltantes en tablas existentes
    await _ensureAllColumnsExist(db);
  }

  // 🔥 Método para verificar y agregar columnas faltantes
  Future<void> _ensureAllColumnsExist(Database db) async {
    print("Checking for missing columns...");

    // 🔥 Verificar columnas en la tabla Pets
    await _ensureColumnExists(db, 'Pets', 'isSterilized', 'INTEGER DEFAULT 0');

    // 🔥 Agregar aquí verificaciones para otras tablas si es necesario
    // await _ensureColumnExists(db, 'User', 'nueva_columna', 'TEXT DEFAULT NULL');

    print("Column verification completed");
  }

  // 🔥 Método para verificar si una columna existe y crearla si no existe
  Future<void> _ensureColumnExists(Database db, String tableName, String columnName, String columnDefinition) async {
    try {
      // Intentar hacer una consulta que use la columna
      await db.query(tableName, columns: [columnName], limit: 1);
      print("✅ Column $tableName.$columnName already exists");
    } catch (e) {
      // Si falla, la columna no existe, la creamos
      if (e.toString().contains('no such column') || e.toString().contains('no column named')) {
        print("🔥 Adding missing column: $tableName.$columnName");
        try {
          await db.execute('ALTER TABLE $tableName ADD COLUMN $columnName $columnDefinition');
          print("✅ Column $tableName.$columnName added successfully");
        } catch (alterError) {
          print("❌ Error adding column $tableName.$columnName: $alterError");
        }
      } else {
        print("❌ Unexpected error checking column $tableName.$columnName: $e");
      }
    }
  }

  // 🔥 Método para verificar si una tabla existe
  Future<bool> _tableExists(Database db, String tableName) async {
    var result = await db.query(
      'sqlite_master',
      where: 'type = ? AND name = ?',
      whereArgs: ['table', tableName],
    );
    return result.isNotEmpty;
  }

  // 🔥 Método para forzar recreación de la base de datos (solo para desarrollo)
  Future<void> recreateDatabase() async {
    await deleteDatabaseFile();
    _database = null;
    await database; // Esto iniciará la recreación
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

    // Verificar si la tabla existe antes de limpiarla
    if (await _tableExists(db, 'ScheduledNotifications')) {
      await db.delete('ScheduledNotifications');
    }
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

  // === 🔥 MÉTODOS PARA NOTIFICACIONES (con verificación de tabla) ===

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

    // Verificar que la tabla existe antes de insertar
    if (!await _tableExists(db, 'ScheduledNotifications')) {
      print("ScheduledNotifications table doesn't exist, creating it...");
      await _ensureAllTablesExist(db);
    }

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

    if (!await _tableExists(db, 'ScheduledNotifications')) {
      return [];
    }

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

    if (!await _tableExists(db, 'ScheduledNotifications')) {
      return null;
    }

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

    if (!await _tableExists(db, 'ScheduledNotifications')) {
      return false;
    }

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

    if (!await _tableExists(db, 'ScheduledNotifications')) {
      return;
    }

    await db.delete(
      'ScheduledNotifications',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// Limpia todas las notificaciones programadas
  Future<void> clearAllScheduledNotifications() async {
    final db = await database;

    if (!await _tableExists(db, 'ScheduledNotifications')) {
      return;
    }

    await db.delete('ScheduledNotifications');
  }

  /// Obtiene todas las notificaciones (para debugging)
  Future<List<Map<String, dynamic>>> getAllScheduledNotifications() async {
    final db = await database;

    if (!await _tableExists(db, 'ScheduledNotifications')) {
      return [];
    }

    return await db.query('ScheduledNotifications', orderBy: 'created_at DESC');
  }
}