import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de IMC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromRGBO(107, 107, 106, 1)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Calculadora de IMC'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int? _iconeSelecionado;
  double _peso = 0;
  double _altura = 0;
  bool _pesoInvalido = true;
  bool _alturaInvalida = true;
  double _imc = 0;
  String _imcCategoria = '';

  Widget iconeSelecionavel(int index, {required String text, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: InkResponse(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: _iconeSelecionado == index ? Colors.blue : null,
            ),
            Text(
              text,
              style: TextStyle(
                color: _iconeSelecionado == index ? Colors.blue : null
              )
            ),
          ],
        ),
        onTap: () => setState(
          () {
            _iconeSelecionado = index;
          },
        ),
      ),
    );
  }

  Widget imcForm() {
    return Form(
      child: Expanded(
        child: Column(
          children: [
            const Text(
              'Informe masculino/feminino, peso e altura',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Spacer(),
                  iconeSelecionavel(0, text: "Masculino", icon: Icons.male),
                  const Spacer(),
                  iconeSelecionavel(1, text: "Feminino", icon: Icons.female),
                  const Spacer(),
                ]
              )
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Spacer(),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Peso (KG)',
                          style: TextStyle(color: _pesoInvalido ? Colors.red : null),
                        ),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            onChanged: (value) => setState(
                              () {
                                var peso = double.tryParse(value);
                                _pesoInvalido = (peso is! double) || peso <= 0;
                                if (!_pesoInvalido) {
                                  _peso = peso!;
                                  calcularImc();
                                }
                              }
                            )
                          )
                        )
                      ]
                    )
                  ),
                  const Spacer(),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Altura (m)',
                          style: TextStyle(color: _alturaInvalida ? Colors.red : null),
                        ),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            onChanged: (value) => setState(
                              () {
                                var altura = double.tryParse(value);
                                _alturaInvalida = (altura is! double) || altura <= 0;
                                if (!_alturaInvalida) {
                                  _altura = altura!;
                                  calcularImc();
                                }
                              }
                            )
                          )
                        )
                      ]
                    )
                  ),
                  const Spacer()
                ]
              )
            )
          ]
        )
      )
    );
  }

  Widget imcResult() {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Seu IMC'),
          Text(_pesoInvalido || _alturaInvalida ? "INVÁLIDO" : _imc.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(_pesoInvalido || _alturaInvalida ? "Preencha peso e altura corretamente nos campos acima" : _imcCategoria)
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            imcForm(),
            imcResult()
          ]
        )
      )
    );
  }

  void calcularImc() {
    _imc = _peso / (_altura * _altura);
    _imcCategoria = switch (_imc) {
      < 18.5 => 'Abaixo do peso',
      >= 18.5 && < 24.9 => 'Peso normal',
      >= 24.9 && < 29.9 => 'Sobrepeso',
      >= 29.9 => 'Obesidade',
      _ => 'ERRO'
    };
  }
}
