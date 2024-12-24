import 'dart:ffi';
import 'package:sqlite3/sqlite3.dart';

int main()
{
  final db = sqlite3.openInMemory();

  db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY,
      name TEXT,
      age INTEGER
    )
  ''');

  db.execute('''
    INSERT INTO users (name, age)
    VALUES ('Alice', 30)
  ''');

  db.execute('''
    INSERT INTO users (name, age)
    VALUES ('Bob', 20)
  ''');

  final result = db.select('SELECT * FROM users');

  for (final row in result) {
    print(row);
  }

  db.dispose();

  return 0;
}