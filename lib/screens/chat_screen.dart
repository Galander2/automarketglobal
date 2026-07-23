import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chat_thread.dart';
import '../repositories/auth_repository.dart';
import '../repositories/chat_repository.dart';

class ChatScreen extends StatefulWidget {
  final ChatThread thread;
  final ChatRepository? repository;

  const ChatScreen({super.key, required this.thread, this.repository});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late final ChatRepository _repository;
  bool _sending = false;
  bool _blockedByMe = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ChatRepository();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final uid = context.read<AuthProvider>().currentUser?.uid;
      if (uid == null) return;
      setState(() => _blockedByMe = widget.thread.isBlockedBy(uid));
      _repository.markRead(widget.thread).catchError((_) {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending) return;
    final text = _controller.text;
    setState(() => _sending = true);
    try {
      await _repository.sendMessage(widget.thread, text);
      _controller.clear();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _toggleBlock() async {
    final nextValue = !_blockedByMe;
    try {
      await _repository.setBlocked(widget.thread, blocked: nextValue);
      if (!mounted) return;
      setState(() => _blockedByMe = nextValue);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nextValue ? 'Пользователь заблокирован' : 'Блокировка снята',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Войдите в аккаунт, чтобы продолжить')),
      );
    }
    final blocked = _blockedByMe || widget.thread.blockedBy.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.thread.carTitle, overflow: TextOverflow.ellipsis),
            Text(
              uid == widget.thread.buyerId ? 'Продавец' : 'Покупатель',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (_) => _toggleBlock(),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'block',
                child: Text(
                  _blockedByMe ? 'Разблокировать' : 'Заблокировать',
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _repository.watchMessages(widget.thread.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Не удалось загрузить сообщения'),
                  );
                }
                final messages = snapshot.data ?? const <ChatMessage>[];
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('Напишите первое сообщение продавцу'),
                  );
                }
                _repository.markRead(widget.thread).catchError((_) {});
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _MessageBubble(
                      message: message,
                      mine: message.senderId == uid,
                    );
                  },
                );
              },
            ),
          ),
          if (blocked)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              color: Colors.orange.withValues(alpha: 0.12),
              child: const Text(
                'Отправка сообщений заблокирована',
                textAlign: TextAlign.center,
              ),
            )
          else
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 5,
                        maxLength: ChatRepository.maxMessageLength,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Сообщение',
                          counterText: '',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _sending ? null : _send,
                      icon: _sending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool mine;

  const _MessageBubble({required this.message, required this.mine});

  @override
  Widget build(BuildContext context) {
    final time = message.sentAt;
    final timeText = time == null
        ? ''
        : '${time.hour.toString().padLeft(2, '0')}:'
              '${time.minute.toString().padLeft(2, '0')}';
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(14, 10, 10, 6),
        decoration: BoxDecoration(
          color: mine
              ? const Color(0xFF2563EB)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: TextStyle(color: mine ? Colors.white : null, fontSize: 16),
            ),
            if (timeText.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                timeText,
                style: TextStyle(
                  color: mine ? Colors.white70 : Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
