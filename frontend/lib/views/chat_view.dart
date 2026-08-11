import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/chat_models.dart';
import '../providers/chat_provider.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _composerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<ChatProvider>().connectDemo());
  }

  @override
  void dispose() {
    _composerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();
    final active = provider.activeConversationId;
    final matchingConversations = provider.conversations.where((item) => item.id == active);
    final conversation = matchingConversations.isEmpty ? null : matchingConversations.first;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        titleSpacing: 20,
        title: Row(children: [
          const CircleAvatar(backgroundColor: Color(0xFF5A61E8), child: Icon(Icons.forum_rounded, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(conversation?.title ?? 'ConnectReal', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            Text(conversation == null ? 'Connecting...' : '${conversation.members.length} participants', style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ])),
          IconButton(onPressed: provider.connectDemo, icon: const Icon(Icons.refresh_rounded)),
        ]),
      ),
      drawer: _ConversationDrawer(provider: provider),
      body: Column(children: [
        if (provider.error != null) _ErrorBanner(message: provider.error!),
        Expanded(child: provider.isLoading && provider.messages.isEmpty ? const Center(child: CircularProgressIndicator()) : _MessageList(provider: provider)),
        _Composer(controller: _composerController, isSending: provider.isSending, onSend: _sendMessage),
      ]),
    );
  }

  Future<void> _sendMessage() async {
    final text = _composerController.text;
    if (text.trim().isEmpty) return;
    _composerController.clear();
    await context.read<ChatProvider>().sendMessage(text);
  }
}

class _ConversationDrawer extends StatelessWidget {
  const _ConversationDrawer({required this.provider});
  final ChatProvider provider;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(padding: EdgeInsets.fromLTRB(20, 24, 20, 8), child: Text('Your conversations', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('Private channels are authorized by Laravel Sanctum.', style: TextStyle(color: Colors.black54, height: 1.4))),
        const SizedBox(height: 16),
        Expanded(child: ListView.builder(
          itemCount: provider.conversations.length,
          itemBuilder: (context, index) {
            final conversation = provider.conversations[index];
            final selected = conversation.id == provider.activeConversationId;
            return ListTile(
              selected: selected,
              selectedTileColor: const Color(0xFFE8E9FF),
              leading: CircleAvatar(backgroundColor: selected ? const Color(0xFF5A61E8) : Colors.black12, child: Icon(Icons.groups_rounded, color: selected ? Colors.white : Colors.black54)),
              title: Text(conversation.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(conversation.lastMessage?.body ?? 'No messages yet', maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () {
                Navigator.pop(context);
                provider.openConversation(conversation.id);
              },
            );
          },
        )),
      ])),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.provider});
  final ChatProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.messages.isEmpty) {
      return const Center(child: Text('Start the conversation.', style: TextStyle(color: Colors.black54)));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      itemCount: provider.messages.length,
      itemBuilder: (context, index) {
        final message = provider.messages[index];
        final mine = message.sender.id == provider.currentUserId;
        return _MessageBubble(message: message, mine: mine);
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.mine});
  final ChatMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = mine ? const Color(0xFF565CE7) : Colors.white;
    final textColor = mine ? Colors.white : const Color(0xFF202133);
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 330),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.fromLTRB(14, 11, 14, 9),
        decoration: BoxDecoration(color: bubbleColor, borderRadius: BorderRadius.only(topLeft: const Radius.circular(18), topRight: const Radius.circular(18), bottomLeft: Radius.circular(mine ? 18 : 4), bottomRight: Radius.circular(mine ? 4 : 18)), boxShadow: mine ? null : const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 3))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!mine) Text(message.sender.name, style: const TextStyle(color: Color(0xFF565CE7), fontWeight: FontWeight.w800, fontSize: 12)),
          if (!mine) const SizedBox(height: 4),
          Text(message.body, style: TextStyle(color: textColor, fontSize: 15, height: 1.35)),
          const SizedBox(height: 5),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Text(DateFormat('HH:mm').format(message.createdAt.toLocal()), style: TextStyle(color: mine ? Colors.white70 : Colors.black45, fontSize: 10)),
            if (message.editedAt != null) ...[const SizedBox(width: 5), Text('edited', style: TextStyle(color: Colors.white70, fontSize: 10))],
          ]),
        ]),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.isSending, required this.onSend});
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0x11000000)))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF5A61E8))),
        Expanded(child: TextField(controller: controller, minLines: 1, maxLines: 4, textInputAction: TextInputAction.newline, decoration: InputDecoration(hintText: 'Write a message...', filled: true, fillColor: const Color(0xFFF4F5FA), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)))),
        const SizedBox(width: 8),
        IconButton.filled(onPressed: isSending ? null : onSend, icon: isSending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send_rounded)),
      ]),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(width: double.infinity, color: const Color(0xFFFFE8E8), padding: const EdgeInsets.all(10), child: Text(message, style: const TextStyle(color: Color(0xFF9B2525)), maxLines: 2, overflow: TextOverflow.ellipsis));
}
