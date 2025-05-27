import 'package:flutter/material.dart';
import 'package:speech_to_text_field/speech_to_text_field.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech To Text Field Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ExamplePage(),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final TextEditingController _basicController = TextEditingController();
  final TextEditingController _customController = TextEditingController();
  final TextEditingController _multilineController = TextEditingController();
  String _errorMessage = '';
  bool _isListening = false;

  @override
  void dispose() {
    _basicController.dispose();
    _customController.dispose();
    _multilineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech to Text Field Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic example
            const Text(
              'Basic Usage:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SpeechToTextField(
              controller: _basicController,
              labelText: 'Basic Speech Input',
              hintText: 'Tap the mic icon and speak',
            ),
            const SizedBox(height: 24),

            // Custom appearance example
            const Text(
              'Custom Appearance:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SpeechToTextField(
              controller: _customController,
              micIcon: Icons.mic_outlined,
              listeningIcon: Icons.record_voice_over,
              micIconColor: Colors.blue,
              listeningIconColor: Colors.green,
              iconPosition: IconPosition.prefix,
              decoration: InputDecoration(
                labelText: 'Custom Speech Input',
                hintText: 'Customized mic button (prefix)',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Multiline with callbacks example
            const Text(
              'Multiline with Callbacks:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SpeechToTextField(
              controller: _multilineController,
              labelText: 'Multiline Speech Input',
              hintText: 'Tap mic and speak for multiline text',
              maxLines: 4,
              keyboardType: TextInputType.multiline,
              onListeningStarted: () {
                setState(() {
                  _isListening = true;
                  _errorMessage = '';
                });
              },
              onListeningStopped: () {
                setState(() {
                  _isListening = false;
                });
              },
              onListeningError: (error) {
                setState(() {
                  _isListening = false;
                  _errorMessage = error;
                });
              },
            ),
            const SizedBox(height: 8),
            if (_isListening)
              const Text(
                '🎤 Listening...',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            if (_errorMessage.isNotEmpty)
              Text(
                '❌ Error: $_errorMessage',
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 24),

            // Display the text
            const Text(
              'Results:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildResultCard('Basic Input', _basicController.text),
            const SizedBox(height: 8),
            _buildResultCard('Custom Input', _customController.text),
            const SizedBox(height: 8),
            _buildResultCard('Multiline Input', _multilineController.text),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(String title, String text) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              text.isEmpty ? '(No text yet)' : text,
              style: TextStyle(
                color: text.isEmpty ? Colors.grey : Colors.black,
                fontStyle: text.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
