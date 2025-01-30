import 'package:flutter/material.dart';
import 'package:new_project/screens/aboutus_screen.dart';
import 'package:new_project/screens/chatbot_screen.dart';
import 'package:new_project/screens/community_screen.dart';
import 'package:new_project/screens/home_screen.dart';
import 'package:new_project/screens/profile_screen.dart';
import 'package:new_project/services/api_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // Controller to manage input from the search bar
  final TextEditingController _searchController = TextEditingController();

  // Function to handle search and send to backend
  void _onSearch() async {
    String query = _searchController.text.trim(); // Get user input
    // print('dashboard vala : $query');
    if (query.isNotEmpty) {
      try {
        // Call the API service to search for professionals
        final response = await ApiService.searchProfessionals(query);

        // For now, print response (can update UI later)
        print("Search response: $response");
      } catch (e) {
        print("Error searching: $e");
      }
    }
  }

  // Function to navigate to the community
  void _navigateToCommunity(BuildContext context) async {
    try {
      final response = await ApiService.getCommunityPosts();
      if (response) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CommunityScreen()),
        );
      } else {
        _showErrorDialog("Access Denied", "You must be logged in to access the community.");
      }
    } catch (e) {
      _showErrorDialog("Error", "Failed to load community. Please try again.");
    }
  }

// Function to show error dialog
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Search bar at the top in the AppBar
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search for professionals...(Plumber, Electrician, etc.)',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white),
          ),
          style: const TextStyle(color: Colors.white),
          onSubmitted: (value) => _onSearch(), // Trigger search on Enter key
          textInputAction: TextInputAction.search, // Keyboard shows 'Search'
        ),
      ),
      // Vertical Navigation Drawer (Navigation Bar)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chatbot'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatbotScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Community'),
              onTap: () 
                => _navigateToCommunity(context),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About Us'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutUs()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'Welcome to the Main Page!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
