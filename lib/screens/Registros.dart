import 'package:flutter/material.dart';
import 'package:matheus/screens/registrarHoras.dart';
import 'package:matheus/services/helper.dart';
import 'package:matheus/widgets/myAppBar.dart';
import 'package:matheus/widgets/myDrawer.dart';

class Registros extends StatefulWidget {
  final Function funcao;
  final String tituloAppBar;
  final String qualRegistro;
  final String label;
  final String hintText;
  const Registros({
    super.key,
    required this.funcao,
    required this.qualRegistro,
    required this.tituloAppBar,
    this.label = "",
    this.hintText = "",
  });

  @override
  State<Registros> createState() => _RegistrosState();
}

class _RegistrosState extends State<Registros> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController registroC = TextEditingController();

  late Function funcao;
  late String nomeTitulo;
  late String qualRegistro;
  late String label;
  late String hintText;
  @override
  void initState() {
    funcao = widget.funcao;
    nomeTitulo = widget.tituloAppBar;
    qualRegistro = widget.qualRegistro;
    label = widget.label;
    hintText = widget.hintText;
    super.initState();
  }

  @override
  void dispose() {
    registroC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(titulo: nomeTitulo),
      drawer: const MyDrawer(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Form(
            key: formKey,
            child: Row(
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
                      borderRadius:
                          const BorderRadius.all(Radius.elliptical(3, 3)),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Icon(Icons.check),
                  ),
                  onTap: () {
                    if (formKey.currentState!.validate()) {
                      funcao(registroC.text).then((value) {
                        if (value) {
                          alertDialog(
                            context,
                            "Registrado",
                            corCaixa: Colors.black,
                            corTexto: Colors.white,
                          );
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegistrarHoras(),
                            ),
                            ModalRoute.withName('/'),
                          );
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
          ),
        ],
      ),
    );
  }
}
