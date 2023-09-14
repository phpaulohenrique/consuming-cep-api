import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Address> fetchAddress(String cep) async {
  int a = int.parse(cep);
  final response =
      await http.get(Uri.parse('https://viacep.com.br/ws/$a/json/'));

  if (response.statusCode == 200) {
    print(response.statusCode);
    return Address.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Erro ao consultar');
  }
}

class Address  {
  final String  cep;
  final String  logradouro;
//   final String localidade;
//   final String bairro;
//   final String uf;
//   final String ddd;

  const Address({
    required this.cep,
    required this.logradouro,
//     required this.localidade,
//     required this.bairro,
//     required this.uf,
//     required this.ddd,
  });

  Map<String, dynamic> getData() {
    return {
      'Cep': cep,
      'Logradouro': logradouro

    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      cep: json['cep'],
      logradouro: json['logradouro']
//       localidade: json['localidade'],
//       bairro: json['bairro'],
//       uf: json['uf'],
//       ddd: json['ddd'],
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
  String inputCep = '78840000';

  void handleGetCepData(String inputCepValue) {
    print(inputCepValue.runtimeType);

    setState(() {
      inputCep = inputCepValue;
      print(inputCep.runtimeType);
    });

    futureAddress = fetchAddress(inputCep);

    // print(futureAddress);
  }

  @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     futureAddress = fetchAddress(inputCep);

// //     if (inputCep.toString().length > 1) {}
//   }
  @override
  void initState() {
    super.initState();
    futureAddress = fetchAddress(inputCep);
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
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: myController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'CEP',
                hintText: '78840000',
              ),
            ),
          ),
//         inputCep != null ? Text('Cep Informado: $inputCep') : const Text(''),
          ElevatedButton(
            onPressed: () {
              handleGetCepData(myController.text);
            },
            child: const Text('Consultar CEP'),
          ),
          SizedBox(
            width: 200.0,
            height: 200.0,
            child: FutureBuilder<Address>(
              future: futureAddress,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  print(snapshot.toString());
                  return Text('Erro: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final  data = snapshot.data!.getData();
                  print(data);
                  return ListView(
                    children: data.keys.map((key) {
                      return data[key] == '' ? Text('$key: não informado') : Text('$key: ${data[key]}');

                    }).toList(),
                  );
                } else {
                  return const Text('Nenhuma informação disponível');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
