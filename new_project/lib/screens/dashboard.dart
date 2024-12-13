import 'package:flutter/material.dart';
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
    print('dashboard vala : $query');
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
                // Navigate to Chatbot page
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Community'),
              onTap: () {
                // Navigate to Community page
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                // Navigate to Profile page
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About Us'),
              onTap: () {
                // Navigate to About Us page
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // Handle logout functionality
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
