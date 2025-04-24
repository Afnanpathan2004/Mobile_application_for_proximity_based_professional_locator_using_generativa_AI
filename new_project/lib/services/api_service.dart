import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static String? sessionCookie;
  static String? loggedInUsername;
  
  // Typing status functionality
  static final Map<String, bool> _typingStatus = {};
  static final StreamController<Map<String, bool>> _typingController = 
      StreamController<Map<String, bool>>.broadcast();
  static WebSocketChannel? _typingChannel;

  // Typing status methods
  static void sendTypingStatus(bool isTyping) {
    if (loggedInUsername == null) return;
    
    _typingStatus[loggedInUsername!] = isTyping;
    _typingController.add(Map.from(_typingStatus));
    
    // Send to server via WebSocket if connected
    _typingChannel?.sink.add(jsonEncode({
      'type': 'typing_status',
      'username': loggedInUsername,
      'is_typing': isTyping
    }));
  }

  static Stream<Map<String, bool>> get typingUpdates => _typingController.stream;

  static void connectTypingWebSocket() {
    if (loggedInUsername == null) return;
    
    _typingChannel = WebSocketChannel.connect(
      Uri.parse('ws://$baseUrl/ws/typing/$loggedInUsername'),
    );

    _typingChannel!.stream.listen((message) {
      try {
        final data = jsonDecode(message);
        if (data['type'] == 'typing_status') {
          final username = data['username'];
          final isTyping = data['is_typing'];
          _typingStatus[username] = isTyping;
          _typingController.add(Map.from(_typingStatus));
        }
      } catch (e) {
        debugPrint('Error handling typing status: $e');
      }
    }, onError: (error) {
      debugPrint('Typing WebSocket error: $error');
    });
  }

  static void disconnectTypingWebSocket() {
    _typingChannel?.sink.close(status.normalClosure);
    _typingChannel = null;
  }

  // Existing methods...

  static Future<Map<String, dynamic>> getUserProfile() async {
    final Uri url = Uri.parse('$baseUrl/user/profile');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (sessionCookie != null) 'Cookie': sessionCookie!,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  static String? extractUsernameFromJWT(String jwt) {
    try {
      final jwtDecoded = JWT.decode(jwt);
      return jwtDecoded.payload['sub'];
    } catch (e) {
      debugPrint("Error decoding JWT: $e");
      return null;
    }
  }

  static void extractCookie(String accessToken) {
    sessionCookie = "access_token=$accessToken";
    loggedInUsername = extractUsernameFromJWT(accessToken);
  }

  static Future<dynamic> searchProfessionals(String query) async {
    final Uri url = Uri.parse('$baseUrl/search');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(query),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to search: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

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
      connectTypingWebSocket(); // Connect typing WebSocket on login
      return responseData;
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

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
        throw Exception('Failed to fetch community posts: ${response.statusCode}');
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
          if (sessionCookie != null) 'Cookie': sessionCookie!,
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

  static Future<void> logoutUser() async {
    disconnectTypingWebSocket(); // Disconnect typing WebSocket on logout
    final Uri url = Uri.parse('$baseUrl/logout');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        sessionCookie = null;
        loggedInUsername = null;
      } else {
        throw Exception('Failed to logout: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Logout Error: $e');
    }
  }

  Future<void> sendMessage(String message, String receiverId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sender': loggedInUsername,
          'message': message,
          'receiver': receiverId,
          'timestamp': DateTime.now().toIso8601String()
        }),
      );

      if (response.statusCode != 200) {
        debugPrint("Failed to send message: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

  WebSocketChannel? channel;
  void connectWebSocket() {
    if (loggedInUsername == null) {
      debugPrint("Error: No logged-in user found. Cannot connect to WebSocket.");
      return;
    }

    channel = WebSocketChannel.connect(
      Uri.parse('ws://127.0.0.1:8000/chat/ws/$loggedInUsername'),
    );
  }

  void listenForMessages(Function(dynamic) onMessageReceived) {
    channel!.stream.listen(
      (message) {
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
        return jsonDecode(response.body)['messages'];
      } else {
        throw Exception('Failed to fetch chat history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Chat History Fetch Error: $e');
    }
  }

  static Future<List<Map<String, String>>> fetchPreviousChats() async {
    final response = await http.get(Uri.parse("$baseUrl/display_community"));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      final List<dynamic> messages = responseBody["messages"];
      return messages
          .map((chat) => {
                "text": chat["message"].toString(),
                "sender": chat["username"].toString(),
              })
          .toList();
    } else {
      throw Exception("Failed to load previous chats");
    }
  }

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
        debugPrint("Message sent successfully");
      } else {
        throw Exception("Failed to send message: ${responseBody["detail"]}");
      }
    } else {
      throw Exception("Failed to send message: ${response.statusCode}");
    }
  }

  static Future<Map<String, dynamic>> chatbotchat(String message) async {
    final response = await http.post(
      Uri.parse("$baseUrl/chat"),
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode({"message": message}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to send message: ${response.statusCode}");
    }
  }

  static Future<List<Map<String, dynamic>>> getConversationLog() async {
    final response = await http.get(Uri.parse("$baseUrl/chat"));
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      
      if (body is List) {
        return List<Map<String, dynamic>>.from(body);
      }

      if (body is Map && body.containsKey("convo_log")) {
        return List<Map<String, dynamic>>.from(body["convo_log"]);
      }

      throw Exception("Unexpected response format: $body");
    } else {
      throw Exception("Failed to fetch chat log: ${response.statusCode}");
    }
  }

  static Future<List<Map<String, dynamic>>> getChatHistory() async {
    final url = Uri.parse("$baseUrl/chat_history");

    final response = await http.get(url, headers: {
      "Accept": "application/json",
    });

    if (response.statusCode == 200) {
      final body = json.decode(response.body);

      if (body is Map && body.containsKey("data") && body["data"] is Map) {
        final Map<String, dynamic> data = body["data"];
        return data.entries.map<Map<String, dynamic>>((entry) {
          final userData = entry.value;
          return {
            "name": userData["sender"],
            "lastMessage": userData["message_text"],
            "timestamp": userData["timestamp"],
          };
        }).toList();
      }

      throw Exception("Unexpected response format: $body");
    } else {
      throw Exception("Failed to fetch chat history: ${response.statusCode}");
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final url = Uri.parse("$baseUrl/user_profile");
    
    try {
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        if (body is Map && body.containsKey("data") && body["data"] is Map) {
          final Map<String, dynamic> userData = body["data"];
          return {
            "username": userData["username"] ?? "User",
            "email": userData["email"] ?? "",
            "dob": userData["dob"] ?? "",
            "profession": userData["profession"] ?? "",
            "address": userData["address"] ?? "",
            "pincode": userData["pincode"]?.toString() ?? "",
          };
        }
        throw Exception("Invalid response format: Missing 'data' field");
      } else {
        throw Exception("Failed to fetch profile: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }
}