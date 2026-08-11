import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/chat_models.dart';
import '../services/chat_api_service.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider({ChatApiService? api}) : _api = api ?? ChatApiService();

  final ChatApiService _api;
  final List<Conversation> _conversations = [];
  final List<ChatMessage> _messages = [];
  WebSocketChannel? _channel;
  StreamSubscription? _socketSubscription;
  int? _activeConversationId;
  int _currentUserId = 1;
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;

  List<Conversation> get conversations => List.unmodifiable(_conversations);
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  int? get activeConversationId => _activeConversationId;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;
  int get currentUserId => _currentUserId;

  Future<void> connectDemo() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _api.login(email: 'ahmed@connectreal.test', password: 'password');
      _currentUserId = 1;
      _conversations
        ..clear()
        ..addAll(await _api.fetchConversations());
      if (_conversations.isNotEmpty) await openConversation(_conversations.first.id);
    } catch (error) {
      _error = 'Could not connect to the demo server. ${error.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> openConversation(int id) async {
    _activeConversationId = id;
    _messages.clear();
    _isLoading = true;
    notifyListeners();
    await _socketSubscription?.cancel();
    await _channel?.sink.close();
    try {
      _messages.addAll(await _api.fetchMessages(id));
      await _api.markRead(id);
      _channel = _api.connectToConversation(id);
      _socketSubscription = _channel!.stream.listen(_onSocketEvent, onError: (_) => _error = 'Live connection interrupted.');
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String body) async {
    final conversationId = _activeConversationId;
    final trimmed = body.trim();
    if (conversationId == null || trimmed.isEmpty) return;
    _isSending = true;
    notifyListeners();
    try {
      final sent = await _api.sendMessage(conversationId: conversationId, body: trimmed);
      if (!_messages.any((message) => message.id == sent.id)) _messages.add(sent);
    } catch (error) {
      _error = error.toString();
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> _onSocketEvent(dynamic rawEvent) async {
    try {
      final event = jsonDecode(rawEvent as String) as Map<String, dynamic>;
      final outerData = event['data'];
      final payload = outerData is String ? jsonDecode(outerData) as Map<String, dynamic> : (outerData as Map<String, dynamic>? ?? <String, dynamic>{});

      if (event['event'] == 'pusher:connection_established') {
        final socketId = payload['socket_id'] as String?;
        final conversationId = _activeConversationId;
        if (socketId == null || conversationId == null) return;
        final channelName = 'private-conversation.$conversationId';
        final auth = await _api.authorizePrivateChannel(socketId: socketId, channelName: channelName);
        _channel?.sink.add(jsonEncode({'event': 'pusher:subscribe', 'data': {'auth': auth, 'channel': channelName}}));
        return;
      }

      if (event['event'] == 'message.sent') {
        final message = ChatMessage.fromJson(payload['message'] as Map<String, dynamic>);
        if (!_messages.any((item) => item.id == message.id)) {
          _messages.add(message);
          notifyListeners();
        }
      }
    } catch (_) {
      // Ignore protocol frames that are not application events.
    }
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    _channel?.sink.close();
    super.dispose();
  }
}
