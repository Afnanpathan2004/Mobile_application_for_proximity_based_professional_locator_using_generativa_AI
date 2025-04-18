import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
        slivers: [
          // App bar with cool animation effect
          SliverAppBar(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: theme.colorScheme.primaryContainer,
              statusBarIconBrightness: theme.brightness == Brightness.dark 
                  ? Brightness.light 
                  : Brightness.dark,
            ),
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Welcome',
                style: textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
              ),
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.8),
                      theme.colorScheme.secondary.withOpacity(0.6),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.home_filled,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // Main content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Hero welcome card
                  _buildWelcomeCard(context),
                  const SizedBox(height: 32),
                  
                  // Auth options with cool animation
                  _buildAuthOptions(context),
                  const SizedBox(height: 32),
                  
                  // Additional features
                  _buildFeatureGrid(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      shadowColor: theme.colorScheme.primary.withOpacity(0.3),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.secondaryContainer,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Animated icon
              const SizedBox(
                height: 80,
                child: Center(
                  child: Icon(
                    Icons.rocket_launch,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                'Professional Locator',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Find and connect with professionals in your area',
                style: textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthOptions(BuildContext context) {
    return Column(
      children: [
        // Login button with animation
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(vertical: 8),
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.login, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  'Login to Your Account',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
        
        // Register button with animation
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(vertical: 8),
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.app_registration, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  'Create New Account',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explore Features',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildFeatureItem(
              context,
              icon: Icons.search,
              label: 'Find Pros',
              color: Colors.orange,
            ),
            _buildFeatureItem(
              context,
              icon: Icons.people,
              label: 'Community',
              color: Colors.purple,
            ),
            _buildFeatureItem(
              context,
              icon: Icons.chat,
              label: 'Chat',
              color: Colors.blue,
            ),
            _buildFeatureItem(
              context,
              icon: Icons.settings,
              label: 'Settings',
              color: Colors.grey,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          // Add feature navigation here
          _showFeatureComingSoon(context, label);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFeatureComingSoon(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$featureName Coming Soon!'),
        content: Text('This feature will be available in future updates.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}