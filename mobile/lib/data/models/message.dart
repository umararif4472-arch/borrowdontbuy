/// A single chat message in the thread attached to a borrow request.
class Message {
  final String id;
  final String requestId;
  final String senderId;
  final String body;
  final DateTime createdAt;
  const Message({
    required this.id,
    required this.requestId,
    required this.senderId,
    required this.body,
    required this.createdAt,
  });
}
