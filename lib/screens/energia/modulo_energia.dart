import 'package:flutter/material.dart';
import 'package:matheus/screens/energia/power_bi_energia.dart';
import 'package:matheus/widgets/MyDrawer.dart';
import 'package:matheus/widgets/myAppBar.dart';

class ModuloEnergia extends StatelessWidget {
  const ModuloEnergia({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(titulo: "Módulo de Energia"),
      drawer: const MyDrawer(),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PowerBiEnergia(),
                  )),
              child: const Text("Power BI"),
            ),
            botaoModulo(
              () {},
              const Text(
                "Subir Relatório",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget botaoModulo(Function acao, Widget body) {
  return GestureDetector(
    onTap: () => acao,
    child: Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: body),
    ),
  );
}
