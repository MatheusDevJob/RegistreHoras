import 'package:flutter/material.dart';
import 'package:matheus/services/banco.dart';
import 'package:matheus/widgets/MyDrawer.dart';
import 'package:matheus/widgets/myAppBar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String total = "a";
  Future<List> buscarRegistros() async {
    List lista = await getRegistrosTabela();

    return lista;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(titulo: "Home"),
      drawer: const MyDrawer(),
      floatingActionButton: FutureBuilder(
          future: buscarRegistros(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (!snapshot.hasData) {
              return const Text("Nenhum registro encontrado.");
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            List<dynamic> data = snapshot.data!;
            double total = 0;
            for (var registro in data) {
              total += registro["valor_receber"];
            }
            return Text("Valor total a receber: R\$ $total");
          }),
      body: Center(
        child: FutureBuilder(
          future: buscarRegistros(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (!snapshot.hasData) {
              return const Text("Nenhum registro encontrado.");
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            List<dynamic> data = snapshot.data!;

            return Scrollbar(
              interactive: false,
              trackVisibility: true,
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text("Projet")),
                      DataColumn(label: Text("Cliente")),
                      DataColumn(label: Text("Tarefa")),
                      DataColumn(label: Text("Descrição")),
                      DataColumn(label: Text("Data Abertura")),
                      DataColumn(label: Text("Data Conclusão")),
                      DataColumn(label: Text("Valor Hora")),
                      DataColumn(label: Text("Horas Trabalhadas")),
                      DataColumn(label: Text("Valor Cobrar")),
                    ],
                    rows: data.map<DataRow>((item) {
                      return DataRow(cells: [
                        DataCell(Text(item["projetoNome"])),
                        DataCell(Text(item["clienteNome"])),
                        DataCell(Text(item["tarefaNome"])),
                        DataCell(Text(item["descricao_tarefa"])),
                        DataCell(Text(item["dataHoraInicio"])),
                        DataCell(Text(item["dataHoraFim"])),
                        DataCell(Text(item["valor_hora"].toString())),
                        DataCell(Text(item["horas_trabalhadas"].toString())),
                        DataCell(Text(item["valor_receber"].toString())),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
