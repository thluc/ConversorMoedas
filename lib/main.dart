import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

var request = Uri.parse("https://api.hgbrasil.com/finance");

typedef ValueChanged<T> = void Function(T value);

void main() async {
  runApp(MaterialApp(
    home: const MyWidget(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: const InputDecorationTheme(
        enabledBorder: OutlineInputBorder(borderSide:  BorderSide(color: Colors.white)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        hintStyle: TextStyle(color: Colors.amber))),
  ));
}

class MyWidget extends StatefulWidget{
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  late double dolar;
  late double euro;

  void _realChanged(String texto){
    double real = double.parse(texto);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro ).toStringAsFixed(2);
  }

  void _dolarChanged(String texto){
    double dolar = double.parse(texto);
    realController.text = (dolar * dolar).toStringAsFixed(2);
    euroController.text = (dolar * dolar / euro).toStringAsFixed(2);
  }

    void _euroChanged(String texto){
      double euro = double.parse(texto);
      realController.text = (euro * euro).toStringAsFixed(2);
      dolarController.text = (euro * euro / dolar).toStringAsFixed(2);
    }

    @override
    Widget build(BuildContext context){
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("Conversor de Moedas"),
          backgroundColor: Colors.amber,
          centerTitle: true,
        ),
        body: FutureBuilder<Map>(
          future: pegarDados(),
          builder: (context, snapshot){
            switch (snapshot.connectionState){
              case ConnectionState.none:
              case ConnectionState.waiting:
                return const Center(
                  child: Text(
                    "Carregando Dados...",
                    style: TextStyle(color: Colors.amber, fontSize: 25),
                    textAlign: TextAlign.center,
                  ));
                default:
                if (snapshot.hasError){
                  return const Center(
                    child: Text(
                      "Erro ao carregar dados...",
                      style: TextStyle(color: Colors.amber, fontSize: 25),
                      textAlign: TextAlign.center,
                    ));
                } else {
                  dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(Icons.monetization_on,
                        size: 150, color: Colors.amber),
                        construirTextField("Reais", "R\$", realController, _realChanged),
                        const Divider(),
                        construirTextField("Dolares", "US\$", dolarController, _dolarChanged),
                        const Divider(),
                        construirTextField("Euros", "€", euroController, _euroChanged)
                      ],)
                  );
                }
            }
          },
        )  
      );
    }
}

Widget construirTextField(String texto, String prefixo, TextEditingController c, Function(String) f) {
  return TextField(
    controller: c,
    decoration: InputDecoration(
      labelText: texto,
      labelStyle: const TextStyle(color: Colors.amber),
      border: const OutlineInputBorder(),
      prefixText: prefixo
    ),
    style: const TextStyle(color: Colors.amber, fontSize: 25),
    onChanged: f,
    keyboardType: TextInputType.number,
  );
}

Future<Map> pegarDados() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}
