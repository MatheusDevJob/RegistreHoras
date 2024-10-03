import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

void alerteToast(
  BuildContext context,
  String msg, {
  Color corCaixa = const Color.fromRGBO(74, 20, 140, 1),
  Color corTexto = Colors.white,
  ToastGravity posicao = ToastGravity.BOTTOM,
}) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: posicao,
    backgroundColor: corCaixa,
    textColor: corTexto,
  );
}

void alertDialog(
  BuildContext context,
  String msg, {
  Color corCaixa = const Color.fromRGBO(74, 20, 140, 1),
  Color corTexto = Colors.white,
  int duracao = 3,
}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: corCaixa,
    duration: Duration(seconds: duracao),
    showCloseIcon: true,
  ));
}

String getDataHora() {
  DateTime now = DateTime.now();

  // Formatação de data no padrão de dois dígitos para dia e mês
  String formattedDate = DateFormat('yyyy-MM-dd').format(now);
  String formattedTime = DateFormat('HH:mm:ss').format(now);
  return '$formattedDate $formattedTime';
}

Future<String> gerarPlanilha(List lista) async {
  if (lista.isEmpty) return "Lista vazia.";
  var excel = Excel.createExcel();

  // Adiciona dados na primeira linha e coluna da planilha padrão
  excel['Sheet1'].cell(CellIndex.indexByString("A1")).value =
      TextCellValue("Projeto");
  excel['Sheet1'].cell(CellIndex.indexByString("B1")).value =
      TextCellValue("Cliente");
  excel['Sheet1'].cell(CellIndex.indexByString("C1")).value =
      TextCellValue("Tarefa");
  excel['Sheet1'].cell(CellIndex.indexByString("D1")).value =
      TextCellValue("Data Hora Início");
  excel['Sheet1'].cell(CellIndex.indexByString("E1")).value =
      TextCellValue("Data Hora Conclusão");
  excel['Sheet1'].cell(CellIndex.indexByString("F1")).value =
      TextCellValue("Descrição");
  excel['Sheet1'].cell(CellIndex.indexByString("G1")).value =
      TextCellValue("Valor Hora");
  excel['Sheet1'].cell(CellIndex.indexByString("H1")).value =
      TextCellValue("Horas Trabalhadas");
  excel['Sheet1'].cell(CellIndex.indexByString("I1")).value =
      TextCellValue("Valor Receber");
  excel['Sheet1'].cell(CellIndex.indexByString("J1")).value =
      TextCellValue("Total");

  // Adiciona mais dados
  int indice = 2;
  double total = 0;
  for (var i = 0; i < lista.length; i++) {
    Map row = lista[i];
    excel['Sheet1'].cell(CellIndex.indexByString("A$indice")).value =
        TextCellValue(row["projetoNome"]);
    excel['Sheet1'].cell(CellIndex.indexByString("B$indice")).value =
        TextCellValue(row["clienteNome"]);
    excel['Sheet1'].cell(CellIndex.indexByString("C$indice")).value =
        TextCellValue(row["tarefaNome"]);
    excel['Sheet1'].cell(CellIndex.indexByString("D$indice")).value =
        TextCellValue(row["dataHoraInicioCompleta"]);
    excel['Sheet1'].cell(CellIndex.indexByString("E$indice")).value =
        TextCellValue(row["dataHoraFimCompleta"]);
    excel['Sheet1'].cell(CellIndex.indexByString("F$indice")).value =
        TextCellValue(row["descricao_tarefa"]);
    excel['Sheet1'].cell(CellIndex.indexByString("G$indice")).value =
        TextCellValue(row["valor_hora"].toString());
    excel['Sheet1'].cell(CellIndex.indexByString("H$indice")).value =
        TextCellValue(row["horas_trabalhadas"].toString());
    excel['Sheet1'].cell(CellIndex.indexByString("I$indice")).value =
        TextCellValue("R\$: ${row["valor_receber"].toString()}");
    indice++;

    total += row["valor_receber"];
  }
  excel['Sheet1'].cell(CellIndex.indexByString("J2")).value =
      TextCellValue("R\$: $total");
  String dataHora = getDataHora();
  dataHora = dataHora.replaceAll(":", "-");

  // Gera um arquivo temporário para salvar o Excel
  Directory tempDir = await getApplicationDocumentsDirectory();

  String tempPath = "${tempDir.path}/$dataHora.xlsx";
  File(tempPath)
    ..createSync(recursive: true)
    ..writeAsBytesSync(excel.encode()!);

  return "Arquivo Excel gerado em: $tempPath";
}
