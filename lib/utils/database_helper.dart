import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import '../models/add_todo_model.dart';

class DatabaseHelper {
  // Table and column names
  static const _dbName = 'todo_db';
  static const _dbVersion = 1;
  static const tableTodos = 'todos';
  static const columnId = '_id';
  static const columnText = 'text';
  static const columnAudio = 'audio';
  static const columnVideo = 'video';
  static const columnImage = 'image';
  static const columnPdf = 'pdf';
  static const columnDoc = 'doc';
  static const columnGeoLocation = 'geolocation';
  static const columnTime = 'time';

// Make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  // Initialize the database
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  // Create the todos table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTodos (
        $columnId INTEGER PRIMARY KEY,
        $columnText TEXT,
        $columnAudio TEXT,
        $columnVideo TEXT,
        $columnImage TEXT,
        $columnPdf TEXT,
        $columnDoc TEXT,
        $columnGeoLocation TEXT,
        $columnTime TEXT
      )
    ''');
  }

  // Insert a todo item into the database
  Future<int> insert(Todo todo) async {
    Database db = await database;
    return await db.insert(tableTodos, todo.toMap());
  }

  // Get all todo items from the database
  Future<List<Todo>> getTodos() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(tableTodos);
    return List.generate(maps.length, (i) {
      print('columnTime: ${maps[i][columnTime]}');
      return Todo(
        columnId: maps[i][columnId],
        columnText: maps[i][columnText],
        columnAudio: maps[i][columnAudio],
        columnVideo: maps[i][columnVideo],
        columnImage: maps[i][columnImage],
        columnPdf: maps[i][columnPdf],
        columnDoc: maps[i][columnDoc],
        columnGeolocation: maps[i][columnGeoLocation],
        columnTime: DateFormat('dd-MM-yyyy HH:mm')
            .format(DateTime.parse(maps[i][columnTime])),
      );
    });
  }

  // Update a todo item in the database
  Future<int> update(Todo todo) async {
    final db = await database;
    return await db.update(tableTodos, todo.toMap(),
        where: '$columnId = ?', whereArgs: [todo.columnId]);
  }

  // Delete a todo item from the database
  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(tableTodos, where: '$columnId = ?', whereArgs: [id]);
  }
}
