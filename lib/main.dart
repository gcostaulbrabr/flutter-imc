import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  // Necessário para o parsing dos valores numéricos no form
  Intl.defaultLocale = 'pt-BR';
  runApp(const ImcApp());
}

class ImcApp extends StatelessWidget {
  const ImcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de IMC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromRGBO(107, 107, 106, 1)),
        useMaterial3: true,
      ),
      home: const ImcHomePage(title: 'Calculadora de IMC'),
    );
  }
}

class ImcHomePage extends StatefulWidget {
  const ImcHomePage({super.key, required this.title});

  final String title;

  @override
  State<ImcHomePage> createState() => _ImcHomePageState();
}

class _ImcHomePageState extends State<ImcHomePage> {
  int? _iconeSelecionado;
  double _peso = 0;
  double _altura = 0;
  bool _pesoInvalido = true;
  bool _alturaInvalida = true;
  double _imc = 0;
  String _imcCategoria = '';
  late NumberFormat numberFormat;

  _ImcHomePageState() {
    numberFormat = NumberFormat();
  }

  // Calcula o IMC, de acordo com as regras estabelecidas no modelo do exercício
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

  double? stringToPositiveDouble(String value) {
    // Não aceita string contendo ponto, porque quebra o parsing do NumberFormat em pt-BR
    // quando usado com numérico no formato en-US (ex.: peso=81.23Kg ou altura=1.75m)
    // Nesses casos o NumberFormat.tryParse() abaixo retorna um número absurdo, em vez de 
    // falhar retornando nulo como esperado. TODO: investigar motivo
    if (value.contains('.')) {
      return null;
    }
      
    var n = numberFormat.tryParse(value) as double?;
    if (n is! double || n <= 0) {
      return null;
    }
    
    return n;
  }

  // Usado nos ícones de masculino/feminino do form
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

  // Form do IMC, com seleção de masculino/feminino e preenchimento de peso e altura
  // O cálculo do IMC ocorre automaticamente, de acordo com o preenchimento do form
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
                                var peso = stringToPositiveDouble(value);
                                _pesoInvalido = (peso is! double);
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
                                var altura = numberFormat.tryParse(value) as double?;
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

  // Exibe o resultado do cálculo do IMC, com o índice e a sua categoria
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
}
