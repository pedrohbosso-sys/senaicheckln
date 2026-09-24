import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'registro_model.dart';

/// Gerenciador do banco de dados SQLite local.
class RegistroDbhelper {
  static final instance = RegistroDbhelper();
  Database? _db;

  /// Retorna a instância ativa do banco de dados ou a inicializa
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      join(await getDatabasesPath(), 'senai_checkin.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE registros (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            data_hora TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            precisao REAL NOT NULL,
            observacao TEXT NOT NULL,
            caminho_da_foto TEXT NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  /// Insere um novo registro no banco de dados SQLite
  Future<int> inserir(Registro registro) async {
    final db = await database;
    return await db.insert('registros', registro.toMap());
  }

  /// Retorna a lista de todos os registros ordenados do mais recente para o mais antigo
  Future<List<Registro>> listar() async {
    final db = await database;
    final maps = await db.query(
      'registros',
      orderBy: 'data_hora DESC, id DESC',
    );
    return maps.map(Registro.fromMap).toList();
  }
}
