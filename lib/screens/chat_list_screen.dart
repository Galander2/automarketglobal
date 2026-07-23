import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/router/app_routes.dart';
import '../models/chat_thread.dart';
import '../repositories/auth_repository.dart';
import '../repositories/chat_repository.dart';

class ChatListScreen extends StatelessWidget {
  final ChatRepository? repository;

  const ChatListScreen({super.key, this.repository});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) {
      return const Scaffold(
        appBar: AppBar(title: Text('Сообщения')),
        body: Center(child: Text('Войдите в аккаунт, чтобы открыть сообщения')),
      );
    }

    final chatRepository = repository ?? ChatRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('Сообщения')),
      body: StreamBuilder<List<ChatThread>>(
        stream: chatRepository.watchChats(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ChatError(
              message: 'Не удалось загрузить диалоги',
              onRetry: () => (context as Element).markNeedsBuild(),
            );
          }

          final chats = snapshot.data ?? const <ChatThread>[];
          if (chats.isEmpty) {
            return const _EmptyChats();
          }

          return RefreshIndicator(
            onRefresh: () async => (context as Element).markNeedsBuild(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: chats.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final thread = chats[index];
                final unread = thread.unreadFor(user.uid);
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: _ChatImage(url: thread.carImageUrl),
                    title: Text(
                      thread.carTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight:
                            unread > 0 ? FontWeight.w900 : FontWeight.w700,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        thread.lastMessage.isEmpty
                            ? 'Начните переписку'
                            : thread.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: unread > 0
                        ? CircleAvatar(
                            radius: 13,
                            backgroundColor: const Color(0xFF2563EB),
                            child: Text(
                              unread > 99 ? '99+' : '$unread',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.chat,
                      arguments: {'thread': thread},
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ChatImage extends StatelessWidget {
  final String url;

  const _ChatImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const CircleAvatar(child: Icon(Icons.directions_car));
    }
    return CircleAvatar(
      backgroundColor: Colors.grey.shade200,
      backgroundImage: NetworkImage(url),
      onBackgroundImageError: (_, __) {},
      child: const SizedBox.shrink(),
    );
  }
}

class _EmptyChats extends StatelessWidget {
  const _EmptyChats();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.forum_outlined, size: 72, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Диалогов пока нет',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Откройте объявление и нажмите «Связаться»',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ChatError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Повторить')),
        ],
      ),
    );
  }
}
