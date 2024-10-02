import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PegaData extends StatefulWidget {
  final Function(String) retorno;
  final String textoBotao;
  final String textoInicialBotao;
  const PegaData({
    super.key,
    required this.retorno,
    required this.textoBotao,
    required this.textoInicialBotao
  });

  @override
  State<PegaData> createState() => _PegaDataState();
}

class _PegaDataState extends State<PegaData> {
  late String botao;
  late Function retorno;
  @override
  void initState() {
    botao = widget.textoInicialBotao;
    retorno = widget.retorno;
    super.initState();
  }

  void trataData(DateTime? data) {
    if (data == null) {
      botao = widget.textoBotao;
      retorno(null);
    } else {
      botao = DateFormat("dd/MM/yyyy").format(data);
      retorno(DateFormat("yyyy-MM-dd").format(data));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.deepPurple),
          color: Colors.deepPurple,
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        padding: const EdgeInsets.all(5),
        child: Text(
          botao,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      onTap: () => showDatePicker(
        initialDate: DateTime.now(),
        context: context,
        firstDate: DateTime(1800),
        lastDate: DateTime(2300),
      ).then((value) {
        trataData(value);
      }),
    );
  }
}
