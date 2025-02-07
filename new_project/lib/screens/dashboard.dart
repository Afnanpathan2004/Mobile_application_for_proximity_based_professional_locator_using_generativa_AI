import 'package:flutter/material.dart';
import 'package:new_project/screens/aboutus_screen.dart';
import 'package:new_project/screens/chatbot_screen.dart';
import 'package:new_project/screens/community_screen.dart';
import 'package:new_project/screens/home_screen.dart';
import 'package:new_project/screens/profile_screen.dart';
import 'package:new_project/screens/professional_profile_screen.dart';
import 'package:new_project/screens/chat_history_screen.dart';
import 'package:new_project/services/api_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _professionals = [];
  bool _isLoading = false;

  void _onSearch() async {
    String query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        final response = await ApiService.searchProfessionals(query);
        setState(() {
          _professionals = response['data'] ?? [];
        });
      } catch (e) {
        _showErrorDialog("Error", "Failed to fetch professionals. Please try again.");
      }
      setState(() => _isLoading = false);
    }
  }

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
      _showErrorDialog("Error", "Failed to load community.");
    }
  }


// Function to logout user 
  void _logoutUser() async {
    try {
      await ApiService.logoutUser();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      _showErrorDialog("Error", "Failed to logout. Please try again.");
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
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search for professionals (Plumber, Electrician, etc.)',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white),
          ),
          style: const TextStyle(color: Colors.white),
          onSubmitted: (value) => _onSearch(),
          textInputAction: TextInputAction.search,
        ),
      ),
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
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const ChatbotScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Chat History'),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const ChatHistoryScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Community'),
              onTap: () => _navigateToCommunity(context),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About Us'),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const AboutUs())),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () 
              => _logoutUser(),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _professionals.isEmpty
              ? const Center(
                  child: Text(
                    'No professionals found. Please search.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: _professionals.length,
                  itemBuilder: (context, index) {
                    var professional = _professionals[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfessionalProfileScreen(
                              professional: professional,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.all(10),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                professional['username'] ?? "No Username",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text("Profession: ${professional['profession'] ?? "N/A"}"),
                              const SizedBox(height: 5),
                              Text("Address: ${professional['address'] ?? "N/A"}"),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
