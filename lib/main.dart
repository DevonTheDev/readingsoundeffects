import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(SpeechRecognitionReading());
}

class SpeechRecognitionReading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech to Text Demo',
      home: SpeechToTextDemo(),
    );
  }
}

class SpeechToTextDemo extends StatefulWidget {
  @override
  _SpeechToTextDemoState createState() => _SpeechToTextDemoState();
}

class _SpeechToTextDemoState extends State<SpeechToTextDemo> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = 'Press the button and start speaking';

  // Store the recognized words
  String _newWords = '';

  @override
  void initState() {
    super.initState();
    // Initialize the permission handler
    _initPermission();
  }

  Future<void> _initPermission() async {
    final microphoneStatus = await Permission.microphone.request();
    if (microphoneStatus.isGranted) {
      _initializeSpeechRecognition();
    } else {
      // Handle denied permission (optional)
    }
  }

  void _initializeSpeechRecognition() {
    _speech.initialize(
      onStatus: (status) {
        print(status);
        if (status == stt.SpeechToText.listeningStatus) {
          setState(() {
            _isListening = true;
            // Reset the recognized words when listening starts
            _newWords = '';
          });
        } else if (status == stt.SpeechToText.notListeningStatus) {
          setState(() {
            _isListening = false;
          });
          // Start a new listening session when done
          _startListening();
        }
      },
      onError: (error) {
        print('Error: $error');
        setState(() {
          _isListening = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speech to Text Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.all(16.0),
              child: Text(
                _text,
                style: TextStyle(fontSize: 24.0),
                softWrap: true,
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _toggleListening,
              child: _isListening ? Text('Stop Listening') : Text('Start Listening'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleListening() {
    if (!_isListening) {
      _startListening();
    } else {
      _speech.stop();
      // Refresh the whole application by popping and pushing the current route
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => SpeechToTextDemo(),
      ));
    }
  }

  void _startListening() {
    _speech.listen(
      onResult: (result) {
        setState(() {
          _text = result.recognizedWords;
          // Append recognized words to the new words
          _newWords += ' ' + result.recognizedWords;
        });
      },
    );
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }
}