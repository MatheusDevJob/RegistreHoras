import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:matheus/screens/financeiro/registrar_gastos.dart';
import 'package:matheus/widgets/MyDrawer.dart';
import 'package:matheus/widgets/myAppBar.dart';

class ModuloFinanceiro extends StatefulWidget {
  final Map priDados;
  const ModuloFinanceiro({super.key, required this.priDados});

  @override
  State<ModuloFinanceiro> createState() => _ModuloFinanceiroState();
}

class _ModuloFinanceiroState extends State<ModuloFinanceiro> {
  late Map priDados;

  @override
  void initState() {
    priDados = widget.priDados;
    print(priDados);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(titulo: "Módulo de Financeiro"),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegistrarGastos(),
                  ),
                ),
                child: const Text("Registrar Gastos"),
              )
            ],
          ),
          Flexible(
            child: LineChart(
              LineChartData(
                  minX: 0,
                  minY: 0,
                  maxY: 20,
                  maxX: 20,
                  lineBarsData: [
                    if (priDados["gastos"].isNotEmpty)
                      LineChartBarData(
                        spots: priDados["gastos"].asMap().entries.map((entry) {
                          int index = entry.key + 1;
                        }),
                      )
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}
