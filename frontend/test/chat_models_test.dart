import 'package:flutter_test/flutter_test.dart';
import 'package:connectreal_mobile/models/chat_models.dart';

void main() {
  test('parses message sender and reply metadata from API JSON', () {
    final message = ChatMessage.fromJson({
      'id': 10,
      'conversation_id': 3,
      'body': 'Hello live room',
      'message_type': 'text',
      'created_at': '2026-08-11T19:00:00Z',
      'sender': {'id': 1, 'name': 'Ahmed Emad'},
      'reply_to': {
        'id': 9,
        'conversation_id': 3,
        'body': 'Earlier message',
        'created_at': '2026-08-11T18:59:00Z',
        'sender': {'id': 2, 'name': 'Sara Hassan'},
      },
    });

    expect(message.body, 'Hello live room');
    expect(message.sender.name, 'Ahmed Emad');
    expect(message.replyTo?.sender.name, 'Sara Hassan');
  });

  test('parses conversation members and recent message', () {
    final conversation = Conversation.fromJson({
      'id': 3,
      'title': 'Product Launch Room',
      'type': 'group',
      'members': [
        {'id': 1, 'name': 'Ahmed Emad'},
        {'id': 2, 'name': 'Sara Hassan'},
      ],
      'messages': [
        {
          'id': 10,
          'conversation_id': 3,
          'body': 'Latest update',
          'created_at': '2026-08-11T19:00:00Z',
          'sender': {'id': 1, 'name': 'Ahmed Emad'},
        },
      ],
    });

    expect(conversation.title, 'Product Launch Room');
    expect(conversation.members.length, 2);
    expect(conversation.lastMessage?.body, 'Latest update');
  });
}
