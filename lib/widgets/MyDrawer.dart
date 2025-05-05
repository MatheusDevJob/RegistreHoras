import 'package:flutter/material.dart';
import 'package:matheus/screens/Home.dart';
import 'package:matheus/screens/Registros.dart';
import 'package:matheus/screens/energia/modulo_energia.dart';
import 'package:matheus/screens/financeiro/modulo_financeiro.dart';
import 'package:matheus/screens/registrarHoras.dart';
import 'package:matheus/services/banco.dart';
import 'package:matheus/services/financeiro.dart';
import 'package:matheus/services/helper.dart';
import 'package:process_run/process_run.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    void navegarRegistro(List registro) {
      bool atividadeAberta = registro.isNotEmpty ? true : false;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => RegistrarHoras(
            atividadeAberta: atividadeAberta,
            mapaAtividade: registro.isNotEmpty ? registro[0] : null,
          ),
        ),
        ModalRoute.withName('/'),
      );
    }

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
              MaterialPageRoute(builder: (context) => const Home()),
              ModalRoute.withName('/'),
            ),
          ),
          ListTile(
            title: const Text("Registrar Atividade"),
            onTap: () async => navegarRegistro(await getAtividadeAberta()),
          ),
          ListTile(
            title: const Text("Abrir pasta DB"),
            onTap: () async {
              try {
                String caminho = await databaseFactoryFfi.getDatabasesPath();
                await runExecutableArguments('explorer', [caminho]);
              } catch (e) {
                alertDialog(
                  // ignore: use_build_context_synchronously
                  context,
                  "Erro ao abrir pasta: $e",
                  duracao: 5,
                  corCaixa: Colors.white,
                );
              }
            },
          ),
          ListTile(
            title: const Text("Cadastrar Projeto"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Registros(
                  funcaoDeletar: update,
                  qualRegistro: "Projeto",
                  tituloAppBar: "Registro de Projeto",
                  funcao: registrarProjeto,
                  hintText: "Informe o Nome do Projeto",
                  label: "Nome Projeto",
                  funcaoAtualizar: atualizarProjeto,
                  nomesColuna: ["projetoNome"],
                  tabelaBusca: "projetos",
                  addCliente: true,
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
                  funcaoDeletar: update,
                  qualRegistro: "Cliente",
                  tituloAppBar: "Registro de Cliente",
                  funcao: registrarCliente,
                  hintText: "Informe o Nome do Cliente",
                  label: "Nome Cliente",
                  funcaoAtualizar: atualizarCliente,
                  nomesColuna: ["clienteNome"],
                  tabelaBusca: "clientes",
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
                  funcaoDeletar: update,
                  qualRegistro: "Tarefa",
                  tituloAppBar: "Registro de Tarefa",
                  funcao: registrarTarefa,
                  hintText: "Informe o Nome do Tarefa",
                  label: "Nome Tarefa",
                  funcaoAtualizar: atualizarTarefa,
                  nomesColuna: ["tarefaNome"],
                  tabelaBusca: "tarefas",
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text("Módulo Energia"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ModuloEnergia()),
            ),
          ),
          ListTile(
            title: const Text("Módulo Financeiro"),
            onTap: () async {
              Map priDados = await Financeiro().getDadosFinancas();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ModuloFinanceiro(priDados: priDados),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
