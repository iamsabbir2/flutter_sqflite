import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PersonDatabaseHelper {
  static PersonDatabaseHelper?
      _personDatabaseHelper; // Singleton DatabaseHelper
  static Database? _database; // Singleton Database
  String personTable = 'personsTable';
  String personFullName = 'fullName';
  String personEmail = 'email';
  String personPhoneNumber = 'phoneNumber';
  String personPassword = 'password';
  String personBirthDate = 'birthDate';
  String personGender = 'gender';

  PersonDatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory PersonDatabaseHelper() {
    //initialize the object
    if (_personDatabaseHelper == null) {
      _personDatabaseHelper = PersonDatabaseHelper._createInstance();
    }
    return _personDatabaseHelper!;
  }

  //Getter for the database
  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}persons.db';
//    String path = directory.path + 'persons.db';

    // Open/create the database at a given path
    var personDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    print('Database Created');
    return personDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    if (_database == null) {
      await db.execute(
          'CREATE TABLE &personTable(&personFullName TEXT, &personEmail TEXT PRIMARY KEY, &personPhoneNumber TEXT, &personPassword TEXT, &personBirthDate TEXT, &personGender TEXT)');
    }

    // Fetch Operation: Get all person objects from database
    Future<List<Map<String, dynamic>>> getPerson(String email) async {
      Database db = await this.database;
      var result = await db.rawQuery(
          'SELECT * FROM &personTable WHERE &personEmail = \'$email\'');
      return result;
    }

    // Insert Operation: Insert a person object to database
    // Future<int> insertPerson(person) async {
    //   Database db = await this.database;
    //   var result = await db.insert(personTable, person.toMap()
    //   : '&personEmail = ?', whereArgs: [person.email]);
    //   return result;
    // }

    Future<int> insertPerson(person) async {
      Database db = await database; // Removed 'this.'
      var result = await db.insert(
        personTable,
        person.toMap(),
        conflictAlgorithm: ConflictAlgorithm
            .replace, // Added conflictAlgorithm for better handling
      );
      return result;
    }

    // Update Operation
    Future<int> updatePerson(person) async {
      Database db = await this.database;
      var result = await db.update(personTable, person.toMap(),
          where: '$personEmail = ?', whereArgs: [person.email]);
      return result;
    }

    // Delete Operation
    Future<int> deletePerson(String email) async {
      Database db = await this.database;
      var result = await db.rawDelete(
          'DELETE FROM $personTable WHERE $personEmail = ?', [email]);
      return result;
    }
  }
}
