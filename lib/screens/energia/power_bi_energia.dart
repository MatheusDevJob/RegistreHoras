import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matheus/widgets/PegaDataRange.dart';
import 'package:matheus/widgets/myAppBar.dart';

class PowerBiEnergia extends StatefulWidget {
  const PowerBiEnergia({super.key});

  @override
  State<PowerBiEnergia> createState() => _PowerBiEnergiaState();
}

class _PowerBiEnergiaState extends State<PowerBiEnergia> {
  final List<Map<String, dynamic>> data = [
    {
      "id": 1,
      "data_referencia": "2025-01",
      "kwh_consumidos": 50.0,
      "preco_por_kwh": 0.35,
      "consumo_tusd": 25.0,
      "consumo_te": 25.0,
      "bandeira_tarifaria": "Verde",
      "encargos_adicionais": 2.0,
      "pis_cofins": 1.5,
      "icms": 1.0,
      "custo_total": 20.0
    },
    {
      "id": 2,
      "data_referencia": "2025-02",
      "kwh_consumidos": 300.0,
      "preco_por_kwh": 0.60,
      "consumo_tusd": 150.0,
      "consumo_te": 150.0,
      "bandeira_tarifaria": "Vermelha",
      "encargos_adicionais": 30.0,
      "pis_cofins": 10.0,
      "icms": 15.0,
      "custo_total": 225.0
    },
    {
      "id": 3,
      "data_referencia": "2025-03",
      "kwh_consumidos": 120.0,
      "preco_por_kwh": 0.45,
      "consumo_tusd": 60.0,
      "consumo_te": 60.0,
      "bandeira_tarifaria": "Amarela",
      "encargos_adicionais": 10.0,
      "pis_cofins": 5.0,
      "icms": 3.0,
      "custo_total": 70.0
    },
    {
      "id": 4,
      "data_referencia": "2025-04",
      "kwh_consumidos": 600.0,
      "preco_por_kwh": 0.75,
      "consumo_tusd": 300.0,
      "consumo_te": 300.0,
      "bandeira_tarifaria": "Vermelha",
      "encargos_adicionais": 50.0,
      "pis_cofins": 25.0,
      "icms": 30.0,
      "custo_total": 475.0
    },
    {
      "id": 5,
      "data_referencia": "2025-05",
      "kwh_consumidos": 80.0,
      "preco_por_kwh": 0.38,
      "consumo_tusd": 40.0,
      "consumo_te": 40.0,
      "bandeira_tarifaria": "Verde",
      "encargos_adicionais": 5.0,
      "pis_cofins": 2.0,
      "icms": 1.5,
      "custo_total": 35.0
    },
    {
      "id": 6,
      "data_referencia": "2025-06",
      "kwh_consumidos": 400.0,
      "preco_por_kwh": 0.65,
      "consumo_tusd": 200.0,
      "consumo_te": 200.0,
      "bandeira_tarifaria": "Amarela",
      "encargos_adicionais": 20.0,
      "pis_cofins": 15.0,
      "icms": 10.0,
      "custo_total": 290.0
    },
    {
      "id": 7,
      "data_referencia": "2025-07",
      "kwh_consumidos": 30.0,
      "preco_por_kwh": 0.32,
      "consumo_tusd": 15.0,
      "consumo_te": 15.0,
      "bandeira_tarifaria": "Verde",
      "encargos_adicionais": 1.0,
      "pis_cofins": 0.8,
      "icms": 0.5,
      "custo_total": 12.0
    },
    {
      "id": 8,
      "data_referencia": "2025-08",
      "kwh_consumidos": 500.0,
      "preco_por_kwh": 0.70,
      "consumo_tusd": 250.0,
      "consumo_te": 250.0,
      "bandeira_tarifaria": "Vermelha",
      "encargos_adicionais": 40.0,
      "pis_cofins": 20.0,
      "icms": 25.0,
      "custo_total": 385.0
    },
    {
      "id": 9,
      "data_referencia": "2025-09",
      "kwh_consumidos": 90.0,
      "preco_por_kwh": 0.40,
      "consumo_tusd": 45.0,
      "consumo_te": 45.0,
      "bandeira_tarifaria": "Amarela",
      "encargos_adicionais": 8.0,
      "pis_cofins": 3.0,
      "icms": 2.5,
      "custo_total": 42.0
    },
    {
      "id": 10,
      "data_referencia": "2025-10",
      "kwh_consumidos": 700.0,
      "preco_por_kwh": 0.80,
      "consumo_tusd": 350.0,
      "consumo_te": 350.0,
      "bandeira_tarifaria": "Vermelha",
      "encargos_adicionais": 60.0,
      "pis_cofins": 30.0,
      "icms": 40.0,
      "custo_total": 560.0
    },
    {
      "id": 11,
      "data_referencia": "2025-11",
      "kwh_consumidos": 60.0,
      "preco_por_kwh": 0.36,
      "consumo_tusd": 30.0,
      "consumo_te": 30.0,
      "bandeira_tarifaria": "Verde",
      "encargos_adicionais": 3.0,
      "pis_cofins": 1.2,
      "icms": 1.0,
      "custo_total": 25.0
    },
    {
      "id": 12,
      "data_referencia": "2025-12",
      "kwh_consumidos": 800.0,
      "preco_por_kwh": 0.85,
      "consumo_tusd": 400.0,
      "consumo_te": 400.0,
      "bandeira_tarifaria": "Vermelha",
      "encargos_adicionais": 70.0,
      "pis_cofins": 35.0,
      "icms": 50.0,
      "custo_total": 650.0
    },
  ];
  String clickedDataInfo = "";
  String filtroData = "";

  @override
  Widget build(BuildContext context) {
    void eventoToque(FlTouchEvent event, response) {
      if (event.runtimeType == FlPanDownEvent) {
        if (response != null && response.lineBarSpots != null) {
          final touchedIndex = response.lineBarSpots!.first.x.toInt();
          final touchedData = data[touchedIndex - 1];
          setState(() {
            clickedDataInfo =
                "Mês: ${touchedData['data_referencia']}, Consumo: ${touchedData['kwh_consumidos']} kWh";
          });

          print(touchedData);
        }
      }
    }

    return Scaffold(
      appBar: const MyAppBar(titulo: "Power BI Energia"),
      body: Column(
        children: [
          Row(
            children: [
              Text(filtroData),
              PegaDataRange(
                body: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Filtro Data"),
                ),
                funcao: (start, end) {
                  String inicio = DateFormat("MM/yyyy").format(start);
                  String finau = DateFormat("MM/yyyy").format(end);
                  setState(() => filtroData = "De $inicio até $finau");
                  print(start);
                  print(end);
                },
              )
            ],
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  minX: 1,
                  maxX: data.length.toDouble(),
                  minY: 0,
                  maxY: data.isEmpty
                      ? 0
                      : data
                          .map((d) => d['kwh_consumidos'])
                          .reduce((ant, rec) => ant > rec ? ant : rec)
                          .toDouble(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((entry) {
                        int index = entry.key + 1;
                        double value = entry.value['kwh_consumidos'].toDouble();
                        return FlSpot(index.toDouble(), value);
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: data.asMap().entries.map((entry) {
                        int index = entry.key + 1;
                        double value = entry.value['custo_total'].toDouble();
                        return FlSpot(index.toDouble(), value);
                      }).toList(),
                      isCurved: true,
                      color: const Color.fromARGB(255, 201, 33, 243),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchCallback: eventoToque,
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(
                      axisNameWidget: Text("Consumo"),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt() - 1;

                          String mes = data[index]["data_referencia"];
                          return Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(mes),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
