import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Add this import
import 'package:new_project/screens/aboutus_screen.dart';
import 'package:new_project/screens/chatbot_screen.dart';
import 'package:new_project/screens/community_screen.dart';
import 'package:new_project/screens/login_screen.dart';
import 'package:new_project/screens/profile_screen.dart';
import 'package:new_project/screens/professional_profile_screen.dart';
import 'package:new_project/screens/chat_history_screen.dart';
import 'package:new_project/services/api_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _professionals = [];
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSearch() async {
    String query = _searchController.text.trim();
    if (query.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.searchProfessionals(query);
      setState(() {
        _professionals = response['data'] ?? [];
      });
    } catch (e) {
      _showErrorDialog("Search Error", "Failed to fetch professionals. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateToCommunity(BuildContext context) async {
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

  Future<void> _logoutUser() async {
    try {
      await ApiService.logoutUser();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      _showErrorDialog("Logout Error", "Failed to logout. Please try again.");
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: colorScheme.background,
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: colorScheme.primary,
              statusBarIconBrightness: colorScheme.brightness == Brightness.dark 
                  ? Brightness.light 
                  : Brightness.dark,
            ),
            title: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search professionals...',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: colorScheme.onPrimaryContainer),
                      suffixIcon: _isLoading
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            )
                          : null,
                      hintStyle: TextStyle(color: colorScheme.onPrimaryContainer.withOpacity(0.6)),
                    ),
                    style: TextStyle(color: colorScheme.onPrimaryContainer),
                    onSubmitted: (value) => _onSearch(),
                    textInputAction: TextInputAction.search,
                  ),
                ),
              ),
            ),
            backgroundColor: colorScheme.primary,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
          ),
          drawer: _buildDrawer(context, colorScheme),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _buildBody(context, colorScheme),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, ColorScheme colorScheme) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.7,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: colorScheme.onPrimary,
                  child: Icon(
                    Icons.person,
                    size: 36,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Welcome!',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.chat_bubble_outline,
            title: 'Chatbot',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatbotScreen()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.history,
            title: 'Chat History',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatHistoryScreen()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.group,
            title: 'Community',
            onTap: () => _navigateToCommunity(context),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.person_outline,
            title: 'Profile',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.info_outline,
            title: 'About Us',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutUs()),
            ),
          ),
          const Divider(),
          _buildDrawerItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            onTap: _logoutUser,
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Theme.of(context).colorScheme.onSurface),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Widget _buildBody(BuildContext context, ColorScheme colorScheme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_professionals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: colorScheme.onBackground.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Search for professionals',
              style: TextStyle(
                fontSize: 18,
                color: colorScheme.onBackground.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for plumbers, electricians, etc.',
              style: TextStyle(
                color: colorScheme.onBackground.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _professionals.length,
      itemBuilder: (context, index) {
        final professional = _professionals[index];
        return _buildProfessionalCard(context, professional, colorScheme)
            .animate()
            .fadeIn(duration: 200.ms)
            .slideY(begin: 0.1, end: 0, duration: 300.ms);
      },
    );
  }

  Widget _buildProfessionalCard(
    BuildContext context,
    dynamic professional,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.person,
                  size: 36,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      professional['username'] ?? "Professional",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (professional['profession'] != null)
                      Row(
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: 16,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            professional['profession'],
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    if (professional['address'] != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              professional['address'],
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.8),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '4.8 (24 reviews)',
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}