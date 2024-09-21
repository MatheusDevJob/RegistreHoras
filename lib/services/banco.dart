import 'dart:io';
import 'package:matheus/services/helper.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<String> getPath() async {
  final String appDataPath = Platform.environment['APPDATA']!;
  final bancoDiretorio = Directory("$appDataPath/banco horas");

  if (!await bancoDiretorio.exists()) {
    await bancoDiretorio.create(recursive: true);
  }

  return bancoDiretorio.path;
}

Future<File> get banco async {
  String caminho = await getPath();
  return File('$caminho/banco_horas.txt');
}

Future<File> registrar(String data, String hora) async {
  final file = await banco;
  String registro = "$data $hora;\n";
  return file.writeAsString(registro, mode: FileMode.append);
}

Future<String> buscar() async {
  try {
    final file = await banco;
    return await file.readAsString();
  } catch (e) {
    return '';
  }
}

Future<Database?> iniciarBanco() async {
  try {
    // Init ffi loader if needed.
    sqfliteFfiInit();

    var databaseFactory = databaseFactoryFfi;

    String caminho = await getPath();

    //Create path for database
    String dbPath = p.join(caminho, "databases", "registroHoras.db");
    Database db = await databaseFactory.openDatabase(dbPath);
    return db;
    //   await db.execute('''
    //       CREATE TABLE Product (
    //           id INTEGER PRIMARY KEY,
    //           title TEXT
    //       )
    // ''');
    //   await db.insert('Product', <String, Object?>{'title': 'Product 1'});

    //   var result = await db.query('Product');
    //   print(result);
    //   // prints [{id: 1, title: Product 1}, {id: 2, title: Product 1}]
  } catch (e) {
    return null;
  }
}

void fecharBanco(Database db) async => await db.close();

Future<bool> registrarProjeto(String projetoName) async {
  Database? db = await iniciarBanco();
  if (db == null) return false;

  try {
    Map<String, String> dados = {
      'projetoNome': projetoName,
      'data_hora': getDataHora(),
    };
    await db.insert('projetos', dados);
    await db.close();
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> apagarProjeto(String id) async {
  Database? db = await iniciarBanco();
  if (db == null) return false;

  try {
    await db.delete('projetos', where: "id = ?", whereArgs: [id]);
    await db.close();
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> registrarCliente(String projetoCliente) async {
  Database? db = await iniciarBanco();
  if (db == null) return false;

  try {
    Map<String, String> dados = {
      'clienteNome': projetoCliente,
      'data_hora': getDataHora(),
    };
    await db.insert('clientes', dados);
    await db.close();
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> apagarCliente(String id) async {
  Database? db = await iniciarBanco();
  if (db == null) return false;

  try {
    await db.delete('clientes', where: "id = ?", whereArgs: [id]);
    await db.close();
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> registrarTarefa(String tarefaNome) async {
  Database? db = await iniciarBanco();
  if (db == null) return false;

  try {
    Map<String, String> dados = {
      'tarefaNome': tarefaNome,
      'data_hora': getDataHora(),
    };
    await db.insert('tarefas', dados);
    await db.close();
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> apagarTarefa(String id) async {
  Database? db = await iniciarBanco();
  if (db == null) return false;

  try {
    await db.delete('tarefas', where: "id = ?", whereArgs: [id]);
    await db.close();
    return true;
  } catch (e) {
    return false;
  }
}

Future<List<Map<String, dynamic>>> getDadosTabela(String nomeTabela) async {
  Database? db = await iniciarBanco();
  if (db == null) return [];
  try {
    List<Map<String, dynamic>> retorno = await db.query(nomeTabela);
    // await db.close();
    return retorno;
  } catch (e) {
    return [
      {"erro": e.toString()}
    ];
  }
}
