import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';  // Importando o pacote Lottie

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de Combustível',
      debugShowCheckedModeBanner: false,  // Removendo o banner de debug
      theme: ThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        primarySwatch: Colors.blue,
      ),
      home: FuelCalculator(
        toggleTheme: _toggleTheme,
        isDarkMode: _isDarkMode,
      ),
    );
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }
}

class FuelCalculator extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  const FuelCalculator({super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  _FuelCalculatorState createState() => _FuelCalculatorState();
}

class _FuelCalculatorState extends State<FuelCalculator> {
  final TextEditingController _alcoolController = TextEditingController();
  final TextEditingController _gasolinaController = TextEditingController();
  String _resultMessage = '';
  late AudioPlayer _audioPlayer;
  late AudioCache _audioCache;
  bool _showFireAnimation = false;  // Variável para controlar se a animação de fogo deve ser exibida

  // Lista de registros de trocas de óleo
  List<Map<String, String>> _oilChangeHistory = [];

  // Controladores para os campos de entrada da troca de óleo
  final TextEditingController _oilChangeDateController = TextEditingController();
  final TextEditingController _oilChangeMileageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer(); // Inicializa o player de áudio
    _audioCache = AudioCache(fixedPlayer: _audioPlayer); // Inicializa o AudioCache
  }

  // Função para calcular a relação entre álcool e gasolina
  void _calculateFuel() {
    final alcool = double.tryParse(_alcoolController.text);
    final gasolina = double.tryParse(_gasolinaController.text);

    if (alcool == null || gasolina == null || alcool <= 0 || gasolina <= 0) {
      setState(() {
        _resultMessage = 'Por favor, insira preços válidos para ambos os combustíveis.';
        _showFireAnimation = false;  // Certifique-se de não mostrar a animação se houver erro
      });
      return;
    }

    double ratio = alcool / gasolina;

    setState(() {
      _resultMessage = ratio < 0.7 ? 'Abasteça com Álcool' : 'Abasteça com Gasolina';
      _showFireAnimation = true;  // Exibe a animação de fogo após o cálculo
    });

    // Tocar o efeito sonoro "sata.mp3" quando calcular
    _audioCache.play('sounds/sata.mp3');  // Usa o AudioCache para tocar o som

    // Exibe a animação de fogo por 5 segundos
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        _showFireAnimation = false;  // Esconde a animação após 5 segundos
      });
    });
  }

  // Função para limpar os campos de entrada e a mensagem de resultado
  void _clearFields() {
    setState(() {
      _alcoolController.clear();
      _gasolinaController.clear();
      _resultMessage = '';
      _showFireAnimation = false;  // Esconde a animação se o usuário limpar
    });
  }

  // Função para abrir a URL do Google Maps
  Future<void> _openUrl() async {
    final url = 'https://precos.petrobras.com.br/sele%C3%A7%C3%A3o-de-estados-gasolina';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possível abrir o link';
    }
  }

  // Função para adicionar uma troca de óleo
  void _addOilChange() {
    final date = _oilChangeDateController.text;
    final mileage = _oilChangeMileageController.text;

    if (date.isNotEmpty && mileage.isNotEmpty) {
      setState(() {
        _oilChangeHistory.add({'Data': date, 'Quilometragem': mileage});
        _oilChangeDateController.clear();
        _oilChangeMileageController.clear();
      });
    }
  }

  // Função para excluir uma troca de óleo
  void _removeOilChange(int index) {
    setState(() {
      _oilChangeHistory.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadora de Combustível', textAlign: TextAlign.center), // Centralizando o título
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () {
              widget.toggleTheme();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: widget.isDarkMode ? 0.4 : 0.1,
              child: Image.asset(
                'assets/icone_posto.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextField(
                      controller: _alcoolController,
                      decoration: InputDecoration(
                        labelText: 'Preço do Álcool (R\$)',
                        labelStyle: TextStyle(color: Colors.red[800]),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red[800]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2), // Borda de foco vermelha
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _gasolinaController,
                      decoration: InputDecoration(
                        labelText: 'Preço da Gasolina (R\$)',
                        labelStyle: TextStyle(color: Colors.red[800]),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red[800]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2), // Borda de foco vermelha
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          onTap: _calculateFuel,
                          splashColor: Colors.red,
                          highlightColor: Colors.red[200],
                          borderRadius: BorderRadius.circular(10),
                          child: Ink(
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red[800]!, width: 2),
                            ),
                            child: Text(
                              'Calcular',
                              style: TextStyle(color: Colors.red[800], fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        InkWell(
                          onTap: _clearFields,
                          splashColor: Colors.red,
                          highlightColor: Colors.red[200],
                          borderRadius: BorderRadius.circular(10),
                          child: Ink(
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red[800]!, width: 2),
                            ),
                            child: Text(
                              'Limpar',
                              style: TextStyle(color: Colors.red[800], fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        InkWell(
                          onTap: _openUrl,
                          splashColor: Colors.red,
                          highlightColor: Colors.red[200],
                          borderRadius: BorderRadius.circular(10),
                          child: Ink(
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red[800]!, width: 2),
                            ),
                            child: Text(
                              'Consulta na Web',
                              style: TextStyle(color: Colors.red[800], fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      _resultMessage,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _resultMessage == 'Abasteça com Álcool' ? Colors.green : Colors.red[800],
                      ),
                    ),
                    if (_showFireAnimation)
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 50.0),
                          child: Lottie.asset(
                            'assets/animations/fire_flame.json',
                            width: 500,
                            height: 500,
                            fit: BoxFit.cover,
                            repeat: false,
                          ),
                        ),
                      ),
                    SizedBox(height: 30),
                    // Título centralizado
                    Text(
                      'Histórico de Trocas de Óleo',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[800]),
                      textAlign: TextAlign.center,  // Centralizando o título
                    ),
                    SizedBox(height: 10),
                    DataTable(
                      columns: [
                        DataColumn(label: Text('Data', style: TextStyle(color: Colors.red[800]))),
                        DataColumn(label: Text('Quilometragem', style: TextStyle(color: Colors.red[800]))),
                        DataColumn(label: Text('Ações', style: TextStyle(color: Colors.red[800]))),
                      ],
                      rows: _oilChangeHistory.map((oilChange) {
                        int index = _oilChangeHistory.indexOf(oilChange);
                        return DataRow(cells: [
                          DataCell(Text(oilChange['Data']!, style: TextStyle(color: Colors.red[800]))),
                          DataCell(Text(oilChange['Quilometragem']!, style: TextStyle(color: Colors.red[800]))),
                          DataCell(
                            MouseRegion(
                              onEnter: (_) {
                                setState(() {
                                  // Mostrar o ícone da lixeira quando o mouse entrar
                                });
                              },
                              onExit: (_) {
                                setState(() {
                                  // Esconder o ícone da lixeira quando o mouse sair
                                });
                              },
                              child: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeOilChange(index),
                              ),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                    SizedBox(height: 10),
                    // Formulário para adicionar uma nova troca de óleo
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _oilChangeDateController,
                            decoration: InputDecoration(
                              labelText: 'Data da Troca',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red, width: 2), // Borda de foco vermelha
                              ),
                            ),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _oilChangeMileageController,
                            decoration: InputDecoration(
                              labelText: 'Quilometragem',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red, width: 2), // Borda de foco vermelha
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 8),
                        InkWell(
                          onTap: _addOilChange,
                          splashColor: Colors.red,
                          highlightColor: Colors.red[200],
                          borderRadius: BorderRadius.circular(10),
                          child: Ink(
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red[800]!, width: 2),
                            ),
                            child: Text(
                              'Adicionar Troca de Óleo',
                              style: TextStyle(color: Colors.red[800], fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
