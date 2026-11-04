import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../state/app_state.dart';
import 'chat_screen.dart';

/// Conversation list — one thread per borrow request you are part of.
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final convos = state.myConversations;
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: convos.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No conversations yet. When you request an item (or someone requests yours), your chat shows up here.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: convos.length,
              itemBuilder: (context, i) {
                final req = convos[i];
                final item = state.itemById(req.itemId);
                final other = state.otherPartyFor(req);
                final last = state.lastMessageFor(req.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: ListTile(
                      leading: UserAvatar(user: other, radius: 22),
                      title: Text(
                        other.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        last != null
                            ? '${item.title} — ${last.body}'
                            : '${item.title} — no messages yet',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StatusChip(
                            status: req.status,
                            isOverdue: req.isOverdue,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            shortDate((last?.createdAt ?? req.createdAt)),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(requestId: req.id),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
