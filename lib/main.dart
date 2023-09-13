import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Address> fetchAddress(int cep) async {
  final response =
      await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));

  if (response.statusCode == 200) {
    return Address.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Erro ao consultar');
  }
}

class Address {
  final int cep;
  final String logradouro;
  final String localidade;
  final String bairro;
  final String uf;
  final int ddd;

  const Address({
    required this.cep,
    required this.logradouro,
    required this.localidade,
    required this.bairro,
    required this.uf,
    required this.ddd,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      cep: json['cep'],
      logradouro: json['logradouro'],
      localidade: json['localidade'],
      bairro: json['bairro'],
      uf: json['uf'],
      ddd: json['ddd'],
    );
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Consulta endereço por CEP',
      home: MyCustomForm(),
    );
  }
}

// Define a custom Form widget.
class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  State<MyCustomForm> createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<MyCustomForm> {
  late Future<Address> futureAddress;
  final myController = TextEditingController();
  int inputCep = 0;

  void handleGetCepData(int inputCepValue) {
    setState(() {
      inputCep = inputCepValue;
    });

    futureAddress = fetchAddress(inputCep);
    // print(futureAddress);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    futureAddress = fetchAddress(inputCep);

//     if (inputCep.toString().length > 1) {}
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta CEP'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: myController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Informe o CEP',
              ),
            ),
          ),
//         inputCep != null ? Text('Cep Informado: $inputCep') : const Text(''),
          ElevatedButton(
            onPressed: () {
              handleGetCepData(int.parse(myController.text));
            },
            child: Text('Consultar CEP'),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<Address>(
              future: futureAddress,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  print(snapshot);
                  return Text('Erro: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final data = snapshot.data as Map<String,
                      dynamic>; // Acesse o mapa de dentro do objeto Address
                  return ListView(
                    children: data.keys.map((key) {
                      return Text('Chave: $key, Valor: ${data[key]}');
                    }).toList(),
                  );
                } else {
                  return Text('Nenhuma informação disponível');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
