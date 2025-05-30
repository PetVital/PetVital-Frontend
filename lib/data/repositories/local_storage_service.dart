import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/entities/Pet.dart';

class LocalStorageService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    String path = await getDatabasesPath();
    print("Database path: $path");

    return await openDatabase(
      join(path, 'pet_vital.db'),
      version: 1,
      onCreate: (db, version) async {
        print("Creating database tables...");

        await db.execute(''' 
          CREATE TABLE IF NOT EXISTS Pets (
            id INTEGER PRIMARY KEY,
            name TEXT,
            type TEXT,
            breed TEXT,
            gender TEXT,
            age INTEGER,
            timeUnit TEXT,
            weight REAL
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

  // Reemplaza todos los registros existentes por una nueva lista de mascotas
  Future<void> replacePets(List<Pet> pets) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('Pets');
      for (var pet in pets) {
        await txn.insert('Pets', pet.toDbJson());
      }
    });
  }

  // Agrega una sola mascota
  Future<void> insertPet(Pet pet) async {
    final db = await database;
    await db.insert('Pets', pet.toDbJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertSamplePets() async {
    final db = await database;

    final List<Pet> samplePets = [
      Pet(
        id: 1,
        name: 'Max',
        type: 'Perro',
        breed: 'Labrador',
        gender: 'Macho',
        age: 3,
        timeUnit: 'años',
        weight: 25.5,
      ),
      Pet(
        id: 2,
        name: 'Luna',
        type: 'Gato',
        breed: 'Persa',
        gender: 'Hembra',
        age: 2,
        timeUnit: 'años',
        weight: 4.2,
      ),
      Pet(
        id: 3,
        name: 'Rocky',
        type: 'Perro',
        breed: 'Bulldog Frances',
        gender: 'Macho',
        age: 3,
        timeUnit: 'año',
        weight: 1.8,
      ),
    ];

    for (final pet in samplePets) {
      await db.insert(
        'Pets',
        pet.toDbJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }


  // Actualiza una mascota
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

  // Elimina una mascota por su ID
  Future<void> deletePet(int id) async {
    final db = await database;
    await db.delete('Pets', where: 'id = ?', whereArgs: [id]);
  }

  // Obtiene todas las mascotas guardadas
  Future<List<Pet>> getAllPets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Pets');
    return maps.map((json) => Pet.fromDb(json)).toList();
  }
}
