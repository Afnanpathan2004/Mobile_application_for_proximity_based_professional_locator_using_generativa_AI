import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required Map<String, dynamic> professional});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
 final AudioRecorder _audioRecorder = AudioRecorder();

  final AudioPlayer _audioPlayer = AudioPlayer();
  // ignore: unused_field
  String? _recordedFilePath;
  bool _isRecording = false;

  // Start recording audio
 Future<void> _startRecording() async {
  try {
    final hasPermission = await _audioRecorder.hasPermission();
    if (hasPermission) {
      Directory tempDir = await getTemporaryDirectory();
      String path = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        RecordConfig(encoder: AudioEncoder.aacLc),
        path: path, // Ensure path is passed
      );

      setState(() {
        _isRecording = true;
        _recordedFilePath = path;
      });
    }
  } catch (e) {
    print("Recording error: $e");
  }
}
  // Stop recording and save audio
  Future<void> _stopRecording() async {
    try {
      String? path = await _audioRecorder.stop();
      if (path != null) {
        setState(() {
          _isRecording = false;
          messages.add({'type': 'audio', 'path': path});
        });
      }
    } catch (e) {
      print("Stop recording error: $e");
    }
  }

  // Play recorded audio
  Future<void> _playAudio(String path) async {
    await _audioPlayer.play(DeviceFileSource(path));
  }

  // Send text message
  void _sendMessage() {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        messages.add({'type': 'text', 'message': message});
      });
      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var msg = messages[index];
                if (msg['type'] == 'text') {
                  // Display text messages
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        msg['message'],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                } else if (msg['type'] == 'audio') {
                  // Display audio messages with play button
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.play_arrow, color: Colors.black),
                            onPressed: () => _playAudio(msg['path']),
                          ),
                          const Text("Voice Message"),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
                GestureDetector(
                  onLongPress: _startRecording,
                  onLongPressUp: _stopRecording,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording ? Colors.red : Colors.grey,
                    ),
                    child: const Icon(Icons.mic, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
