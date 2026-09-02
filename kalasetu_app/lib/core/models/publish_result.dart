class PublishResult {
  final bool success;
  final String? ondcListingId;
  final String? errorMessage;

  const PublishResult({
    required this.success,
    this.ondcListingId,
    this.errorMessage,
  });
}
