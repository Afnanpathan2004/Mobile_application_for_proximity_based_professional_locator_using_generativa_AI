import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // Controller to manage input from the search bar
  final TextEditingController _searchController = TextEditingController();

  // List of professions
  final List<String> professions = [
    'Doctor', 'Plumber', 'Electrician', 'Carpenter', 'Teacher',
    'Mechanic', 'Driver', 'Gardener', 'Painter', 'Chef',
    'Nurse', 'Software Developer', 'Data Scientist', 'Accountant', 'Architect',
    'Photographer', 'Artist', 'Dentist', 'Lawyer', 'Engineer',
    'Mason', 'Tailor', 'Cleaner', 'Barber', 'Beautician',
    'Farmer', 'Veterinarian', 'Pharmacist', 'Therapist', 'Librarian',
    'Security Guard', 'Translator', 'Tutor', 'Fitness Trainer', 'Yoga Instructor',
    'Dietitian', 'Social Worker', 'Consultant', 'Event Planner', 'Real Estate Agent',
    'Insurance Agent', 'Travel Agent', 'Hotel Manager', 'Bartender', 'Waiter',
    'Courier', 'Delivery Driver', 'Pilot', 'Flight Attendant', 'Researcher',
    'Scientist', 'Biologist', 'Chemist', 'Physicist', 'Geologist',
    'Astronomer', 'Economist', 'Marketing Specialist', 'Salesperson', 'Journalist',
    'Editor', 'Publisher', 'Actor', 'Musician', 'Singer',
    'Dancer', 'Film Director', 'Producer', 'Screenwriter', 'IT Technician',
    'Network Administrator', 'Cybersecurity Specialist', 'Mobile App Developer', 'Game Developer', 'UI/UX Designer',
    'Graphic Designer', 'Interior Designer', 'Fashion Designer', 'Model', 'Choreographer',
    'Scientist', 'Anthropologist', 'Historian', 'Archaeologist', 'Psychologist',
    'Psychiatrist', 'Counselor', 'Statistician', 'Surveyor', 'Urban Planner',
    'Civil Engineer', 'Electrical Engineer', 'Mechanical Engineer', 'Chemical Engineer', 'Biomedical Engineer',
    'Aerospace Engineer', 'Marine Engineer', 'Environmental Scientist', 'Wildlife Biologist', 'Forester'
  ];

  // Function to handle search and send to backend
  void _onSearch() async {
    String query = _searchController.text.trim(); // Get user input
    if (kDebugMode) {
      print('Search query: $query');
    }
    if (query.isNotEmpty) {
      // Perform search operation (API integration can be added here)
      if (kDebugMode) {
        print("Searching for: $query");
      }
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
              onTap: () {
                Navigator.pushNamed(context, '/chatbot');
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Community'),
              onTap: () {
                Navigator.pushNamed(context, '/community');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About Us'),
              onTap: () { Navigator.pushNamed(context, '/about_us');
              },
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
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5, // Five cards per row
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 2.0, // Adjusted for smaller cards
          ),
          itemCount: professions.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // Handle card tap
                if (kDebugMode) {
                  print('Tapped on: ${professions[index]}');
                }
                // Navigate to the details page with the profession name
              },
              child: Card(
                color: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 4,
                child: Center(
                  child: Text(
                    professions[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    }  }
