import 'package:flutter/material.dart';
import 'package:matheus/widgets/MyDrawer.dart';
import 'package:matheus/widgets/myAppBar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MyAppBar(titulo: "Home"),
      drawer: MyDrawer(),
    );
  }
}
