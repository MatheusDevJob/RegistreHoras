import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:matheus/screens/EdiarRegistro.dart';
import 'package:matheus/widgets/PegaData.dart';
import 'package:matheus/services/banco.dart';
import 'package:matheus/services/helper.dart';
import 'package:matheus/widgets/FutureDrop.dart';
import 'package:matheus/widgets/MyDrawer.dart';
import 'package:matheus/widgets/myAppBar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late String? dataInicio;
  late String? dataFinal;
  String? projetoID;
  String? clienteID;
  String? tarefaID;
  String? botaoDataInicial;
  String? botaoDataFinal;

  Future<List> buscarRegistros() async {
    List lista = await getRegistrosTabela(
      dataInicio: dataInicio,
      dataFinal: dataFinal,
      projetoID: projetoID,
      clienteID: clienteID,
      tarefaID: tarefaID,
    );
    return lista;
  }

  void buscarDadosPlanilha() async {
    List lista = await buscarRegistros();
    gerarPlanilha(lista).then((value) => alertDialog(context, value));
  }

  void getDataInicio(String? data) => dataInicio = data;
  void getDataFim(String? data) => dataFinal = data;
  void selecionarProjeto(String idProjeto) => projetoID = idProjeto;
  void selecionarCliente(String idCliente) => clienteID = idCliente;
  void selecionarTarefa(String idTarefa) => tarefaID = idTarefa;
  DateTime now = DateTime.now();

  @override
  void initState() {
    DateTime primeiroDia = DateTime(now.year, now.month, 1);
    DateTime ultimoDia = DateTime(now.year, now.month + 1, 0);

    botaoDataInicial = DateFormat("dd/MM/yyyy").format(primeiroDia);
    botaoDataFinal = DateFormat("dd/MM/yyyy").format(ultimoDia);
    dataInicio = DateFormat("yyyy-MM-dd").format(primeiroDia);
    dataFinal = DateFormat("yyyy-MM-dd").format(ultimoDia);

    super.initState();
  }

  void navegarEdicao(registro) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarRegistro(
          registros: registro,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        titulo: "Home",
        texto: SizedBox(
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
              double total = 0;
              for (var registro in data) {
                total += registro["valor_receber"];
              }
              return Text(
                  "Valor total a receber: R\$ ${total.toStringAsFixed(2)}");
            },
          ),
        ),
      ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => buscarDadosPlanilha(),
        child: const FaIcon(FontAwesomeIcons.fileExcel),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.all(5),
            child: Row(
              children: [
                const Text("Filtro por Data: "),
                PegaData(
                  retorno: getDataInicio,
                  textoBotao: "Data Inicial",
                  textoInicialBotao: botaoDataInicial!,
                ),
                const Text(" até "),
                PegaData(
                  retorno: getDataFim,
                  textoBotao: "Data Final",
                  textoInicialBotao: botaoDataFinal!,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FutureDrop(
                    onChange: selecionarProjeto,
                    tabelaBusca: "projetos",
                    nomeColuna: "projetoNome",
                    hintText: "Projeto",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FutureDrop(
                    onChange: selecionarCliente,
                    tabelaBusca: "clientes",
                    nomeColuna: "clienteNome",
                    hintText: "Cliente",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FutureDrop(
                    onChange: selecionarTarefa,
                    tabelaBusca: "tarefas",
                    nomeColuna: "tarefaNome",
                    hintText: "Tarefa",
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(4, 0, 4, 4),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(5),
              ),
              child: FutureBuilder(
                future: buscarRegistros(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.data!.isEmpty) {
                    return const Text("Nenhum registro encontrado.");
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  List<dynamic> data = snapshot.data!;

                  return Scrollbar(
                    interactive: false,
                    trackVisibility: true,
                    child: SingleChildScrollView(
                      child: Scrollbar(
                        interactive: false,
                        trackVisibility: true,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            dataRowHeight: 80,
                            columns: const [
                              DataColumn(label: Text("Ações")),
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
                                DataCell(
                                  const FaIcon(FontAwesomeIcons.pen),
                                  onTap: () => navegarEdicao(item),
                                ),
                                DataCell(Text(item["projetoNome"])),
                                DataCell(Text(item["clienteNome"])),
                                DataCell(Text(item["tarefaNome"])),
                                DataCell(
                                  SingleChildScrollView(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 600,
                                      ),
                                      child: Text(
                                        item["descricao_tarefa"],
                                        softWrap: true,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text(item["dataHoraInicioCompleta"])),
                                DataCell(Text(item["dataHoraFimCompleta"])),
                                DataCell(Text(item["valor_hora"].toString())),
                                DataCell(
                                    Text(item["horas_trabalhadas"].toString())),
                                DataCell(Text("R\$ ${item["valor_receber"]}")),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
