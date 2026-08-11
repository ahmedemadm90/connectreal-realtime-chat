class ChatUser {
  const ChatUser({required this.id, required this.name, this.avatarUrl, this.lastSeenAt});

  final int id;
  final String name;
  final String? avatarUrl;
  final DateTime? lastSeenAt;

  factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
        id: int.tryParse(json['id'].toString()) ?? 0,
        name: json['name'] as String? ?? 'Unknown user',
        avatarUrl: json['avatar_url'] as String?,
        lastSeenAt: DateTime.tryParse(json['last_seen_at']?.toString() ?? ''),
      );
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.body,
    required this.sender,
    required this.createdAt,
    this.messageType = 'text',
    this.editedAt,
    this.replyTo,
    this.isPending = false,
  });

  final int id;
  final int conversationId;
  final String body;
  final ChatUser sender;
  final DateTime createdAt;
  final String messageType;
  final DateTime? editedAt;
  final ChatMessage? replyTo;
  final bool isPending;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final senderJson = (json['sender'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final replyJson = json['reply_to'] as Map<String, dynamic>?;
    return ChatMessage(
      id: int.tryParse(json['id'].toString()) ?? 0,
      conversationId: int.tryParse(json['conversation_id'].toString()) ?? 0,
      body: json['body'] as String? ?? '',
      sender: ChatUser.fromJson(senderJson),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      messageType: json['message_type'] as String? ?? 'text',
      editedAt: DateTime.tryParse(json['edited_at']?.toString() ?? ''),
      replyTo: replyJson == null ? null : ChatMessage.fromJson(replyJson),
    );
  }
}

class Conversation {
  const Conversation({required this.id, required this.title, required this.type, required this.members, this.lastMessage});

  final int id;
  final String title;
  final String type;
  final List<ChatUser> members;
  final ChatMessage? lastMessage;

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'] as List<dynamic>? ?? [];
    final rawMessages = json['messages'] as List<dynamic>? ?? [];
    return Conversation(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] as String? ?? 'Conversation',
      type: json['type'] as String? ?? 'direct',
      members: rawMembers.map((item) => ChatUser.fromJson(item as Map<String, dynamic>)).toList(),
      lastMessage: rawMessages.isEmpty ? null : ChatMessage.fromJson(rawMessages.first as Map<String, dynamic>),
    );
  }
}
