import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matheus/services/banco.dart';
import 'package:matheus/services/helper.dart';
import 'package:matheus/services/reformatarDados.dart';
import 'package:matheus/widgets/myAppBar.dart';

class RegistrarHoras extends StatefulWidget {
  const RegistrarHoras({super.key});

  @override
  State<RegistrarHoras> createState() => _RegistrarHorasState();
}

class _RegistrarHorasState extends State<RegistrarHoras> {
  TimeOfDay? hora;
  DateTime data = DateTime.now();
  String? horasHoje;
  List<String> listaHoras = [];
  Map<String, List> mapaDatas = {};
  String aberturaString = "";
  String fechamentoString = "";
  int abertura = 0;
  int fechamento = 0;

  @override
  void initState() {
    carregarHoras();
    super.initState();
  }

  void carregarHoras() async {
    var horas = await buscar();
    listaHoras = tratarHorasParaLista(horas);
    mapaDatas = separarDatas(listaHoras);
    calcularHorasTrabalhadasHoje();
  }

  void calcularHorasTrabalhadasHoje() {
    DateTime data = DateTime.now();
    String dataHoje = DateFormat('dd/MM/yyyy').format(data);
    contarHorasTrabalhadas(mapaDatas[dataHoje]);
  }

  contarHorasTrabalhadas(List? lista) {
    int horasTrabalhadas = 0;

    // converter horas em minutos e fazer o cálculo
    if (lista != null) {
      for (int i = 0; i < lista.length; i++) {
        var horas = lista[i];
        List<String> listaHoras = horas.split(":");
        int hora = int.parse(listaHoras[0]);
        int minuto = int.parse(listaHoras[1]);

        // se o horário é abertura, adicionar.
        if (i % 2 == 0) {
          abertura = hora * 60 + minuto;
          aberturaString = converterInteiroEmValorHora(abertura);
        }
        // se o horário é fechamento
        if (i % 2 == 1) {
          fechamento = hora * 60 + minuto;
          horasTrabalhadas += fechamento - abertura;
          fechamentoString = converterInteiroEmValorHora(fechamento);
        }
      }
    }

    setState(() => horasHoje = converterInteiroEmValorHora(horasTrabalhadas));
  }

  @override
  Widget build(BuildContext context) {
    void registrarHora() async {
      if (hora == null) {
        alertDialog(context, "Selecione um horário.", corCaixa: Colors.red);
        return;
      }
      String dataFormatada = DateFormat('dd/MM/yyyy').format(data);
      String horaFormatada = formatarHora(hora!);
      await registrar(dataFormatada, horaFormatada);

      carregarHoras();
    }

    Future<void> selectTime(BuildContext context) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: hora ?? TimeOfDay.now(),
      );
      if (picked != null && picked != hora) {
        setState(() => hora = picked);
      }
    }

    return Scaffold(
      appBar: const MyAppBar(titulo: "BANCO DE HORAS"),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("ULTIMO TURNO ABERTO: $aberturaString"),
                    Text("ULTIMO TURNO FECHADO: $fechamentoString"),
                  ],
                ),
                Text("HORAS HOJE: ${horasHoje ?? "-"}"),
              ],
            ),
            SizedBox(
              height: 400,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DatePickerDialog(
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2200),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ElevatedButton(
                        onPressed: () => selectTime(context),
                        child: Text(
                          hora != null
                              ? 'Hora Selecionada: ${hora!.format(context)}'
                              : 'Nenhuma hora selecionada',
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => registrarHora(),
                        child: const Text("Registrar Hora"),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
