import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'http://127.0.0.1:8000'; // Replace with your FastAPI URL
  static String? sessionCookie;

// Extract session token from the cookie
  static void extractCookie(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      sessionCookie = rawCookie.split(';')[0]; // Store only "access_token=..."
    }
  }

// Search Functionality
  static Future<dynamic> searchProfessionals(String query) async {
    // print('api service vala : $query');
    final Uri url = Uri.parse('$baseUrl/search'); // Endpoint for search

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(query), // Send query as JSON
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Return decoded response
      } else {
        throw Exception('Failed to search: ${response.statusCode}');
      }
    } catch (e) {
      throw e;
    }
  }

  // Registration endpoint
  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String password,
    required String dob,
    required String profession,
    required String address,
    required String pincode,
    required String contactNumber,
    required String email,
    required String latitude,
    required String longitude,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'dob': dob,
        'profession': profession,
        'address': address,
        'pincode': pincode,
        'contact_number': contactNumber,
        'email': email,
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  // Login endpoint
  Future<Map<String, dynamic>> loginUser({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/token');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      extractCookie(response); // Extract JWT from cookie and store it
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

// Community Endpoint
  static Future<dynamic> getCommunityPosts() async {
    final Uri url = Uri.parse('$baseUrl/display_community');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to fetch community posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Community Fetch Error: $e');
    }
  }

  static Future<dynamic> createCommunityPost(String content) async {
    final Uri url = Uri.parse('$baseUrl/community');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (sessionCookie != null) 'Cookie': sessionCookie!, // Send JWT
        },
        body: jsonEncode({'content': content}),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Community Post Error: $e');
    }
  }


// Logout Endpoint
  static Future<void> logoutUser() async {
    final Uri url = Uri.parse('$baseUrl/logout'); // Logout endpoint
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        // Clear session cookie after successful logout
        sessionCookie = null;
        // print("Logout successful");
      } else {
        throw Exception('Failed to logout: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Logout Error: $e');
    }
  }
}
