import 'package:matheus/services/helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<Database?> iniciarBanco() async {
  try {
    // Init ffi loader if needed.
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    String caminho = await databaseFactory.getDatabasesPath();
    Database db =
        await databaseFactory.openDatabase("$caminho/registroHoras.db");
    // Verificar se a tabela 'projetos' existe
    await db.execute('''
          CREATE TABLE IF NOT EXISTS projetos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            projetoNome TEXT NOT NULL UNIQUE,
            clienteID INTEGER NOT NULL,
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

    // código SQLite para resetar tabela
    // DELETE FROM registros;
    // VACUUM;

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

Future<bool> registrarProjeto(String projetoName, String clienteID) async {
  Database? db = await iniciarBanco();
  if (db == null) return false;

  try {
    Map<String, String> dados = {
      'projetoNome': projetoName,
      'clienteID': clienteID,
      'data_hora': getDataHora(),
    };
    await db.insert('projetos', dados);
    await db.close();
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> atualizarProjeto(String id, String novoNome) async {
  Database? db = await iniciarBanco();
  if (db == null) return false;

  try {
    await db.update(
      'projetos',
      {"projetoNome": novoNome},
      where: "id = ?",
      whereArgs: [id],
    );
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

Future<bool> atualizarCliente(String id, String nomeCliente) async {
  Database? db = await iniciarBanco();
  if (db == null) return false;

  try {
    await db.update(
      'clientes',
      {"clienteNome": nomeCliente},
      where: "id = ?",
      whereArgs: [id],
    );
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

Future<bool> atualizarTarefa(String id, nomeTarefa) async {
  Database? db = await iniciarBanco();
  if (db == null) return false;

  try {
    await db.update(
      'tarefas',
      {"tarefaNome": nomeTarefa},
      where: "id = ?",
      whereArgs: [id],
    );
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

Future getRegistrosTabela({
  String? dataInicio,
  String? dataFinal,
  String? projetoID,
  String? clienteID,
  String? tarefaID,
}) async {
  Database? db = await iniciarBanco();
  if (db == null) return [];
  try {
    String query = '''
        SELECT 
          registros.id,
          registros.data_hora_inicio,
          registros.data_hora_fim,
          registros.descricao_tarefa,
          registros.valor_hora,
          registros.horas_trabalhadas,
          registros.valor_receber,
          registros.projetoID,
          registros.clienteID,
          registros.tarefaID,
          strftime('%Y-%m-%d', data_hora_inicio) AS dataUSAInicio,
          strftime('%Y-%m-%d', data_hora_fim) AS dataUSAFim,
          strftime('%d/%m/%Y', data_hora_inicio) AS dataHoraInicio,
          strftime('%d/%m/%Y', data_hora_fim) AS dataHoraFim,
          strftime('%d/%m/%Y %H:%M:%S', data_hora_inicio) AS dataHoraInicioCompleta,
          strftime('%d/%m/%Y %H:%M:%S', data_hora_fim) AS dataHoraFimCompleta,
          strftime('%H:%M:%S', data_hora_inicio) AS horaInicio,
          strftime('%H:%M:%S', data_hora_fim) AS horaFim,
          projetos.projetoNome,
          clientes.clienteNome,
          tarefas.tarefaNome 
        FROM registros
        JOIN projetos ON projetos.id = registros.projetoID
        JOIN clientes ON clientes.id = registros.clienteID
        JOIN tarefas ON tarefas.id = registros.tarefaID
    ''';

    // Lista para armazenar todas as condições WHERE
    List<String> conditions = [];

    // Adiciona as condições conforme os parâmetros fornecidos
    if (dataInicio != null && dataFinal != null) {
      conditions.add(
          'data_hora_inicio >= "$dataInicio 00:00:00" AND data_hora_fim <= "$dataFinal 23:59:59"');
    }
    if (projetoID != null && projetoID != "null") {
      conditions.add('registros.projetoID = "$projetoID"');
    }
    if (clienteID != null && clienteID != "null") {
      conditions.add('registros.clienteID = "$clienteID"');
    }
    if (tarefaID != null && tarefaID != "null") {
      conditions.add('registros.tarefaID = "$tarefaID"');
    }

    // Se houver condições, adiciona a cláusula WHERE
    if (conditions.isNotEmpty) {
      query += ' WHERE ${conditions.join(' AND ')}';
    }
    query += " ORDER BY registros.data_hora_inicio DESC";
    List<Map<String, dynamic>> retorno = await db.rawQuery(query);
    return retorno;
  } catch (e) {
    return [];
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
    List<Map<String, dynamic>> retorno = await db.rawQuery('''
      SELECT 
        r.id,
        r.data_hora_inicio,
        r.descricao_tarefa,
        r.valor_hora,
        p.projetoNome,
        c.clienteNome, 
        t.tarefaNome
      FROM registros r
      JOIN projetos p ON p.id = r.projetoID
      JOIN clientes c ON c.id = r.clienteID
      JOIN tarefas t ON t.id = r.tarefaID
      WHERE r.data_hora_fim IS NULL
      ''');
    await db.close();
    return retorno;
  } catch (e) {
    return [
      {"erro": e.toString()}
    ];
  }
}

Future<int> atualizarAtividade(
  int atividadeID,
  String dataHoraFinalizacao,
  String horasTrabalhadas,
  double valorReceber,
  String descricaoTarefa,
) async {
  Database? db = await iniciarBanco();
  if (db == null) return 0;
  try {
    Map<String, dynamic> dados = {
      'data_hora_fim': dataHoraFinalizacao,
      'horas_trabalhadas': horasTrabalhadas,
      'valor_receber': valorReceber.toStringAsFixed(2),
      'descricao_tarefa': descricaoTarefa,
    };
    return db
        .update("registros", dados, where: "id = ?", whereArgs: [atividadeID]);
  } catch (e) {
    return 0;
  }
}

// funções de uso geral

Future<int> update(String tabela, Map<String, dynamic> dados,
    {String? onde, List<String>? argumento}) async {
  Database? db = await iniciarBanco();
  if (db == null) return 0;
  try {
    return db.update(tabela, dados, where: onde, whereArgs: argumento);
  } catch (e) {
    return 0;
  }
}

Future<int> delete(String tabela, {String? onde, List? argumento}) async {
  Database? db = await iniciarBanco();
  if (db == null) return 0;
  try {
    return db.delete(tabela, where: onde, whereArgs: argumento);
  } catch (e) {
    return 0;
  }
}
