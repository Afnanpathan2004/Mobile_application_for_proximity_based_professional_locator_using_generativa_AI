import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Search bar at the top in the AppBar
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search for professionals...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white),
          ),
          style: TextStyle(color: Colors.white),
        ),
      ),
      // Vertical Navigation Drawer (Navigation Bar)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Chatbot'),
              onTap: () {
                // Navigate to Chatbot page
              },
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text('Community'),
              onTap: () {
                // Navigate to Community page
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                // Navigate to Profile page
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About Us'),
              onTap: () {
                // Navigate to About Us page
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                // Handle logout functionality
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Welcome to the Main Page!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
