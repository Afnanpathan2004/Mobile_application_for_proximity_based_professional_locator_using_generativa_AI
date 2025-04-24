import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_animate/flutter_animate.dart';
import 'package:new_project/services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Map<String, dynamic> _userData = {};
  bool _isLoading = true;

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
    _loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await ApiService.getUserProfile();
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Failed to load profile data: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : 'Not specified',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
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
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: colorScheme.primary,
              statusBarIconBrightness: colorScheme.brightness == Brightness.dark 
                  ? Brightness.light 
                  : Brightness.dark,
            ),
            title: const Text('My Profile'),
            centerTitle: true,
            backgroundColor: colorScheme.primary,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Navigate to edit profile screen
                },
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          Center(
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _userData['username'] ?? 'User',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _userData['profession'] ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                _buildProfileItem(
                                  Icons.person_outline,
                                  'Full Name',
                                  '${_userData['first_name'] ?? ''} ${_userData['last_name'] ?? ''}',
                                ),
                                const Divider(height: 1, indent: 56),
                                _buildProfileItem(
                                  Icons.email_outlined,
                                  'Email',
                                  _userData['email'] ?? '',
                                ),
                                const Divider(height: 1, indent: 56),
                                _buildProfileItem(
                                  Icons.phone_outlined,
                                  'Phone Number',
                                  _userData['contact_number'] ?? '',
                                ),
                                const Divider(height: 1, indent: 56),
                                _buildProfileItem(
                                  Icons.cake_outlined,
                                  'Date of Birth',
                                  _userData['dob'] ?? '',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                _buildProfileItem(
                                  Icons.work_outline,
                                  'Profession',
                                  _userData['profession'] ?? '',
                                ),
                                const Divider(height: 1, indent: 56),
                                _buildProfileItem(
                                  Icons.home_outlined,
                                  'Address',
                                  _userData['address'] ?? '',
                                ),
                                const Divider(height: 1, indent: 56),
                                _buildProfileItem(
                                  Icons.location_on_outlined,
                                  'Pincode',
                                  _userData['pincode'] ?? '',
                                ),
                                const Divider(height: 1, indent: 56),
                                _buildProfileItem(
                                  Icons.location_city_outlined,
                                  'City',
                                  _userData['city'] ?? '',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => ApiService.logoutUser().then((_) {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context, 
                                    '/login', 
                                    (route) => false
                                  );
                                }),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Logout'),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}