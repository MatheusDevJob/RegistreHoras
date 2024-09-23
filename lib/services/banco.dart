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
    String caminho = await getPath();
    databaseFactory = databaseFactoryFfi;
    //Create path for database
    String dbPath = p.join(caminho, "databases", "registroHoras.db");

    // Verificar se o diretório existe, se não, criar o diretório
    if (!await Directory(p.dirname(dbPath)).exists()) {
      await Directory(p.dirname(dbPath)).create(recursive: true);
    }
    Database db = await databaseFactory.openDatabase(dbPath);
    // Verificar se a tabela 'projetos' existe
    await db.execute('''
          CREATE TABLE IF NOT EXISTS projetos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            projetoNome TEXT NOT NULL UNIQUE,
            data_hora TEXT NOT NULL
          );
        ''');

    // Verificar se a tabela 'clientes' existe
    await db.execute('''
          CREATE TABLE IF NOT EXISTS clientes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            clienteNome TEXT NOT NULL UNIQUE,
            data_hora TEXT NOT NULL
          );
        ''');

    // Verificar se a tabela 'tarefas' existe
    await db.execute('''
          CREATE TABLE IF NOT EXISTS tarefas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tarefaNome TEXT NOT NULL,
            data_hora TEXT NOT NULL
          );
        ''');

    await db.execute('''
          CREATE TABLE IF NOT EXISTS
            registros (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                projetoID INTEGER NOT NULL,
                clienteID INTEGER NOT NULL,
                tarefaID INTEGER NOT NULL,
                data_hora_inicio TEXT NOT NULL,
                data_hora_fim TEXT,
                descricao_tarefa TEXT,
                valor_hora REAL NOT NULL,
                horas_trabalhadas REAL,
                valor_receber INTEGER,
                FOREIGN KEY (projetoID) REFERENCES projetos (id),
                FOREIGN KEY (clienteID) REFERENCES clientes (id),
                FOREIGN KEY (tarefaID) REFERENCES tarefas (id)
            );
        ''');

    return db;
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

Future<int> registrarAtividade(
  String projetoID,
  String clienteID,
  String tarefaID,
  String dataHoraInicio,
  String descricaoTarefa,
  String valorHora,
) async {
  Database? db = await iniciarBanco();
  if (db == null) return 2;

  try {
    Map<String, String> dados = {
      'projetoID': projetoID,
      'clienteID': clienteID,
      'tarefaID': tarefaID,
      'data_hora_inicio': dataHoraInicio,
      'descricao_tarefa': descricaoTarefa,
      'valor_hora': valorHora,
    };
    await db.insert('registros', dados);

    await db.close();
    return 1;
  } catch (e) {
    return 2;
  }
}

Future<List<Map<String, dynamic>>> getAtividadeAberta() async {
  Database? db = await iniciarBanco();
  if (db == null) return [];
  try {
    List<Map<String, dynamic>> retorno = await db.query(
      "registros",
      where: "data_hora_fim = NULL",
    );
    await db.close();
    return retorno;
  } catch (e) {
    return [
      {"erro": e.toString()}
    ];
  }
}
