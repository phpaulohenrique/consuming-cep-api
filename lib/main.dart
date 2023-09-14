import 'dart:async';
import 'dart:convert';
// import 'dart:js_interop';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Address> fetchAddress(String cep) async {
  final response = await http
      .get(Uri.parse('https://viacep.com.br/ws/${int.parse(cep)}/json/'));

  if (response.statusCode == 200) {
    print(response.statusCode);
    return Address.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Erro ao consultar');
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
      title: 'Consulta endereço por CEP',
      home: MyCustomForm(),
    );
  }
}

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
//     print(inputCepValue.runtimeType);

    setState(() {
      inputCep = inputCepValue;
      print(inputCep.runtimeType);
    });

    if (inputCep == '') {
      return;
    }
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
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 16, 0, 26),
              child: SizedBox(
                height: 50, //height of button
                width: 300, //width of button
      
                child: ElevatedButton(
                  //             style: ElevatedButton.styleFrom(padding: EdgeInsets.all(10)),
                  onPressed: () {
                    handleGetCepData(myController.text);
                  },
                  child: const Text('Consultar CEP'),
                ),
              ),
            ),
            inputCep == ''
                ? const Text('Informe o CEP.', style: TextStyle(fontSize: 16))
                : SizedBox(
                    width: 300.0,
                    height: 200.0,
      //             margin: EdgeInsets.only(top: 24),
                    child: FutureBuilder<Address>(
                      future: futureAddress,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          print(snapshot.toString());
                          return Text('Erro: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          final data = snapshot.data!.getData();
                          print(data);
                          return ListView(
                            children: data.keys.map((key) {
                              return data[key] == ''
                                  ? Text('$key: não informado',
                                      style: TextStyle(fontSize: 16))
                                  : Text('$key: ${data[key]}',
                                      style: TextStyle(fontSize: 16));
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
      ),
    );
  }
}
