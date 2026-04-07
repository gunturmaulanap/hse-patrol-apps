import 'package:dio/dio.dart';

/// Standard API response validator
class ApiResponse {
  /// Validate and normalize API response
  static Response validate(Response response) {
    // Check if response is successful
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      return response;
    }

    // Return error response as-is for error handling
    return response;
  }

  /// Extract data from response
  static dynamic extractData(Response response) {
    final data = response.data;

    if (data is Map<String, dynamic>) {
      // Try common data wrapper keys
      final wrappedData = data['data'] ?? data['results'] ?? data['items'];
      if (wrappedData != null) {
        return wrappedData;
      }
      return data;
    }

    return data;
  }

  /// Extract list from response
  static List<T> extractList<T>(Response response, T Function(dynamic) converter) {
    final data = extractData(response);

    if (data is List) {
      return data.map(converter).toList();
    }

    if (data is Map<String, dynamic>) {
      final items = data['data'] ?? data['results'] ?? data['items'];
      if (items is List) {
        return items.map(converter).toList();
      }
    }

    return [];
  }

  /// Extract pagination info
  static Map<String, int>? extractPagination(Response response) {
    final data = response.data;

    if (data is Map<String, dynamic>) {
      final pagination = data['pagination'] ?? data['meta'];
      if (pagination is Map<String, dynamic>) {
        return {
          'currentPage': pagination['current_page'] ?? pagination['currentPage'] ?? 1,
          'lastPage': pagination['last_page'] ?? pagination['lastPage'] ?? 1,
          'perPage': pagination['per_page'] ?? pagination['perPage'] ?? 10,
          'total': pagination['total'] ?? 0,
        };
      }

      // Try direct keys
      if (data.containsKey('current_page') || data.containsKey('last_page')) {
        return {
          'currentPage': data['current_page'] ?? 1,
          'lastPage': data['last_page'] ?? 1,
          'perPage': data['per_page'] ?? 10,
          'total': data['total'] ?? 0,
        };
      }
    }

    return null;
  }

  /// Check if response is successful
  static bool isSuccess(Response response) {
    return response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300;
  }

  /// Check if response has error
  static bool isError(Response response) {
    return !isSuccess(response);
  }
}
