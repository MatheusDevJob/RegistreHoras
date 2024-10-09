import 'package:flutter/material.dart';
import 'package:matheus/services/banco.dart';

class FutureDrop extends StatefulWidget {
  final Function onChange;
  final String? selecionado;
  final String? nomeColuna;
  final String tabelaBusca;
  final String hintText;
  const FutureDrop({
    super.key,
    required this.onChange,
    required this.nomeColuna,
    required this.tabelaBusca,
    this.hintText = "Selecione uma opção",
    this.selecionado,
  });

  @override
  State<FutureDrop> createState() => _FutureDropState();
}

class _FutureDropState extends State<FutureDrop> {
  late String? selecionado;
  late Function funcaoOnChange;
  late String? nomeColuna;
  late String tabelaBusca;
  late String? hintText;
  @override
  void initState() {
    selecionado = widget.selecionado;
    funcaoOnChange = widget.onChange;
    nomeColuna = widget.nomeColuna;
    tabelaBusca = widget.tabelaBusca;
    hintText = widget.hintText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: get(tabelaBusca, onde: "status = ?", argumento: [1]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Erro: ${snapshot.error}");
        } else if (!snapshot.hasData) {
          return const Text("Nenhum dado disponível");
        }
        List<Map<String, dynamic>> antigaData = snapshot.data!;
        List<Map<String, dynamic>> data = [];

        data.add({'id': null, nomeColuna!: hintText});
        for (var valor in antigaData) {
          data.add(valor);
        }
        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          hint: Text(hintText!),
          value: selecionado,
          onChanged: (newValue) {
            setState(() {
              selecionado = newValue.toString();
              funcaoOnChange(newValue);
            });
          },
          validator: (value) {
            if (value == null || value == "null" || value.isEmpty) {
              return "Informe o registro.";
            }
            return null;
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
