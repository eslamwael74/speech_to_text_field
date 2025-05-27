# Speech to Text Field

[![pub package](https://img.shields.io/pub/v/speech_to_text_field.svg)](https://pub.dev/packages/speech_to_text_field)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A Flutter widget that provides a TextField with built-in speech-to-text functionality. This widget makes it easy to add voice input capabilities to your app with minimal setup.

## Features

- 🎤 Easy-to-use TextField with integrated microphone button
- 📱 Works on Android, iOS, macOS, and Web
- 🔄 Seamless integration with existing Flutter apps
- 🌈 Customizable appearance and behavior
- 🗣️ Support for different languages
- ⚙️ Event callbacks for listening state changes
- 📝 Compatible with all standard TextField functionalities

![Speech to Text Field Demo](https://via.placeholder.com/300x200.png?text=SpeechToTextField+Demo)

## Requirements

- Flutter SDK 3.8.0 or higher
- iOS 10.0+ / Android 21+ (Android 5.0 Lollipop) / macOS 10.15+ / Modern browsers
- Microphone permissions configured in your app

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  speech_to_text_field: ^0.1.0
```

Then run:

```bash
flutter pub get
```

### Platform Setup

#### Android

Add the following permissions to your `AndroidManifest.xml` file:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

#### iOS

Add the following to your `Info.plist` file:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to your microphone for speech recognition</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs access to speech recognition to convert your speech to text</string>
```

#### macOS

Add the following to your `macos/Runner/Info.plist` file:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to your microphone for speech recognition</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs access to speech recognition to convert your speech to text</string>
```

Also, enable the microphone capability in `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:

```xml
<key>com.apple.security.device.audio-input</key>
<true/>
```

#### Web

For web support, no additional setup is required. However, be aware that:
- Speech recognition on the web uses the browser's built-in SpeechRecognition API
- It's only available in secure contexts (HTTPS)
- Browser support varies (Chrome has the best support)

## Usage

Basic usage example:

```dart
import 'package:flutter/material.dart';
import 'package:speech_to_text_field/speech_to_text_field.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SpeechInputExample(),
    );
  }
}

class SpeechInputExample extends StatefulWidget {
  @override
  State<SpeechInputExample> createState() => _SpeechInputExampleState();
}

class _SpeechInputExampleState extends State<SpeechInputExample> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech to Text Field Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SpeechToTextField(
              controller: _controller,
              labelText: 'Speak something',
              hintText: 'Tap the mic and start speaking',
              onListeningStarted: () {
                print('Started listening');
              },
              onListeningStopped: () {
                print('Stopped listening');
              },
              onListeningError: (error) {
                print('Error: $error');
              },
            ),
            const SizedBox(height: 20),
            Text('The text will appear here: ${_controller.text}'),
          ],
        ),
      ),
    );
  }
}
```

## Customization

`SpeechToTextField` provides many customization options:

```dart
SpeechToTextField(
  controller: _controller,
  labelText: 'Custom label',
  hintText: 'Custom hint',
  maxLines: 3,
  keyboardType: TextInputType.multiline,
  micIcon: Icons.mic_outlined,
  listeningIcon: Icons.record_voice_over,
  micIconColor: Colors.blue,
  listeningIconColor: Colors.green,
  iconPosition: IconPosition.prefix,
  localeId: 'en_US', // Specify language locale
  decoration: InputDecoration(
    filled: true,
    fillColor: Colors.grey[200],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
);
```

## Advanced Features

### Supported Languages

The widget supports multiple languages for speech recognition. You can specify the language by setting the `localeId` parameter:

```dart
SpeechToTextField(
  controller: _controller,
  localeId: 'fr_FR', // French
)
```

Common locale IDs:
- English (US): 'en_US'
- English (UK): 'en_GB'
- Spanish: 'es_ES'
- French: 'fr_FR'
- German: 'de_DE'
- Chinese (Simplified): 'zh_CN'
- Japanese: 'ja_JP'

### Listening Events

The widget provides callbacks for different speech recognition events:

```dart
SpeechToTextField(
  controller: _controller,
  onListeningStarted: () {
    // Called when speech recognition starts
  },
  onListeningStopped: () {
    // Called when speech recognition stops
  },
  onListeningError: (error) {
    // Called when there's an error with speech recognition
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Speech error: $error')),
    );
  },
)
```

## Contributing

Contributions are welcome! If you find a bug or want a feature, please open an issue on GitHub. If you want to contribute code, please fork the repository and submit a pull request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
