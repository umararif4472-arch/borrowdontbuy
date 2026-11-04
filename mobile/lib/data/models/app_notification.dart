/// A notification derived live from request state (see AppState).
class DerivedNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final DateTime createdAt;
  final String? requestId;
  final String? itemId;

  /// 'action' items need the user's attention; 'info' items do not.
  final String kind;
  const DerivedNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.requestId,
    this.itemId,
    this.kind = 'info',
  });
}
