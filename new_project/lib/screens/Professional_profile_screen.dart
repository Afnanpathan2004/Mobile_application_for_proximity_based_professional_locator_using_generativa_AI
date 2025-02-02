import 'package:flutter/material.dart';
import 'chat_screen.dart'; // Import the Chat screen

class ProfessionalProfileScreen extends StatelessWidget {
  final Map<String, dynamic> professional;
  
  const ProfessionalProfileScreen({super.key, required this.professional});

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
                onPressed: () {
                  // Navigate to ChatScreen with this professional's info
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(professional: professional),
                    ),
                  );
                },
                child: const Text("Chat"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
