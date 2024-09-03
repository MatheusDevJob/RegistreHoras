import 'dart:io';

Future<String> getPath() async {
  final String appDataPath = Platform.environment['APPDATA']!;
  final bancoDiretorio = Directory("$appDataPath/banco horas");

  if (!await bancoDiretorio.exists()) {
    await bancoDiretorio.create(recursive: true);
  }

  return bancoDiretorio.path;
}

Future<File> get banco async {
  String caminho = await getPath();
  return File('$caminho/banco_horas.txt');
}

Future<File> registrar(String data, String hora) async {
  final file = await banco;
  String registro = "$data $hora;\n";
  return file.writeAsString(registro, mode: FileMode.append);
}

Future<String> buscar() async {
  try {
    final file = await banco;
    return await file.readAsString();
  } catch (e) {
    return '';
  }
}
