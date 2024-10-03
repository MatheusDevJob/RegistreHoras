import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String? horaRetornar;
String? minutoRetornar;

String formatarHora(TimeOfDay horaMinuto) {
  int hora = horaMinuto.hour;
  int minuto = horaMinuto.minute;

  horaRetornar = horaParaString(hora);
  minutoRetornar = horaParaString(minuto);

  return "$horaRetornar:$minutoRetornar";
}

String horaParaString(int horaMinuto) {
  String retornar;
  // adicionar o segundo dígito
  if (contarDigitosNumero(horaMinuto) < 2) {
    retornar = "0$horaMinuto";
  } else {
    retornar = horaMinuto.toString();
  }
  return retornar;
}

int contarDigitosNumero(int numero) {
  String numeroString = numero.toString();

  return numeroString.length;
}

List<String> tratarHorasParaLista(String horas) {
  List<String> lista = horas.split(';');

  // Remove trim caracteres de nova linha
  lista = lista
      .where((item) => item.isNotEmpty)
      .map((item) => item.trim())
      .toList();
  // apaga itens vazios
  lista.removeWhere((item) => item == "");

  return lista;
}

Map<String, List> separarDatas(List<String> lista) {
  Map<String, List> retorno = {};

  for (int i = 0; i < lista.length; i++) {
    var dataHora = lista[i];
    List listaDataHora = dataHora.split(" ");
    String data = listaDataHora[0];
    String hora = listaDataHora[1];

    if (retorno.containsKey(data)) {
      // Se a data já existe, adiciona a hora à lista existente
      retorno[data]!.add(hora);
    } else {
      // Se a data não existe, cria uma nova entrada no mapa com a hora
      retorno[data] = [hora];
    }
  }

  return retorno;
}

String converterInteiroEmValorHora(int horaMinuto) {
  horaRetornar = horaParaString(horaMinuto ~/ 60);
  minutoRetornar = horaParaString(horaMinuto % 60);
  return "$horaRetornar:$minutoRetornar";
}

Map<String, dynamic> calcularHorasEValor(
  String dataHoraInicial,
  String dataHoraFinal,
  double valorHora,
) {
  DateTime data1 = DateFormat("yyyy-MM-dd HH:mm:ss").parse(dataHoraInicial);
  DateTime data2 = DateFormat("yyyy-MM-dd HH:mm:ss").parse(dataHoraFinal);

  double valorMinuto = valorHora / 60;

  Duration diff = data2.difference(data1);
  int minutosTrabalhados = diff.inMinutes;
  if (minutosTrabalhados < 1) {
    return {
      'status': false,
      'msg':
          'Data e Hora inválidas. Você abriu essa atividade as $dataHoraInicial e tentou fechar as $dataHoraFinal',
    };
  }
  int horas = minutosTrabalhados ~/ 60;
  int minutos = minutosTrabalhados % 60;

  double valorReceber = minutosTrabalhados * valorMinuto;

  return {
    'status': true,
    'horasTrabalhadas': '$horas:$minutos',
    'valorReceber': valorReceber,
  };
}
