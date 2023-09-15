import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Address> fetchAddress(String cep) async {
  final response = await http
      .get(Uri.parse('https://viacep.com.br/ws/${int.parse(cep)}/json/'));

  if (response.statusCode == 200) {
    return Address.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Ops, ocorreu um erro ao consultar');
  }
}

class Address {
  final String cep;
  final String logradouro;
  final String localidade;
  final String bairro;
  final String uf;
  final String ddd;

  const Address({
    required this.cep,
    required this.logradouro,
    required this.localidade,
    required this.bairro,
    required this.uf,
    required this.ddd,
  });

  Map<String, dynamic> getData() {
    return {
      'Cep': cep,
      'Cidade': localidade,
      'UF do Estado': uf,
      'Logradouro': logradouro,
      'Bairro': bairro,
      'DDD': ddd,
    };
  }

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
      title: 'Consultar endereço pelo CEP',
      debugShowCheckedModeBanner: false,
      home: FormCep(),
    );
  }
}

class FormCep extends StatefulWidget {
  const FormCep({super.key});

  @override
  State<FormCep> createState() => _FormCepState();
}

class _FormCepState extends State<FormCep> {
  late Future<Address> futureAddress;
  final inputCepController = TextEditingController();
  String inputCep = '';

  void handleGetCepData(String inputCepValue) {
    setState(() {
      inputCep = inputCepValue;
    });

    if (inputCep == '') {
      return;
    } else {
      futureAddress = fetchAddress(inputCep);
    }
  }

  @override
  void initState() {
    super.initState();
    futureAddress = fetchAddress(inputCep);
  }

  @override
  void dispose() {
    inputCepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta CEP'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(40, 80, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: TextField(
                  controller: inputCepController,
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
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 16, 0, 26),
              child: SizedBox(
                height: 50,
                width: 300,
                child: ElevatedButton(
                  onPressed: () {
                    handleGetCepData(inputCepController.text);
                  },
                  child: const Text('Consultar CEP',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
            inputCep.isEmpty
                ? const Text('Informe o CEP', style: TextStyle(fontSize: 16))
                : inputCep.length >= 1 && inputCep.length != 8
                    ? const Text('CEP Inválido',
                        style: TextStyle(fontSize: 16, color: Colors.red))
                    : SizedBox(
                        width: 300.0,
                        height: 200.0,
                        child: FutureBuilder<Address>(
                          future: futureAddress,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text(
                                  'Ocorreu um erro, verifique se o CEP informado está correto. Erro: ${snapshot.error}');
                            } else if (snapshot.hasData) {
                              final data = snapshot.data!.getData();

                              return ListView(
                                children: data.keys.map((key) {
                                  return data[key] == ''
                                      ? Text('$key: não informado',
                                          style: const TextStyle(fontSize: 16))
                                      : Text('$key: ${data[key]}',
                                          style: const TextStyle(fontSize: 16));
                                }).toList(),
                              );
                            } else {
                              return const Text(
                                  'Nenhuma informação disponível');
                            }
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
