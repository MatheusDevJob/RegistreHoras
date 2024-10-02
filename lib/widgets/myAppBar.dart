import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;
  final Widget? texto;
  const MyAppBar({super.key, required this.titulo, this.texto});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(titulo),
      backgroundColor: Colors.grey[400],
      shape: const Border(bottom: BorderSide(color: Colors.grey)),
      actions: [texto ?? const Text(""), const SizedBox(width: 20)],
    );
  }
}
