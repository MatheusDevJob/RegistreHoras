import 'package:flutter/material.dart';
import 'package:matheus/screens/Registros.dart';
import 'package:matheus/screens/registrarHoras.dart';
import 'package:matheus/services/banco.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0.0),
          bottomRight: Radius.circular(0.0),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text("Home"),
            onTap: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const RegistrarHoras()),
              ModalRoute.withName('/'),
            ),
          ),
          ListTile(
            title: const Text("Cadastrar Projeto"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Registros(
                  qualRegistro: "Projeto",
                  tituloAppBar: "Registro de Projeto",
                  funcao: registrarProjeto,
                  hintText: "Informe o Nome do Projeto",
                  label: "Nome Projeto",
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text("Cadastrar Cliente"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Registros(
                  qualRegistro: "Cliente",
                  tituloAppBar: "Registro de Cliente",
                  funcao: registrarCliente,
                  hintText: "Informe o Nome do Cliente",
                  label: "Nome Cliente",
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text("Cadastrar Tarefa"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Registros(
                  qualRegistro: "Tarefa",
                  tituloAppBar: "Registro de Tarefa",
                  funcao: registrarTarefa,
                  hintText: "Informe o Nome do Tarefa",
                  label: "Nome Tarefa",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}