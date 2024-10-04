import 'package:flutter/material.dart';

class PegaHora extends StatefulWidget {
  final Function(String) retorno;
  final String textoBotao;
  final String textoInicialBotao;
  final TimeOfDay? horaAtual;
  const PegaHora({
    super.key,
    required this.retorno,
    required this.textoBotao,
    required this.textoInicialBotao,
    this.horaAtual,
  });

  @override
  State<PegaHora> createState() => _PegaHoraState();
}

class _PegaHoraState extends State<PegaHora> {
  late String botao;
  late Function retorno;
  late TimeOfDay? horaAtual;
  @override
  void initState() {
    botao = widget.textoInicialBotao;
    retorno = widget.retorno;
    horaAtual = widget.horaAtual ?? TimeOfDay.now();
    super.initState();
  }

  void trataHora(TimeOfDay? data) {
    if (data == null) {
      botao = widget.textoBotao;
      retorno(null);
    } else {
      botao = "${data.format(context)}:00";
      retorno(botao);
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
      onTap: () => showTimePicker(
        context: context,
        initialTime: horaAtual!,
      ).then((value) {
        if (value == null) return;
        trataHora(value);
      }),
    );
  }
}
