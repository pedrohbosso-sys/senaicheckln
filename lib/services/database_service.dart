import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/registro.dart';

class DatabaseService {
  static final instance = DatabaseService();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      join(await getDatabasesPath(), 'senai_checkin.db'),
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE registros (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          data_hora TEXT NOT NULL,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          precisao REAL NOT NULL,
          observacao TEXT NOT NULL,
          caminho_da_foto TEXT NOT NULL
        )
      '''),
    );
    return _db!;
  }

  Future<int> inserir(Registro registro) async {
    final db = await database;
    return db.insert('registros', registro.toMap());
  }

  Future<List<Registro>> listar() async {
    final db = await database;
    final maps = await db.query('registros', orderBy: 'data_hora DESC');
    return maps.map(Registro.fromMap).toList();
  }
}
