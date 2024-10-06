import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:matheus/services/banco.dart';
import 'package:matheus/services/helper.dart';
import 'package:matheus/services/reformatarDados.dart';
import 'package:matheus/widgets/FutureDrop.dart';
import 'package:matheus/widgets/PegarData.dart';
import 'package:matheus/widgets/PegarHora.dart';
import 'package:matheus/widgets/myAppBar.dart';
import 'package:matheus/widgets/myDrawer.dart';

class RegistrarHoras extends StatefulWidget {
  final bool atividadeAberta;
  final Map<String, dynamic>? mapaAtividade;
  const RegistrarHoras({
    super.key,
    this.atividadeAberta = false,
    this.mapaAtividade,
  });

  @override
  State<RegistrarHoras> createState() => _RegistrarHorasState();
}

class _RegistrarHorasState extends State<RegistrarHoras> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController registroC = TextEditingController();
  final TextEditingController valorHoraC = TextEditingController();

  DateTime data = DateTime.now();
  late String dataString;
  late String horasHoje;
  List<String> listaHoras = [];
  Map<String, List> mapaDatas = {};
  String aberturaString = "";
  String fechamentoString = "";
  int abertura = 0;
  int fechamento = 0;
  String? projetoID;
  String? clienteID;
  String? tarefaID;

  late bool atividadeAberta;
  late Map<String, dynamic>? mapaAtividade;
  @override
  void initState() {
    DateTime data = DateTime.now();
    horasHoje = DateFormat("HH:mm:ss").format(data);
    dataString = DateFormat("yyyy-MM-dd").format(data);
    atividadeAberta = widget.atividadeAberta;
    mapaAtividade = widget.mapaAtividade;
    if (atividadeAberta) {
      registroC.text = mapaAtividade!["descricao_tarefa"];
      valorHoraC.text = mapaAtividade!["valor_hora"].toString();
    }
    super.initState();
  }

  @override
  void dispose() {
    registroC.dispose();
    valorHoraC.dispose();
    super.dispose();
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
    void tratarResposta(int resposta, List registros) {
      bool atividadeAberta = registros.isNotEmpty ? true : false;
      if (resposta == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RegistrarHoras(
              atividadeAberta: atividadeAberta,
              mapaAtividade: registros.isNotEmpty ? registros[0] : null,
            ),
          ),
        );
      } else {
        alertDialog(context, "Houve um erro ao registrar a atividade");
      }
    }

    void registrarHora() async {
      int resposta = await registrarAtividade(
        projetoID!,
        clienteID!,
        tarefaID!,
        "$dataString $horasHoje",
        registroC.text,
        valorHoraC.text,
      );
      List registros = await getAtividadeAberta();
      tratarResposta(resposta, registros);
    }

    void pegarData(DateTime date) =>
        dataString = DateFormat('yyyy-MM-dd').format(date);
    void pegarHora(TimeOfDay hora) => horasHoje = "${hora.format(context)}:00";

    void selecionarProjeto(String idProjeto) => projetoID = idProjeto;
    void selecionarCliente(String idCliente) => clienteID = idCliente;
    void selecionarTarefa(String idTarefa) => tarefaID = idTarefa;
    void atualizarAtividadeLocal() async {
      String horaI = mapaAtividade!["data_hora_inicio"] + ":00";
      String horaF = "$dataString $horasHoje";
      Map<String, dynamic> calculo = calcularHorasEValor(
        horaI,
        horaF,
        mapaAtividade!["valor_hora"],
      );
      if (!calculo["status"]) {
        alertDialog(context, calculo["msg"], duracao: 30);
        return;
      }

      int resposta = await atualizarAtividade(
        mapaAtividade!["id"],
        horaF,
        calculo["horasTrabalhadas"],
        calculo["valorReceber"],
        registroC.text,
      );

      List registros = await getAtividadeAberta();
      tratarResposta(resposta, registros);
    }

    return Scaffold(
      appBar: const MyAppBar(titulo: "REGISTRAR ATIVIDADE"),
      drawer: const MyDrawer(),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          if (atividadeAberta) {
            atualizarAtividadeLocal();
          } else if (formKey.currentState!.validate()) {
            registrarHora();
          }
        },
        child: atividadeAberta
            ? const Text("ATUALIZAR ATIVIDADE")
            : const Text("REGISTRAR ATIVIDADE"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("Cliente:", style: TextStyle(fontSize: 18)),
                    Text("Projetos:", style: TextStyle(fontSize: 18)),
                    Text("Tarefas:", style: TextStyle(fontSize: 18)),
                  ],
                ),
                if (atividadeAberta) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 0.5),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 11.0),
                          child: Text(
                            mapaAtividade!["projetoNome"],
                            style: const TextStyle(fontSize: 16.0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 0.5),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 11.0),
                          child: Text(
                            mapaAtividade!["clienteNome"],
                            style: const TextStyle(fontSize: 16.0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 0.5),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 11.0),
                          child: Text(
                            mapaAtividade!["tarefaNome"],
                            style: const TextStyle(fontSize: 16.0),
                          ),
                        ),
                      ),
                    ],
                  )
                ] else
                  Row(children: [
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
                        readOnly: atividadeAberta,
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
                SizedBox(
                  height: 400,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PegarData(
                        retornarValor: pegarData,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1800),
                        lastDate: DateTime(3000),
                      ),
                      PegarHora(
                        retornarTime: pegarHora,
                        initialTime: TimeOfDay.now(),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ConjuntoFutureDrop extends StatefulWidget {
  final Function funcCliente;
  final Function funcProjeto;
  const ConjuntoFutureDrop({
    super.key,
    required this.funcCliente,
    required this.funcProjeto,
  });

  @override
  State<ConjuntoFutureDrop> createState() => _ConjuntoFutureDropState();
}

class _ConjuntoFutureDropState extends State<ConjuntoFutureDrop> {
  String? projetoID;
  String? clienteID;
  String? selecionado;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FutureBuilder(
            future: getDadosTabela("clientes"),
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

              data.add({'id': null, "clienteNome": "Cliente"});
              for (var valor in antigaData) {
                data.add(valor);
              }
              return DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                hint: const Text("Cliente"),
                value: clienteID,
                onChanged: (newValue) {
                  setState(() {
                    clienteID = newValue.toString();
                    selecionado = null;
                    widget.funcCliente(newValue);
                  });
                },
                validator: (value) {
                  if (value == null || value == "null" || value.isEmpty) {
                    return "Informe o registro.";
                  }
                  return null;
                },
                items: data
                    .map<DropdownMenuItem<String>>((Map<String, dynamic> item) {
                  return DropdownMenuItem<String>(
                    value: item['id'].toString(),
                    child: Text(item["clienteNome"]),
                  );
                }).toList(),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FutureBuilder(
            future:
                get("projetos", argumento: [clienteID], onde: "clienteID = ?"),
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

              data.add({'id': null, "projetoNome": "Projeto"});
              for (var valor in antigaData) {
                data.add(valor);
              }
              return DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                hint: const Text("Projeto"),
                value: selecionado,
                onChanged: (newValue) {
                  setState(() {
                    selecionado = newValue.toString();
                    widget.funcProjeto(newValue);
                  });
                },
                validator: (value) {
                  if (value == null || value == "null" || value.isEmpty) {
                    return "Informe o registro.";
                  }
                  return null;
                },
                items: data
                    .map<DropdownMenuItem<String>>((Map<String, dynamic> item) {
                  return DropdownMenuItem<String>(
                    value: item['id'].toString(),
                    child: Text(item["projetoNome"]),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
