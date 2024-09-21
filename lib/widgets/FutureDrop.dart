import 'package:flutter/material.dart';
import 'package:matheus/services/banco.dart';

class FutureDrop extends StatefulWidget {
  final Function onChange;
  final String? nomeColuna;
  final String tabelaBusca;
  const FutureDrop({
    super.key,
    required this.onChange,
    required this.nomeColuna,
    required this.tabelaBusca,
  });

  @override
  State<FutureDrop> createState() => _FutureDropState();
}

class _FutureDropState extends State<FutureDrop> {
  String? selecionado;
  late Function funcaoOnChange;
  late String? nomeColuna;
  late String tabelaBusca;
  @override
  void initState() {
    funcaoOnChange = widget.onChange;
    nomeColuna = widget.nomeColuna;
    tabelaBusca = widget.tabelaBusca;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getDadosTabela(tabelaBusca),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Erro: ${snapshot.error}");
        } else if (!snapshot.hasData) {
          return const Text("Nenhum dado disponível");
        }
        List<Map<String, dynamic>> data = snapshot.data!;
        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          hint: const Text("Selecione uma opção"),
          value: selecionado,
          onChanged: (newValue) {
            setState(() {
              selecionado = newValue.toString();
              funcaoOnChange(newValue);
            });
          },
          items:
              data.map<DropdownMenuItem<String>>((Map<String, dynamic> item) {
            return DropdownMenuItem<String>(
              value: item['id'].toString(),
              child: Text(item[nomeColuna]),
            );
          }).toList(),
        );
      },
    );
  }
}
