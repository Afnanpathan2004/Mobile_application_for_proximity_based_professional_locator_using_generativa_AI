import 'package:flutter/material.dart';
import 'package:new_project/services/api_service.dart';

class Profession {
  final String name;
  final IconData icon;

  Profession({required this.name, required this.icon});
}

final List<Profession> professions = [
  Profession(name: 'Plumber', icon: Icons.plumbing),
  Profession(name: 'Electrician', icon: Icons.electrical_services),
  Profession(name: 'Carpenter', icon: Icons.handyman),
  Profession(name: 'Mechanic', icon: Icons.car_repair),
  Profession(name: 'Painter', icon: Icons.format_paint),
];

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final TextEditingController _searchController = TextEditingController();

  void _onSearch() async {
    String query = _searchController.text.trim();
    if (query.isNotEmpty) {
      try {
        final response = await ApiService.searchProfessionals(query);
        print("Search response: $response");
      } catch (e) {
        print("Error searching: $e");
      }
    }
  }

  void _onProfessionSelected(String profession) async {
    print('Selected profession: $profession');
    try {
      final response = await ApiService.searchProfessionals(profession);
      print("Profession search response: $response");
    } catch (e) {
      print("Error searching for profession: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Community'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About Us'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
            childAspectRatio: 1.0,
          ),
          itemCount: professions.length,
          itemBuilder: (context, index) {
            final profession = professions[index];
            return GestureDetector(
              onTap: () => _onProfessionSelected(profession.name),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 4.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(profession.icon, size: 40, color: Colors.blue),
                    const SizedBox(height: 10),
                    Text(
                      profession.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
