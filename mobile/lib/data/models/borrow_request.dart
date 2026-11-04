class BorrowPeriod {
  final DateTime start;
  final DateTime end;
  const BorrowPeriod({required this.start, required this.end});
}

class BorrowRequest {
  final String id;
  final String itemId;
  final String borrowerId;
  final BorrowPeriod period;
  final String note;
  final String
  status; // pending, approved, active, returned, reviewed, declined, cancelled
  final DateTime createdAt;
  final DateTime? respondedAt;
  final DateTime? dueAt;
  final DateTime? returnedAt;
  const BorrowRequest({
    required this.id,
    required this.itemId,
    required this.borrowerId,
    required this.period,
    required this.note,
    required this.status,
    required this.createdAt,
    this.respondedAt,
    this.dueAt,
    this.returnedAt,
  });
  bool get isOverdue {
    if (status != 'active' || dueAt == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueAt!.year, dueAt!.month, dueAt!.day);
    return due.isBefore(today);
  }

  BorrowRequest copyWith({
    String? status,
    DateTime? respondedAt,
    DateTime? dueAt,
    DateTime? returnedAt,
  }) {
    return BorrowRequest(
      id: id,
      itemId: itemId,
      borrowerId: borrowerId,
      period: period,
      note: note,
      status: status ?? this.status,
      createdAt: createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      dueAt: dueAt ?? this.dueAt,
      returnedAt: returnedAt ?? this.returnedAt,
    );
  }
}
