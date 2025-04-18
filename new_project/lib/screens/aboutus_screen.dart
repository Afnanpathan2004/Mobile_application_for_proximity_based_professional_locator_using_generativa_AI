import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.5, curve: Curves.easeIn),
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1, curve: Curves.elasticOut),
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: colorScheme.primary,
          statusBarIconBrightness: colorScheme.brightness == Brightness.dark 
              ? Brightness.light 
              : Brightness.dark,
        ),
        title: const Text('About Us'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/logo.png', // Replace with your logo
                    height: 120,
                    width: 120,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'About Professional Locator',
                  content: 'Professional Locator is an app designed to connect you with the professionals you need, whether it\'s a plumber, electrician, teacher, or any other expert. Our mission is to make your life easier by providing quick access to trusted and skilled individuals.',
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'Our Mission',
                  content: 'To create a platform that simplifies the process of finding and hiring professionals, ensuring reliability and quality for every user.',
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'Our Vision',
                  content: 'To become the most trusted platform for professional services worldwide, recognized for our commitment to quality and customer satisfaction.',
                ),
                const SizedBox(height: 24),
                _buildContactSection(
                  title: 'Contact Us',
                  items: [
                    _buildContactItem(
                      icon: Icons.email,
                      text: 'support@professionallocator.com',
                      onTap: () => _launchUrl('mailto:support@professionallocator.com'),
                    ),
                    _buildContactItem(
                      icon: Icons.phone,
                      text: '+1 234 567 890',
                      onTap: () => _launchUrl('tel:+1234567890'),
                    ),
                    _buildContactItem(
                      icon: Icons.location_on,
                      text: '123 Business Ave, City, Country',
                      onTap: () => _launchUrl('https://maps.google.com/?q=123+Business+Ave'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSocialMediaSection(),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget _buildContactSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: items,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem({required IconData icon, required String text, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(text),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      visualDensity: const VisualDensity(vertical: -2),
    );
  }

  Widget _buildSocialMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Follow Us',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(
              icon: FontAwesomeIcons.facebook,
              color: const Color(0xFF1877F2),
              url: 'https://facebook.com/professionallocator',
            ),
            const SizedBox(width: 16),
            _buildSocialIcon(
              icon: FontAwesomeIcons.twitter,
              color: const Color(0xFF1DA1F2),
              url: 'https://twitter.com/professionallocator',
            ),
            const SizedBox(width: 16),
            _buildSocialIcon(
              icon: FontAwesomeIcons.instagram,
              color: const Color(0xFFE4405F),
              url: 'https://instagram.com/professionallocator',
            ),
            const SizedBox(width: 16),
            _buildSocialIcon(
              icon: FontAwesomeIcons.linkedin,
              color: const Color(0xFF0A66C2),
              url: 'https://linkedin.com/company/professionallocator',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon({required IconData icon, required Color color, required String url}) {
    return IconButton(
      icon: FaIcon(icon, size: 28),
      color: color,
      onPressed: () => _launchUrl(url),
    );
  }
}