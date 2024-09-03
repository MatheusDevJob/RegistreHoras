import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void alerteToast(
  BuildContext context,
  String msg, {
  Color corCaixa = const Color.fromRGBO(74, 20, 140, 1),
  Color corTexto = Colors.white,
  ToastGravity posicao = ToastGravity.BOTTOM,
}) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: posicao,
    backgroundColor: corCaixa,
    textColor: corTexto,
  );
}

void alertDialog(
  BuildContext context,
  String msg, {
  Color corCaixa = const Color.fromRGBO(74, 20, 140, 1),
  Color corTexto = Colors.white,
  int duracao = 3,
}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: corCaixa,
    duration: Duration(seconds: duracao),
  ));
}
