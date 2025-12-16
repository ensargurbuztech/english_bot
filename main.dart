import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const EnglishBotApp());
}

class EnglishBotApp extends StatelessWidget {
  const EnglishBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'English Bot',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFEFF3F6),
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  // --- ARAÇLAR ---
  late stt.SpeechToText _speech;
  final FlutterTts flutterTts = FlutterTts(); 
  late AnimationController _rippleController;
  
  // --- DURUM DEĞİŞKENLERİ ---
  bool _isListening = false;
  bool _isAutoModeActive = false;
  String _lastWords = "";
  String _statusText = "Sohbeti başlatmak için butona bas 👇";
  
  // --- SORU HAVUZU (GÜNCELLENMİŞ) ---
  final Map<String, List<String>> questionPool = {
    // A1 SEVİYESİ (25 Soru)
    "A1": [
      "What is your name?",
      "Where are you from?",
      "Do you have a big family?",
      "What is your favorite color?",
      "Can you swim?",
      "Do you like music?",
      "What time do you wake up?",
      "What is your job?",
      "Do you have any pets?",
      "What is your favorite food?",
      "How old are you?",
      "What is your mother's name?",
      "Do you live in a house or an apartment?",
      "How many brothers or sisters do you have?",
      "What is your favorite season?",
      "Can you cook?",
      "What do you do on weekends?",
      "What's the weather like today?",
      "Do you speak any other languages?",
      "What is your favorite animal?",
      "Where do you study?",
      "What do you usually have for breakfast?",
      "Do you like to watch TV?",
      "What is your favorite drink?",
      "Do you like to go shopping?"
    ],
    // A2 SEVİYESİ (20 Soru)
    "A2": [
      "What did you do yesterday evening?",
      "Describe your best friend.",
      "What is your favorite memory from childhood?",
      "How often do you use your phone?",
      "What are your plans for the next holiday?",
      "Do you prefer reading books or watching movies?",
      "What kind of sports do you like?",
      "Where did you go on your last vacation?",
      "What is the most beautiful place you have ever visited?",
      "What do you usually wear to work or school?",
      "How do you travel to work or school?",
      "What is the biggest difference between a city and the countryside?",
      "Do you enjoy learning new things?",
      "What is the best way to relax after a long day?",
      "If you could have any superpower, what would it be?",
      "What kind of music is popular in your country?",
      "Do you prefer sunny or rainy days?",
      "What are the benefits of eating healthy food?",
      "What time do you usually go to bed?",
      "Tell me about a time you were late."
    ],
    // B1 SEVİYESİ (24 Soru)
    "B1": [
      "Describe your daily routine.",
      "What is the best movie you have ever seen?",
      "Why do you want to learn English?",
      "What would you do if you won the lottery?",
      "How has technology changed your life?",
      "What is the most challenging thing about your job?",
      "If you could travel anywhere, where would you go?",
      "What qualities make a good leader?",
      "Do you think it's important to save money?",
      "What is your opinion on working from home?",
      "What are the pros and cons of social media?",
      "How do you manage stress?",
      "What is the most interesting book you have ever read?",
      "Describe a difficult situation you faced and how you overcame it.",
      "What is one skill you wish you had?",
      "Do you think the education system needs to change?",
      "What is your favorite holiday and why?",
      "How often do you use public transportation?",
      "What kind of hobbies did you have as a child?",
      "Do you think global warming is a serious problem?",
      "What's the most important lesson you've learned in life?",
      "How do you keep up with current events?",
      "What is a typical dish from your culture?",
      "Do you enjoy cooking for others?"
    ],
    // B2 SEVİYESİ (20 Soru)
    "B2": [
      "Discuss the effects of globalization on local cultures.",
      "What role does artificial intelligence play in modern society?",
      "Should governments censor information on the internet?",
      "Analyze the benefits and drawbacks of a four-day work week.",
      "How does cultural identity influence political views?",
      "To what extent should we rely on renewable energy sources?",
      "Is privacy an outdated concept in the digital age?",
      "Evaluate the impact of influencers on consumer behavior.",
      "What measures can be taken to combat economic inequality?",
      "Discuss the ethics of genetic engineering.",
      "How important is higher education today?",
      "Analyze the challenges of achieving work-life balance.",
      "Describe a current world event that concerns you and why.",
      "What are the arguments for and against universal basic income?",
      "How does humor differ across various cultures?",
      "Discuss the philosophical implications of space exploration.",
      "Should animals have the same rights as humans?",
      "Evaluate the effectiveness of current social media regulations.",
      "What factors contribute to successful long-term relationships?",
      "Analyze the concept of 'digital detox'."
    ],
    // C1 SEVİYESİ (Mevcut Sorular)
    "C1": [
      "What are the biggest challenges of modern life?",
      "Do you think AI will replace humans?",
      "How does social media affect mental health?"
    ],
  };

  final List<String> praiseWords = ["Great!", "Excellent!", "Amazing!", "Good job!", "Fantastic!", "You are doing great!", "Perfect!"];
  
  String currentLevel = "A1";
  int questionIndex = 0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    initTts();
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  Future<void> initTts() async {
    // Dil ayarı (Lütfen fiziksel cihazınızda İngilizce ses paketinin yüklü olduğundan emin olun.)
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);

    flutterTts.setCompletionHandler(() {
      if (_isAutoModeActive && !_isListening) {
        // TTS bittikten sonra yankı sönmesi için 5 saniye bekleme (Ayar Korundu)
        Future.delayed(const Duration(milliseconds: 5000), () {
          if (_isAutoModeActive) {
            startListening();
          }
        });
      }
    });
  }

  // --- DİNLENME SÜRESİNİ SEVİYEYE GÖRE AYARLAMA ---
  Duration getListeningDuration() {
    switch (currentLevel) {
      case "A1":
      case "A2":
        return const Duration(seconds: 10);
      case "B1":
      case "B2":
        return const Duration(seconds: 20);
      case "C1":
        return const Duration(seconds: 30);
      default:
        return const Duration(seconds: 10); 
    }
  }

  String get currentQuestion {
    // Olası hata kontrolü: Eğer seviyede hiç soru kalmadıysa, sessizce durur.
    if (questionPool[currentLevel] == null || questionIndex >= questionPool[currentLevel]!.length) {
      return "Soru havuzu bu seviye için tükendi.";
    }
    return questionPool[currentLevel]![questionIndex];
  }

  // --- 1. SOHBETİ BAŞLAT / DURDUR ---
  void toggleSession() {
    if (_isAutoModeActive) {
      stopSession();
    } else {
      startSession();
    }
  }

  void startSession() async {
    setState(() {
      _isAutoModeActive = true;
      questionIndex = 0;
      _lastWords = "";
    });
    prepareAndSpeak(currentQuestion);
  }

  void stopSession() {
    _speech.stop();
    flutterTts.stop();
    setState(() {
      _isAutoModeActive = false;
      _isListening = false;
      _statusText = "Durduruldu 🛑";
    });
  }
  
  // KRİTİK FONKSİYON: Konuşma Başlatma Gecikmesi (Ayar Korundu)
  Future<void> prepareAndSpeak(String text) async {
    // Mikrofonun durdurulduğundan emin olmak için 1 saniye bekle
    await Future.delayed(const Duration(milliseconds: 1000));
    
    await _speak(text);
  }

  // --- 2. KONUŞMA MOTORU ---
  Future<void> _speak(String text) async {
    setState(() => _statusText = "Soruyorum :) 🤖");
    await flutterTts.speak(text);
  }
  
  // --- 3. DİNLEME MOTORU ---
  void startListening() async {
    bool available = await _speech.initialize(
      onError: (val) => print('Hata: $val'),
      onStatus: (val) {
        if (val == 'done' || val == 'notListening') {
          if (_isListening) {
             stopListeningAndProcess();
          }
        }
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
        _statusText = "Seni Dinliyor... 👂";
        _lastWords = "";
      });
      
      _speech.listen(
        onResult: (val) {
          setState(() {
            _lastWords = val.recognizedWords;
          });
        },
        localeId: "en-US",
        pauseFor: const Duration(milliseconds: 5000), // 5 saniye bekleme (Siz susunca)
        listenFor: getListeningDuration(), // Seviyeye göre maksimum süre
      );
    }
  }

  void stopListeningAndProcess() async {
    setState(() => _isListening = false);
    _speech.stop(); // Mikrofonu durdur
    
    // Mikrofonun tamamen kapandığından emin olmak için 1 saniye bekle (Ayar Korundu)
    await Future.delayed(const Duration(milliseconds: 1000)); 

    if (!_isAutoModeActive) return;

    if (_lastWords.isEmpty) {
       await prepareAndSpeak("Again."); 
       return; 
    }

    processAnswer();
  }

  void processAnswer() async {
    String praise = praiseWords[Random().nextInt(praiseWords.length)];
    await prepareAndSpeak(praise); 
    
    await Future.delayed(const Duration(milliseconds: 2500)); 

    setState(() {
      if (questionIndex < questionPool[currentLevel]!.length - 1) {
        questionIndex++;
      } else {
        questionIndex = 0; 
        prepareAndSpeak("Level finished!");
        return;
      }
    });

    await prepareAndSpeak(currentQuestion);
  }

  void changeLevel(String level) {
    stopSession();
    setState(() {
      currentLevel = level;
      _statusText = "Seviye $level seçildi. Lütfen sohbeti tekrar başlatın.";
    });
  }

  @override
  Widget build(BuildContext context) {
    // SEVİYE BUTONLARI
    final List<String> availableLevels = ["A1", "A2", "B1", "B2", "C1"];
    
    return Scaffold(
      appBar: AppBar(title: const Text("English AI Practical"), centerTitle: true, elevation: 0),
      body: Column(
        children: [
          // SEVİYE SEÇİMİ
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: availableLevels.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: ChoiceChip(
                    label: Text(e),
                    selected: currentLevel == e,
                    onSelected: (sel) => changeLevel(e),
                    selectedColor: Colors.indigoAccent,
                    labelStyle: TextStyle(color: currentLevel == e ? Colors.white : Colors.black),
                  ),
                )).toList(),
              ),
            ),
          ),
          
          const Spacer(),

          // --- DALGALANAN MİKROFON ---
          Stack(
            alignment: Alignment.center,
            children: [
              if (_isListening)
                AnimatedBuilder(
                  animation: _rippleController,
                  builder: (context, child) {
                    return Container(
                      width: 150 + (_rippleController.value * 50),
                      height: 150 + (_rippleController.value * 50),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.withOpacity(0.5 - _rippleController.value * 0.5),
                      ),
                    );
                  },
                ),
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening ? Colors.red : (_isAutoModeActive ? Colors.indigo : Colors.grey),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.headset,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
          
          Text(_statusText, style: TextStyle(color: Colors.indigo[800], fontWeight: FontWeight.bold)),
          
          const SizedBox(height: 20),

          // SORU KARTI
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    Text(currentQuestion, 
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)
                    ),
                    const SizedBox(height: 15),
                    const Divider(),
                    const SizedBox(height: 10),
                    Text(
                      _lastWords.isEmpty ? "Cevabın buraya gelecek..." : _lastWords, 
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey[600], fontStyle: FontStyle.italic)
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Spacer(),

          // BAŞLAT BUTONU
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAutoModeActive ? Colors.redAccent : Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: toggleSession,
              icon: Icon(_isAutoModeActive ? Icons.stop : Icons.play_arrow, size: 40, color: Colors.white),
              label: Text(
                _isAutoModeActive ? "SOHBETİ BİTİR" : "SOHBETİ BAŞLAT",
                style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}