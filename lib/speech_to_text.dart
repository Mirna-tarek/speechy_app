import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart';

class SpeechText extends StatefulWidget {
  const SpeechText({super.key});

  @override
  State<SpeechText> createState() => _SpeechTextState();
}

class _SpeechTextState extends State<SpeechText> {
  bool isListening = false;
  late stt.SpeechToText _speechToText;
  String text = "Press the button & Speak";
  double confidence = 1.0;
  String currentLocaleId = 'en-US'; // Default to English
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _speechToText = stt.SpeechToText();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // No specific logic needed here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confidence: ${(confidence * 100).toStringAsFixed(1)}"),
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: isListening,
        glowColor: Colors.blue,
        duration: const Duration(milliseconds: 1000),
        repeat: true,
        child: FloatingActionButton(
          onPressed: _captureVoice,
          backgroundColor: Colors.blue,
          child: Icon(
            isListening ? Icons.mic : Icons.mic_none,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        reverse: true,
        child: Container(
          padding: EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Select your preferred language",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  _setLocale('en-US'); // Set English locale
                },
                child: Text('English Speech'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _setLocale('ar-SA'); // Set Arabic locale
                },
                child: Text('Arabic Speech'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _setLocale('fr-FR'); // Set French locale
                },
                child: Text('French Speech'),
              ),
              SizedBox(height: 20),
              Text(
                'Current Language: ${_getLanguageName(currentLocaleId)}',
                style: TextStyle(fontSize: 10),
              ),
              SizedBox(height: 20),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setLocale(String localeId) {
    setState(() {
      currentLocaleId = localeId;
      text = "Press the button & Speak"; // Resetting recognized speech text
    });
  }

  String _getLanguageName(String localeId) {
    switch (localeId) {
      case 'en-US':
        return 'English';
      case 'ar-SA':
        return 'Arabic';
      case 'fr-FR':
        return 'French';
      default:
        return 'Unknown';
    }
  }


  /// Handles the voice capture and speech recognition
  /// This is an asynchronous function because it involves waiting for
  /// speech-to-text service initialization and listening for voice input.
  Future<void> _captureVoice() async {
    if (!isListening) {
      bool available = await _speechToText.initialize(
        onStatus: (status) => _handleStatusChange(status),
        onError: (error) => print('Error: $error'),
      );
      if (available) {
        setState(() {
          isListening = true;
        });

        _speechToText.listen(
          onResult: (result) {
            setState(() {
              text = result.recognizedWords;   // Updating recognized speech text
              if (result.hasConfidenceRating && result.confidence > 0) {
                confidence = result.confidence;  // Updating confidence level
              }
              if (result.finalResult) {
                _showRecognitionDialog(result.recognizedWords);  // Showing recognition dialog
              }
              _scrollToBottom(); // Scrolling to bottom to show latest speech
            });
          },
          localeId: currentLocaleId, // Set locale dynamically based on button click
          listenFor: Duration(minutes: 5),
          pauseFor: Duration(seconds: 5),
          cancelOnError: true,
          partialResults: true,
        );
      } else {
        setState(() {
          isListening = false;
        });
      }
    } else {
      setState(() {
        isListening = false;
      });
      _speechToText.stop();
    }
  }

  void _handleStatusChange(String status) {
    if (status == "notListening") {
      setState(() {
        isListening = false;
      });
    }
  }

  void _showRecognitionDialog(String recognizedText) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Recognized Speech'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(recognizedText),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: recognizedText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Successfully copied text")),
                      );
                    },
                    child: Text(
                      "Copy Text",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,     // Scrolling to the bottom of the list
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}




