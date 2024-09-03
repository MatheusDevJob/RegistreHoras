import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;
  const MyAppBar({super.key, required this.titulo});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(titulo),
      backgroundColor: Colors.grey[400],
      shape: const Border(bottom: BorderSide(color: Colors.grey)),
    );
  }
}
