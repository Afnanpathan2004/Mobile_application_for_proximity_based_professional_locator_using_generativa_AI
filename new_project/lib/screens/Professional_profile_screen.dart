import 'package:flutter/material.dart';
import 'chat_screen.dart'; // Import the Chat screen
import 'package:new_project/services/api_service.dart';

class ProfessionalProfileScreen extends StatelessWidget {
  final Map<String, dynamic> professional;

  const ProfessionalProfileScreen({super.key, required this.professional});

// Function to fetch chat history, connect to websocket and navigate to ChatScreen
  void _handleChat(BuildContext context) async {
    try {
      // Step 1: Fetch chat history from FastAPI
      final chatHistory = await ApiService.fetchChatHistory(professional['username']);
      // debugPrint('Chat History recieved : $chatHistory');

      // Step 2: Navigate to ChatScreen with necessary data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            professional: professional,
            chatHistory: chatHistory, // Passing history to chat screen
          ),
        ),
      );
    } catch (e) {
      // Handle errors if API call or connection fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(professional['username'] ?? 'Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              professional['username'] ?? 'No username',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Profession: ${professional['profession'] ?? 'N/A'}"),
            const SizedBox(height: 8),
            Text("Address: ${professional['address'] ?? 'N/A'}"),
            const SizedBox(height: 8),
            Text("Contact: ${professional['contact_number'] ?? 'N/A'}"),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => _handleChat(context),
                child: const Text("Chat"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
