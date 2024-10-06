import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:matheus/services/banco.dart';
import 'package:matheus/services/helper.dart';
import 'package:matheus/widgets/FutureDrop.dart';
import 'package:matheus/widgets/myAppBar.dart';
import 'package:matheus/widgets/myDrawer.dart';

class Registros extends StatefulWidget {
  final Function funcao;
  final String tituloAppBar;
  final String qualRegistro;
  final String label;
  final String hintText;

  final Function funcaoAtualizar;
  final List<String>? nomesColuna;
  final String tabelaBusca;
  final bool addCliente;
  const Registros({
    super.key,
    required this.funcao,
    required this.qualRegistro,
    required this.tituloAppBar,
    this.label = "",
    this.hintText = "",
    this.addCliente = false,
    required this.funcaoAtualizar,
    required this.nomesColuna,
    required this.tabelaBusca,
  });

  @override
  State<Registros> createState() => _RegistrosState();
}

class _RegistrosState extends State<Registros> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> formEditKey = GlobalKey<FormState>();
  final TextEditingController registroC = TextEditingController();
  final TextEditingController editeC = TextEditingController();

  late Function funcao;
  late String nomeTitulo;
  late String qualRegistro;
  late String label;
  late String hintText;

  late Function funcaoAtualizar;
  late List<String>? nomesColuna;
  late String tabelaBusca;
  late bool addCliente;

  String? clienteID;
  @override
  void initState() {
    funcao = widget.funcao;
    nomeTitulo = widget.tituloAppBar;
    qualRegistro = widget.qualRegistro;
    label = widget.label;
    hintText = widget.hintText;
    funcaoAtualizar = widget.funcaoAtualizar;
    nomesColuna = widget.nomesColuna;
    tabelaBusca = widget.tabelaBusca;
    addCliente = widget.addCliente;
    super.initState();
  }

  @override
  void dispose() {
    registroC.dispose();
    editeC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void abrirConfirmacao(Map<String, dynamic> item) {
      editeC.text = item[nomesColuna![0]];
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
                  "Confirmação",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Você tem certeza que deseja realizar esta ação?",
                ),
                Form(
                  key: formEditKey,
                  child: TextFormField(
                    controller: editeC,
                    decoration: InputDecoration(
                      label: Text(label),
                      hintText: hintText,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Informe o registro.";
                      }
                      return null;
                    },
                  ),
                ),
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
                        if (!formEditKey.currentState!.validate()) return;
                        funcaoAtualizar(item["id"].toString(), editeC.text)
                            .then((bool bul) {
                          if (bul) setState(() {});
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

    void selecionarCliente(String idCliente) => clienteID = idCliente;

    return Scaffold(
      appBar: MyAppBar(titulo: nomeTitulo),
      drawer: const MyDrawer(),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // TABELA PARA LISTAR E ATUALZIAR REGISTRO
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: FutureBuilder(
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
                  return DataTable(
                    border: TableBorder.all(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey,
                    ),
                    columns: const [
                      DataColumn(label: Text('Nome')),
                      DataColumn(label: Text('Ação')),
                    ],
                    rows: data.map<DataRow>((Map<String, dynamic> item) {
                      return DataRow(cells: [
                        DataCell(Text(item[nomesColuna![0]])),
                        DataCell(
                          FaIcon(
                            FontAwesomeIcons.pen,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onTap: () => abrirConfirmacao(item),
                        ),
                      ]);
                    }).toList(),
                  );
                },
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (addCliente)
                      Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        width: 552,
                        child: FutureDrop(
                          onChange: selecionarCliente,
                          tabelaBusca: "clientes",
                          nomeColuna: "clienteNome",
                          hintText: "Cliente",
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 500,
                          // height: 60,
                          child: TextFormField(
                            controller: registroC,
                            autofocus: true,
                            decoration: InputDecoration(
                              label: Text(label),
                              hintText: hintText,
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Informe o registro.";
                              }
                              return null;
                            },
                          ),
                        ),
                        InkWell(
                          child: Container(
                            margin: const EdgeInsets.only(left: 5),
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                  Radius.elliptical(3, 3)),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: const Icon(Icons.check),
                          ),
                          onTap: () {
                            if (formKey.currentState!.validate()) {
                              funcao(registroC.text, clienteID).then((value) {
                                if (value) {
                                  alertDialog(
                                    context,
                                    "Registrado",
                                    corCaixa: Colors.black,
                                    corTexto: Colors.white,
                                  );
                                  registroC.text = '';
                                  setState(() {});
                                } else {
                                  alertDialog(
                                    context,
                                    "Não foi registrado",
                                    corCaixa: Colors.red,
                                    corTexto: Colors.white,
                                  );
                                }
                              });
                            }
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
