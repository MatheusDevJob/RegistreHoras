import 'package:matheus/services/banco.dart';

class Financeiro {
  Future<Map> getDadosFinancas() async {
    return {
      "gastos": await get("gastos_mensais"),
      "lucros": await get("lucros_mensais"),
    };
  }
}
