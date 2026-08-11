import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/chat_models.dart';

class ChatApiService {
  ChatApiService({http.Client? client, this.baseUrl = 'http://10.0.2.2:8000/api/v1'}) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  String? token;

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<void> login({required String email, required String password}) async {
    final response = await _client.post(Uri.parse('$baseUrl/auth/login'), headers: _headers, body: jsonEncode({'email': email, 'password': password}));
    _ensureSuccess(response);
    token = (jsonDecode(response.body) as Map<String, dynamic>)['token'] as String;
  }

  Future<List<Conversation>> fetchConversations() async {
    final response = await _client.get(Uri.parse('$baseUrl/conversations'), headers: _headers);
    _ensureSuccess(response);
    final data = (jsonDecode(response.body) as Map<String, dynamic>)['data'] as List<dynamic>? ?? [];
    return data.map((item) => Conversation.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<ChatMessage>> fetchMessages(int conversationId) async {
    final response = await _client.get(Uri.parse('$baseUrl/conversations/$conversationId/messages?per_page=50'), headers: _headers);
    _ensureSuccess(response);
    final data = (jsonDecode(response.body) as Map<String, dynamic>)['data'] as List<dynamic>? ?? [];
    return data.map((item) => ChatMessage.fromJson(item as Map<String, dynamic>)).toList().reversed.toList();
  }

  Future<ChatMessage> sendMessage({required int conversationId, required String body, int? replyToId}) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/conversations/$conversationId/messages'),
      headers: _headers,
      body: jsonEncode({'body': body, if (replyToId != null) 'reply_to_id': replyToId}),
    );
    _ensureSuccess(response);
    return ChatMessage.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> markRead(int conversationId) async {
    final response = await _client.post(Uri.parse('$baseUrl/conversations/$conversationId/read'), headers: _headers);
    _ensureSuccess(response);
  }

  WebSocketChannel connectToConversation(int conversationId) {
    final uri = Uri.parse('ws://10.0.2.2:8080/app/connectreal-key?protocol=7&client=flutter&version=1.0&flash=false');
    return WebSocketChannel.connect(uri);
  }

  Future<String> authorizePrivateChannel({required String socketId, required String channelName}) async {
    final response = await _client.post(
      Uri.parse('http://10.0.2.2:8000/api/broadcasting/auth'),
      headers: _headers,
      body: jsonEncode({'socket_id': socketId, 'channel_name': channelName}),
    );
    _ensureSuccess(response);
    return (jsonDecode(response.body) as Map<String, dynamic>)['auth'] as String;
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ChatApiException('Request failed with status ${response.statusCode}: ${response.body}');
    }
  }
}

class ChatApiException implements Exception {
  const ChatApiException(this.message);
  final String message;

  @override
  String toString() => message;
}
