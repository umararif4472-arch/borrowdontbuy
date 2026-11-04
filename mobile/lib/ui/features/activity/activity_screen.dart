import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../data/models/borrow_request.dart';
import '../../../state/app_state.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Activity',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Borrowing'),
              Tab(text: 'Lending'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _RequestList(isLending: false),
            _RequestList(isLending: true),
          ],
        ),
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  final bool isLending;
  const _RequestList({required this.isLending});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final list = isLending ? state.incomingRequests : state.outgoingRequests;
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            isLending
                ? 'No lending activity yet. When neighbors request your items, they will show up here.'
                : 'No borrowing activity yet. Request an item from Explore to get started.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemCount: list.length,
      itemBuilder: (context, i) =>
          _RequestCard(request: list[i], isLending: isLending),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final BorrowRequest request;
  final bool isLending;
  const _RequestCard({required this.request, required this.isLending});
  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final watched = context.watch<AppState>();
    final item = watched.itemById(request.itemId);
    final other = isLending
        ? watched.userById(request.borrowerId)
        : watched.userById(item.ownerId);
    final overdue = request.isOverdue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoryTile(category: item.category, size: 48),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${isLending ? 'Borrower' : 'Owner'}: ${other.name}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  StatusChip(status: request.status, isOverdue: overdue),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${dateRangeLabel(request.period.start, request.period.end)} · ${dueLabel(request.period.end)}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: overdue ? AppColors.errorRed : AppColors.bark,
                ),
              ),
              if (request.note.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '“${request.note}”',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              if (request.status == 'returned')
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: AppColors.moss),
                      SizedBox(width: 6),
                      Text(
                        'Completed — item returned',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.mossDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ..._actions(context, state),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _actions(BuildContext context, AppState state) {
    final widgets = <Widget>[];
    if (isLending && request.status == 'pending') {
      widgets.add(const SizedBox(height: 12));
      widgets.add(
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  state.approveRequest(request.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Approved — borrower can pick up.'),
                    ),
                  );
                },
                child: const Text('Approve'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  state.declineRequest(request.id);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Declined.')));
                },
                child: const Text('Decline'),
              ),
            ),
          ],
        ),
      );
    }
    if (request.status == 'approved') {
      widgets.add(const SizedBox(height: 12));
      widgets.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              state.markPickedUp(request.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Marked as picked up — borrow is now active.'),
                ),
              );
            },
            child: const Text('Mark picked up'),
          ),
        ),
      );
    }
    if (request.status == 'active') {
      widgets.add(const SizedBox(height: 12));
      widgets.add(
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  state.markReturned(request.id, onTime: true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Returned on time — trust updated.'),
                    ),
                  );
                },
                child: const Text('Returned on-time'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  state.markReturned(request.id, onTime: false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Marked late — borrower trust reflects it.',
                      ),
                    ),
                  );
                },
                child: const Text('Returned late'),
              ),
            ),
          ],
        ),
      );
    }
    return widgets;
  }
}
