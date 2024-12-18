import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:matheus/screens/EdiarRegistro.dart';
import 'package:matheus/screens/registrarHoras.dart';
import 'package:matheus/services/reformatarDados.dart';
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

  // variáveis paginação
  int page = 0;
  int atualPage = 1;
  int totalPage = 0;
  bool avancar = true;
  int? limit = 10;
  final List<Map<String, dynamic>> items = [
    {'id': 0, 'nome': 'Tudo'},
    {'id': 10, 'nome': '10'},
    {'id': 50, 'nome': '50'},
    {'id': 100, 'nome': '100'},
  ];

  Future<List> buscarRegistros() async {
    List lista = await getRegistrosTabela(
      dataInicio: dataInicio,
      dataFinal: dataFinal,
      projetoID: projetoID,
      clienteID: clienteID,
      tarefaID: tarefaID,
      limite: limit,
      offset: page,
    );
    return lista;
  }

  void buscarDadosPlanilha() async {
    List lista = await buscarRegistros();
    gerarPlanilha(lista).then((value) => alertDialog(
          context,
          value,
          corCaixa: Colors.white,
        ));
  }

  void getDataInicio(String? data) => dataInicio = data;
  void getDataFim(String? data) => dataFinal = data;
  void selecionarProjeto(String idProjeto) => projetoID = idProjeto;
  void selecionarCliente(String idCliente) {
    clienteID = idCliente;
    projetoID = null;
  }

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

  Future<int> apagarRegistro(int id) async {
    return await delete("registros", onde: "id = ?", argumento: [id]);
  }

  void abrirConfirmacao(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      isDismissible: false,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                "Você tem certeza que deseja apagar o registro? NÃO HÁ VOLTA!!!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(item["descricao_tarefa"]),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      apagarRegistro(item["id"]).then((int num) {
                        if (num > 0) setState(() {});
                        Navigator.of(context).pop(); // Fecha o modal
                      });
                    },
                    child: const Text("Confirmar"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  voltarPagina() async {
    if (page <= 0 || limit == 0) {
      page = 0;
      limit = 0;
      alertDialog(context, "Não há mais dados.", corCaixa: Colors.white);
      return;
    }
    atualPage--;
    setState(() {
      page -= limit!;
    });
  }

  avancarPagina() async {
    if (!avancar || limit == 0) {
      alertDialog(context, "Não há mais dados.", corCaixa: Colors.white);
      return;
    }
    atualPage++;
    setState(() {
      page += limit!;
    });
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
              List result = somaHorasValor(data);
              double total = result[0];
              String horas = result[1];

              return Text(
                "Total de horas trabalhadas: $horas.\n Valor total a receber: R\$ ${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              );
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
            child: Column(
              children: [
                Row(
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
                    Flexible(
                      flex: 2,
                      child: ConjuntoFutureDrop(
                        funcCliente: selecionarCliente,
                        funcProjeto: selecionarProjeto,
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
                      style: const ButtonStyle(
                          iconSize: WidgetStatePropertyAll(40)),
                      onPressed: () => setState(() {}),
                      icon: const Icon(Icons.search),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text("Quantidade por Página: "),
                        SizedBox(
                          width: 200,
                          child: DropdownButtonFormField<int>(
                            value: limit,
                            hint: const Text("Limite Linhas"),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 0),
                            ),
                            items: items.map((Map<String, dynamic> item) {
                              return DropdownMenuItem<int>(
                                value: item['id'],
                                child: Text(item['nome']),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => limit = value),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text("PÁGINA: "),
                        IconButton(
                          onPressed: () => voltarPagina(),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        Text(atualPage.toString()),
                        IconButton(
                          onPressed: () => avancarPagina(),
                          icon: const Icon(Icons.arrow_forward),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(4, 0, 4, 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1),
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

                  avancar = data.length < limit! ? false : true;
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
                                  FaIcon(
                                    FontAwesomeIcons.pen,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  onTap: () => navegarEdicao(item),
                                  onLongPress: () => abrirConfirmacao(item),
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
