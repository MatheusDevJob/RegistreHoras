import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:matheus/widgets/FutureDrop.dart';
import 'package:matheus/widgets/MyDrawer.dart';
import 'package:matheus/widgets/PegaData.dart';
import 'package:matheus/widgets/PegaHora.dart';
import 'package:matheus/widgets/myAppBar.dart';

class EditarRegistro extends StatefulWidget {
  final Map<String, dynamic> registros;
  const EditarRegistro({super.key, required this.registros});

  @override
  State<EditarRegistro> createState() => _EditarRegistroState();
}

class _EditarRegistroState extends State<EditarRegistro> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController registroC = TextEditingController();
  final TextEditingController valorHoraC = TextEditingController();

  late Map<String, dynamic> registros;
  late String horasAbertura;
  late String horasFechamento;
  late String dataAbertura;
  late String dataFechamento;
  String? projetoID;
  String? clienteID;
  String? tarefaID;
  late DateTime dataInicio;
  late DateTime dataFinal;

  bool rotate = false;
  @override
  void initState() {
    registros = widget.registros;

    registroC.text = registros["descricao_tarefa"];
    valorHoraC.text = registros["valor_hora"].toString();
    projetoID = registros["projetoID"].toString();
    clienteID = registros["clienteID"].toString();
    tarefaID = registros["tarefaID"].toString();
    horasAbertura = registros["horaInicio"];
    horasFechamento = registros["horaFim"];
    dataInicio = DateTime.parse(registros["data_hora_inicio"]);
    dataFinal = DateTime.parse(registros["data_hora_fim"]);
    dataAbertura = registros["dataHoraInicio"];
    dataFechamento = registros["dataHoraFim"];
    super.initState();
  }

  void getDataInicio(String? data) => dataAbertura = data!;
  void getDataFim(String? data) => dataFechamento = data!;
  void getHoraInicio(String? hora) => horasAbertura = hora!;
  void getHoraFim(String? hora) => horasFechamento = hora!;

  // funções do select
  void selecionarProjeto(String idProjeto) => projetoID = idProjeto;
  void selecionarCliente(String idCliente) => clienteID = idCliente;
  void selecionarTarefa(String idTarefa) => tarefaID = idTarefa;
  Future? _atualizarAtividade() async {
    print(registros);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(titulo: "Editar Atividade"),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _atualizarAtividade(),
        child: const FaIcon(FontAwesomeIcons.arrowRotateRight),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Projetos:", style: TextStyle(fontSize: 18)),
                  Text("Cliente:", style: TextStyle(fontSize: 18)),
                  Text("Tarefas:", style: TextStyle(fontSize: 18)),
                ],
              ),
              Row(children: [
                Expanded(
                  child: FutureDrop(
                    onChange: selecionarProjeto,
                    tabelaBusca: "projetos",
                    nomeColuna: "projetoNome",
                    selecionado: projetoID,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FutureDrop(
                    onChange: selecionarCliente,
                    tabelaBusca: "clientes",
                    nomeColuna: "clienteNome",
                    selecionado: clienteID,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FutureDrop(
                    onChange: selecionarTarefa,
                    tabelaBusca: "tarefas",
                    nomeColuna: "tarefaNome",
                    selecionado: tarefaID,
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: registroC,
                      autofocus: true,
                      decoration: const InputDecoration(
                        label: Text("Descrição"),
                        hintText: "Descrição",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Informe o registro.";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      controller: valorHoraC,
                      inputFormatters: [
                        // utilizar regexp para permitir apenas números
                        // e até 2 dígitos após casa decimal
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        )
                      ],
                      autofocus: true,
                      decoration: const InputDecoration(
                        label: Text("VALOR HORA"),
                        hintText: "VALOR HORA",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Informe o valor.";
                        }
                        return null;
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const Text("Iniciado: "),
                      Row(
                        children: [
                          PegaData(
                            retorno: getDataInicio,
                            textoBotao: dataAbertura,
                            textoInicialBotao: dataAbertura,
                          ),
                          PegaHora(
                            retorno: getHoraInicio,
                            textoBotao: horasAbertura,
                            textoInicialBotao: horasAbertura,
                            horaAtual: TimeOfDay.fromDateTime(dataInicio),
                          ),
                        ],
                      ),
                      const Text("Concluído: "),
                      Row(
                        children: [
                          PegaData(
                            retorno: getDataFim,
                            textoBotao: dataFechamento,
                            textoInicialBotao: dataFechamento,
                          ),
                          PegaHora(
                            retorno: getHoraInicio,
                            textoBotao: horasFechamento,
                            textoInicialBotao: horasFechamento,
                            horaAtual: TimeOfDay.fromDateTime(dataFinal),
                          ),
                        ],
                      )
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Dados diretamente não editáveis.",
                          style: TextStyle(fontSize: 22),
                        ),
                        Text(
                          "Horas Trabalhadas: ${registros["horas_trabalhadas"]}",
                          style: const TextStyle(fontSize: 20),
                        ),
                        Text(
                          "Valor a receber: R\$ ${registros["valor_receber"]}",
                          style: const TextStyle(fontSize: 20),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}