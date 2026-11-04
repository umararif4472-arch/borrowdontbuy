/// A single chat message. Three kinds of thread exist:
///
/// - **Request threads** — [requestId] is set; the chat attached to a
///   borrow request (pickup, return, and so on).
/// - **Item threads** — [itemId] is set and [requestId] is null; a
///   neighbor asking the owner about a listing before requesting it.
/// - **User threads** — both are null; a general chat between two
///   neighbors, opened from a profile.
///
/// For item and user threads, [otherUserId] records the participant who
/// is *not* the sender, so the pair (sender, other) identifies the
/// thread from any single message.
class Message {
  final String id;
  final String? requestId;
  final String? itemId;
  final String? otherUserId;
  final String senderId;
  final String body;
  final DateTime createdAt;
  const Message({
    required this.id,
    this.requestId,
    this.itemId,
    this.otherUserId,
    required this.senderId,
    required this.body,
    required this.createdAt,
  });
}
