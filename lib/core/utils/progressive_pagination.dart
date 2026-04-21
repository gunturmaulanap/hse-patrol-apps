/// Progressive pagination utility
/// Implements exponential growth: 5 → 10 → 20 → 40 → ...
class ProgressivePagination {
  /// Get next visible count based on current count
  static int getNextVisibleCount(int currentCount) {
    if (currentCount == 0) return 5;       // Initial: show 5
    if (currentCount <= 5) return 10;      // Step 1: 5 → 10
    if (currentCount <= 10) return 20;     // Step 2: 10 → 20
    return currentCount * 2;               // Subsequent: x2
  }

  /// Get per_page and current_page for API request
  static PaginationParams getPaginationParams(int visibleCount) {
    int perPage;
    int currentPage;

    if (visibleCount == 0) {
      // Initial load
      perPage = 5;
      currentPage = 1;
    } else if (visibleCount <= 5) {
      // 5 → 10: request page 1 with per_page=10
      perPage = 10;
      currentPage = 1;
    } else if (visibleCount <= 10) {
      // 10 → 20: request page 1 with per_page=20
      perPage = 20;
      currentPage = 1;
    } else {
      // 20 → 40, 40 → 80, etc.
      // Use exponential: load up to next milestone
      final nextCount = visibleCount * 2;
      perPage = nextCount;
      currentPage = 1;
    }

    return PaginationParams(perPage: perPage, currentPage: currentPage);
  }

  /// Calculate button text
  static String getButtonText(int visibleCount, int totalCount) {
    final nextCount = getNextVisibleCount(visibleCount);
    final remaining = totalCount - visibleCount;
    final toShow = (nextCount - visibleCount).clamp(0, remaining);

    if (remaining <= 0) return 'Semua Laporan Ditampilkan';

    if (toShow >= remaining) {
      return 'Tampilkan Semua ($remaining sisa)';
    }

    return 'Tampilkan $toShow Laporan Lainnya';
  }

  /// Check if has more to show
  static bool hasMore(int visibleCount, int totalCount) {
    return visibleCount < totalCount;
  }
}

class PaginationParams {
  final int perPage;
  final int currentPage;

  const PaginationParams({
    required this.perPage,
    required this.currentPage,
  });

  @override
  String toString() => 'PaginationParams(perPage: $perPage, currentPage: $currentPage)';
}
