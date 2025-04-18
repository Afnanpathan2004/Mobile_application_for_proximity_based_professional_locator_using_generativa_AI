import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class ApiService {
  static const String baseUrl =
      'http://127.0.0.1:8000'; // Replace with your FastAPI URL
  static String? sessionCookie;
  static String? loggedInUsername;

// code to extract loggedin username from JWT
  static String? extractUsernameFromJWT(String jwt) {
    try {
      final jwtDecoded = JWT.decode(jwt);
      // debugPrint("Decoded JWT: $jwtDecoded");
      return jwtDecoded.payload['sub'];
    } catch (e) {
      debugPrint("Error decoding JWT: $e");
      return null;
    }
  }

// Extract session token from the cookie
  static void extractCookie(String accessToken) {
    sessionCookie = "access_token=$accessToken"; // Store the token
    // debugPrint("Session Cookie: $sessionCookie");

    // Extract and store the username from the JWT
    loggedInUsername = extractUsernameFromJWT(accessToken);
    // debugPrint("Logged in User: $loggedInUsername");
  }

// Search Functionality
  static Future<dynamic> searchProfessionals(String query) async {
    if (kDebugMode) {
      // print('api service vala : $query');
    }
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
      rethrow;
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
      final responseData = jsonDecode(response.body);
      String accessToken = responseData['access_token'];
      extractCookie(accessToken);
      return responseData;
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

// Send Chat functionality
  Future<void> sendMessage(String message, String receiverId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sender': 'PLACEHOLDER',
          'message': message,
          'receiver': receiverId,
          'timestamp': '2025-02-08T09:34:23.923Z'
        }),
      );

      if (response.statusCode != 200) {
        debugPrint("Failed to send message: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

// Connect to websocket functionality
  WebSocketChannel? channel;
  void connectWebSocket() {
    if (loggedInUsername == null) {
      debugPrint(
          "Error: No logged-in user found. Cannot connect to WebSocket.");
      return;
    }

    // debugPrint('Connecting WebSocket for user: $loggedInUsername');
    channel = WebSocketChannel.connect(
      Uri.parse('ws://127.0.0.1:8000/chat/ws/$loggedInUsername'),
    );
  }

// Listen for incoming messages
  void listenForMessages(Function(dynamic) onMessageReceived) {
    // debugPrint("Listening for WebSocket messages");
    channel!.stream.listen(
      (message) {
        // debugPrint("WebSocket Message Received: $message");
        onMessageReceived(message);
      },
      onError: (error) {
        debugPrint("WebSocket Error: $error");
      },
      onDone: () {
        debugPrint("WebSocket connection closed");
      },
      cancelOnError: true,
    );
  }

  void disconnectWebSocket() {
    channel?.sink.close(status.normalClosure);
    channel = null;
  }

// Fetch chat history
  static Future<dynamic> fetchChatHistory(String professionalUsername) async {
    final Uri url = Uri.parse('$baseUrl/chat/$professionalUsername');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // debugPrint('Chat History recieved from the backend (API Service): ${jsonDecode(response.body)['messages']}');
        return jsonDecode(response.body)['messages']; // Extract chat messages
      } else {
        throw Exception('Failed to fetch chat history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Chat History Fetch Error: $e');
    }
  }

// Community API'S

// Fetch previous chats from the backend
  static Future<List<Map<String, String>>> fetchPreviousChats() async {
    final response = await http.get(Uri.parse("$baseUrl/display_community"));
    if (response.statusCode == 200) {
      // debugPrint("raw Response: ${response.body}");
      final Map<String, dynamic> responseBody = json.decode(response.body);
      // debugPrint("Decoded Response Body: $responseBody");
      // Extract the "messages" list from the response
      final List<dynamic> messages = responseBody["messages"];
      // debugPrint("Messages got: $messages");
      // Convert each message to a Map<String, String>
      return messages
          .map((chat) => {
                "text": chat["message"].toString(), // Ensure "text" is a String
                "sender":
                    chat["username"].toString(), // Ensure "sender" is a String
              })
          .toList();
    } else {
      throw Exception("Failed to load previous chats");
    }
  }

  // Send a message to the backend
  static Future<void> sendMessageCommunity(String message) async {
    final response = await http.post(
      Uri.parse("$baseUrl/community"),
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode({"message": message}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      if (responseBody["success"] == true) {
        // debugPrint("Message sent successfully: ${responseBody["message"]}");
      } else {
        throw Exception("Failed to send message: ${responseBody["detail"]}");
      }
    } else {
      throw Exception("Failed to send message: ${response.statusCode}");
    }
  }

// Chatbot API

// Send a message to the backend
  static Future<Map<String, dynamic>> chatbotchat(String message) async {
    final response = await http.post(
      Uri.parse("$baseUrl/chat"),
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode({"message": message}),
    );

    if (response.statusCode == 200) {
      // debugPrint("Chatbot response: ${response.body}");
      return json.decode(response.body);
    } else {
      throw Exception("Failed to send message: ${response.statusCode}");
    }
  }

// Get Conversation Log
  static Future<List<Map<String, dynamic>>> getConversationLog() async {
  final response = await http.get(Uri.parse("$baseUrl/chat"));
  if (response.statusCode == 200) {
    final body = json.decode(response.body);
    // debugPrint("Raw decoded body: $body");

    // If the response is a plain list:
    if (body is List) {
      return List<Map<String, dynamic>>.from(body);
    }

    // If it's a map with convo_log key:
    if (body is Map && body.containsKey("convo_log")) {
      return List<Map<String, dynamic>>.from(body["convo_log"]);
    }

    throw Exception("Unexpected response format: $body");
  } else {
    throw Exception("Failed to fetch chat log: ${response.statusCode}");
  }
}
}