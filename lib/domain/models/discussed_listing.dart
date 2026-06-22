/// A housing listing whose share card has been posted in a group conversation.
/// Powers the chat's "mentioned listings" quick-jump ribbon.
class DiscussedListing {
  const DiscussedListing({
    required this.listingId,
    required this.messageId,
    required this.title,
  });

  factory DiscussedListing.fromJson(Map<String, dynamic> json) {
    return DiscussedListing(
      listingId: (json["listing_id"] as num).toInt(),
      messageId: (json["message_id"] as num?)?.toInt() ?? 0,
      title: json["title"] as String? ?? "",
    );
  }

  final int listingId;
  final int messageId;
  final String title;
}
