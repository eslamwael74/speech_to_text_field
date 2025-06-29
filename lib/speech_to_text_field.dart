import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// A reusable TextField widget with speech-to-text functionality.
///
/// This widget provides a text field with a microphone button that allows
/// users to input text using voice recognition.
class SpeechToTextField extends StatefulWidget {
  /// Controller for the text field
  final TextEditingController controller;

  /// Label text for the text field
  final String labelText;

  /// Hint text for the text field
  final String hintText;

  /// Callback function when text changes
  final Function(String)? onChanged;

  /// Maximum number of lines for the text field
  final int? maxLines;

  /// Decoration for the text field
  final InputDecoration? decoration;

  /// Whether the text field is enabled
  final bool? enabled;

  /// Input action for the keyboard
  final TextInputAction? textInputAction;

  /// Focus node for the text field
  final FocusNode? focusNode;

  /// Text input type
  final TextInputType? keyboardType;

  /// Callback when speech recognition starts
  final VoidCallback? onListeningStarted;

  /// Callback when speech recognition stops
  final VoidCallback? onListeningStopped;

  /// Callback when speech recognition encounters an error
  final Function(String)? onListeningError;

  /// Custom icon for the microphone when not listening
  final IconData micIcon;

  /// Custom icon for the microphone when listening
  final IconData listeningIcon;

  /// Color of the microphone icon when not listening
  final Color? micIconColor;

  /// Color of the microphone icon when listening
  final Color listeningIconColor;

  /// Language locale for speech recognition
  final String? localeId;

  /// Position of the mic icon
  final IconPosition iconPosition;

  /// Style for the text field
  final TextStyle? style;

  const SpeechToTextField({
    super.key,
    required this.controller,
    this.labelText = '',
    this.hintText = '',
    this.onChanged,
    this.maxLines = 1,
    this.decoration,
    this.style,
    this.enabled,
    this.textInputAction,
    this.focusNode,
    this.keyboardType,
    this.onListeningStarted,
    this.onListeningStopped,
    this.onListeningError,
    this.micIcon = Icons.mic_none,
    this.listeningIcon = Icons.mic,
    this.micIconColor,
    this.listeningIconColor = Colors.red,
    this.localeId,
    this.iconPosition = IconPosition.suffix,
  });

  @override
  State<SpeechToTextField> createState() => _SpeechToTextFieldState();
}

class _SpeechToTextFieldState extends State<SpeechToTextField> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// Initialize the speech recognition service
  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: _onSpeechStatus,
      onError: _onSpeechError,
    );
    if (mounted) {
      setState(() {});
    }
  }

  /// Handle speech status changes
  void _onSpeechStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      if (mounted) {
        setState(() {
          _isListening = false;
        });
        if (widget.onListeningStopped != null) {
          widget.onListeningStopped!();
        }
      }
    }
  }

  /// Handle speech recognition errors
  void _onSpeechError(dynamic errorNotification) {
    if (mounted) {
      setState(() {
        _isListening = false;
      });

      if (widget.onListeningError != null) {
        String errorMessage = 'Speech recognition error';
        // Handle error object without using 'is' operator since SpeechRecognitionError is not directly accessible
        if (errorNotification != null && errorNotification.errorMsg != null) {
          errorMessage = errorNotification.errorMsg;
        } else if (errorNotification != null &&
            errorNotification.toString().isNotEmpty) {
          errorMessage = errorNotification.toString();
        }
        widget.onListeningError!(errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final IconButton micButton = IconButton(
      onPressed: _speechAvailable ? _toggleListening : null,
      tooltip: _isListening ? 'Stop listening' : 'Start listening',
      icon: Icon(
        _isListening ? widget.listeningIcon : widget.micIcon,
        color: _isListening
            ? widget.listeningIconColor
            : (widget.micIconColor ?? Theme.of(context).iconTheme.color),
      ),
    );

    InputDecoration effectiveDecoration =
        widget.decoration ??
        InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        );

    // Apply the mic button to the appropriate position
    if (widget.iconPosition == IconPosition.suffix) {
      effectiveDecoration = effectiveDecoration.copyWith(suffixIcon: micButton);
    } else {
      effectiveDecoration = effectiveDecoration.copyWith(prefixIcon: micButton);
    }

    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      maxLines: widget.maxLines,
      enabled: widget.enabled,
      textInputAction: widget.textInputAction,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      decoration: effectiveDecoration,
      style: widget.style,
    );
  }

  /// Toggle speech recognition on/off
  void _toggleListening() async {
    if (!_isListening) {
      if (_speechAvailable) {
        setState(() {
          _isListening = true;
        });

        if (widget.onListeningStarted != null) {
          widget.onListeningStarted!();
        }

        try {
          await _speech.listen(
            localeId: widget.localeId,
            onResult: (result) {
              if (mounted) {
                setState(() {
                  if (result.finalResult) {
                    if (result.recognizedWords.isEmpty) {
                      // Reset listening state if no results
                      _isListening = false;
                      return;
                    }

                    // If there's existing text, add a space before new text
                    String currentText = widget.controller.text;
                    if (currentText.isNotEmpty && !currentText.endsWith(' ')) {
                      currentText += ' ';
                    }
                    widget.controller.text =
                        currentText + result.recognizedWords;

                    // Set cursor to the end of the text
                    widget.controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: widget.controller.text.length),
                    );

                    // Call onChanged callback if provided
                    if (widget.onChanged != null) {
                      widget.onChanged!(widget.controller.text);
                    }

                    _isListening = false;
                    if (widget.onListeningStopped != null) {
                      widget.onListeningStopped!();
                    }
                  }
                });
              }
            },
          );
        } catch (e) {
          setState(() {
            _isListening = false;
          });

          if (widget.onListeningError != null) {
            widget.onListeningError!('Failed to start listening: $e');
          }
        }
      } else {
        // Try to initialize speech again if it wasn't available before
        bool available = await _speech.initialize(
          onStatus: _onSpeechStatus,
          onError: _onSpeechError,
        );

        if (mounted) {
          setState(() {
            _speechAvailable = available;
          });

          if (available) {
            _toggleListening(); // Call this method again now that speech is available
          } else if (widget.onListeningError != null) {
            widget.onListeningError!(
              'Speech recognition not available on this device',
            );
          }
        }
      }
    } else {
      _speech.stop();
      setState(() {
        _isListening = false;
      });

      if (widget.onListeningStopped != null) {
        widget.onListeningStopped!();
      }
    }
  }

  @override
  void dispose() {
    if (_isListening) {
      _speech.stop();
    }
    super.dispose();
  }
}

/// Position for the mic icon in the TextField
enum IconPosition {
  /// Show the mic icon as a prefix
  prefix,

  /// Show the mic icon as a suffix
  suffix,
}
