import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de Combustível',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FuelCalculator(),
    );
  }
}

class FuelCalculator extends StatefulWidget {
  const FuelCalculator({super.key});

  @override
  _FuelCalculatorState createState() => _FuelCalculatorState();
}

class _FuelCalculatorState extends State<FuelCalculator> {
  final TextEditingController _alcoolController = TextEditingController();
  final TextEditingController _gasolinaController = TextEditingController();
  String _resultMessage = '';
  late AudioPlayer _audioPlayer;
  late AudioCache _audioCache;

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
      });
      return;
    }

    double ratio = alcool / gasolina;

    setState(() {
      _resultMessage = ratio < 0.7 ? 'Abasteça com Álcool' : 'Abasteça com Gasolina';
    });

    // Tocar o efeito sonoro "sata.mp3" quando calcular
    _audioCache.play('sounds/sata.mp3');  // Usa o AudioCache para tocar o som
  }

  // Função para limpar os campos de entrada e a mensagem de resultado
  void _clearFields() {
    setState(() {
      _alcoolController.clear();
      _gasolinaController.clear();
      _resultMessage = '';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pergunte ao demonio qual combustivel queimar !'),
        centerTitle: true, // Alinhar título ao centro
      ),
      body: Stack(
        children: [
          // Imagem de fundo com efeito de marca d'água
          Positioned.fill(
            child: Opacity(
              opacity: 0.1, // Opacidade para criar o efeito de marca d'água
              child: Image.asset(
                'assets/icone_posto.png',
                fit: BoxFit.cover, // Preenche toda a tela
              ),
            ),
          ),
          // Container com widgets sobre a imagem
          Center(  // Centralizando o conteúdo
            child: SingleChildScrollView(
              child: Container(
                color: Colors.transparent, // Tornar o fundo transparente
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,  // Centralizando os itens
                  children: <Widget>[
                    SizedBox(height: 8),
                    TextField(
                      controller: _alcoolController,
                      decoration: InputDecoration(
                        labelText: 'Preço do Álcool (R\$)',
                        labelStyle: TextStyle(color: Colors.red[800]), // Cor da label em vermelho sangue
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red[800]!), // Borda em vermelho sangue
                        ),
                        filled: true, // Campos de texto transparentes
                        fillColor: Colors.transparent,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _gasolinaController,
                      decoration: InputDecoration(
                        labelText: 'Preço da Gasolina (R\$)',
                        labelStyle: TextStyle(color: Colors.red[800]), // Cor da label em vermelho sangue
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red[800]!), // Borda em vermelho sangue
                        ),
                        filled: true, // Campos de texto transparentes
                        fillColor: Colors.transparent,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20),
                    // Botões com fundo transparente e texto em vermelho sangue
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,  // Centralizando os botões
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: _calculateFuel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent, // Cor transparente para o botão
                            side: BorderSide(color: Colors.red[800]!), // Borda vermelha sangue
                          ),
                          child: Text(
                            'Calcular',
                            style: TextStyle(color: Colors.red[800]), // Texto em vermelho sangue
                          ),
                        ),
                        SizedBox(width: 16), // Espaçamento entre os botões
                        ElevatedButton(
                          onPressed: _clearFields,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent, // Cor transparente para o botão
                            side: BorderSide(color: Colors.red[800]!), // Borda vermelha sangue
                          ),
                          child: Text(
                            'Limpar',
                            style: TextStyle(color: Colors.red[800]), // Texto em vermelho sangue
                          ),
                        ),
                        SizedBox(width: 16), // Espaçamento entre os botões
                        ElevatedButton(
                          onPressed: _openUrl, // Mantém a funcionalidade de abrir a web
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent, // Cor transparente para o botão
                            side: BorderSide(color: Colors.red[800]!), // Borda vermelha sangue
                          ),
                          child: Text(
                            'Consulta na Web',
                            style: TextStyle(color: Colors.red[800]), // Texto em vermelho sangue
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
                        color: _resultMessage == 'Abasteça com Álcool' ? Colors.green : Colors.red[800], // Cor do texto dependendo do resultado
                      ),
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
