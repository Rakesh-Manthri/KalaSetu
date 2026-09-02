enum ListingStatus {
  draft,
  processing,
  pendingApproval,
  published;

  String get displayName {
    switch (this) {
      case ListingStatus.draft:
        return 'Draft';
      case ListingStatus.processing:
        return 'Processing';
      case ListingStatus.pendingApproval:
        return 'Pending Approval';
      case ListingStatus.published:
        return 'Published';
    }
  }
}
