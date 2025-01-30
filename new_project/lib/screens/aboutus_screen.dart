import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About Professional Locator',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Professional Locator is an app designed to connect you with the professionals you need, whether it\'s a plumber, electrician, teacher, or any other expert. Our mission is to make your life easier by providing quick access to trusted and skilled individuals.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            const Text(
              'Our Mission',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'To create a platform that simplifies the process of finding and hiring professionals, ensuring reliability and quality for every user.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                Icon(Icons.email, color: Colors.blue),
                SizedBox(width: 10),
                Text('support@professionallocator.com'),
              ],
            ),
            const SizedBox(height: 10),
            const Row(
              children:  [
                Icon(Icons.phone, color: Colors.blue),
                SizedBox(width: 10),
                Text('+1 234 567 890'),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Follow Us',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  icon: const Icon(FontAwesomeIcons.facebook, color: Colors.blue),
                  onPressed: () {
                    // Open Facebook link
                  },
                ),
                IconButton(
                  icon: const Icon(FontAwesomeIcons.twitter, color: Colors.blue),
                  onPressed: () {
                    // Open Twitter link
                  },
                ),
                IconButton(
                  icon: const Icon(FontAwesomeIcons.instagram, color: Colors.pink),
                  onPressed: () {
                    // Open Instagram link
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
