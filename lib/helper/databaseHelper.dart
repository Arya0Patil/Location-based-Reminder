import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/ReminderModel.dart';

class ReminderDatabaseHelper {
  static final _databaseName = "reminders_database.db";
  static final _databaseVersion = 1;

  static final table = 'reminders_table';

  static final columnId = '_id';
  static final columnTitle = 'title';
  static final columnLatitude = 'latitude';
  static final columnLongitude = 'longitude';
  static final columnRadius = 'radius';
  static final columnStartTime = 'start_time';
  static final columnEndTime = 'end_time';
  static final columnAddress = 'address';

  static final ReminderDatabaseHelper instance =
      ReminderDatabaseHelper._privateConstructor();

  static Database? _database;

  ReminderDatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnTitle TEXT NOT NULL,
            $columnLatitude REAL NOT NULL,
            $columnLongitude REAL NOT NULL,
            $columnRadius REAL NOT NULL,
            $columnStartTime TEXT NOT NULL,
            $columnEndTime TEXT NOT NULL,
            $columnAddress TEXT NOT NULL
          )
          ''');
  }

  Future<int> insert(Reminder reminder) async {
    Database db = await instance.database;
    return await db.insert(table, reminder.toMap());
  }

  Future<List<Reminder>> getAllReminders() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(table);
    return List.generate(maps.length, (i) {
      return Reminder.fromMap(maps[i]);
    });
  }

  Future<int> update(Reminder reminder) async {
    Database db = await instance.database;
    return await db.update(table, reminder.toMap(),
        where: '$columnId = ?', whereArgs: [reminder.id]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
