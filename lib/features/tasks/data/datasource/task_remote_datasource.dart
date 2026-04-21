import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../../../app/env/app_env.dart';
import '../models/hse_task_model.dart';
import '../models/create_hse_task_request.dart';
import '../models/hse_staff_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<HseTaskModel>> fetchTasks({int? areaId, String? status});
  Future<List<HseTaskModel>> fetchTasksPaginated({
    int? areaId,
    String? status,
    required int perPage,
    required int currentPage,
  });
  Future<HseTaskModel> getTaskById(int id);
  Future<HseTaskModel> getTaskByPicToken(String picToken);
  Future<Map<String, dynamic>> validatePicToken(String picToken);
  Future<HseTaskModel> createTask(
      CreateHseTaskRequest request, List<File>? photos);
  Future<HseTaskModel> updateTask(int id, CreateHseTaskRequest request,
      {List<File>? photos, String? mode});
  Future<HseTaskModel> cancelTask(int id, String canceledBy);
  Future<List<HseStaffModel>> fetchStaffs();
  Future<List<HseStaffModel>> fetchPicUsers();
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio _dio = DioClient.instance;
  static const String _picTokenEndpoint = '/hse-reports/pic';

  @override
  Future<List<HseTaskModel>> fetchTasks({int? areaId, String? status}) async {
    // Backend limit: max 100 per page
    // Loop through all pages to get all tasks
    return await fetchTasksPaginated(
      areaId: areaId,
      status: status,
      perPage: 100, // Backend max limit
      currentPage: 1,
    );
  }

  @override
  Future<List<HseTaskModel>> fetchTasksPaginated({
    int? areaId,
    String? status,
    required int perPage,
    required int currentPage,
  }) async {
    try {
      List<HseTaskModel> allTasks = [];
      int requestedPage = currentPage;
      int totalPages = 1;
      int requestedPerPage = perPage;
      int maxPages = AppEnv.maxPaginationPages;
      bool reachedMaxPagesGuard = false;

      do {
        final queryParams = <String, dynamic>{
          'page': requestedPage,
          'per_page': requestedPerPage,
        };
        if (areaId != null) queryParams['area_id'] = areaId;
        if (status != null) queryParams['status'] = status;

        log.info('Fetching tasks', data: {'page': requestedPage, 'per_page': requestedPerPage}, tag: 'TaskRemoteDataSource');

        final response = await _dio.get(
          '/hse-reports',
          queryParameters: queryParams,
        );

        // Parse response
        final responseData = response.data;
        List<dynamic> data = [];

        if (responseData is Map) {
          final map = responseData as Map<String, dynamic>;
          data = _extractListData(map);

          final nested = map['data'];
          final pageMeta = nested is Map
              ? Map<String, dynamic>.from(nested)
              : map;

          final nestedPagination = pageMeta['pagination'] is Map
              ? Map<String, dynamic>.from(pageMeta['pagination'] as Map)
              : <String, dynamic>{};
          final rootPagination = map['pagination'] is Map
              ? Map<String, dynamic>.from(map['pagination'] as Map)
              : <String, dynamic>{};

          // Cek pagination info
          final totalRaw = pageMeta['total'] ??
              nestedPagination['total'] ??
              rootPagination['total'];
          final perPageRaw = pageMeta['per_page'] ??
              nestedPagination['per_page'] ??
              rootPagination['per_page'];

          if (totalRaw != null) {
            final total = totalRaw is int
                ? totalRaw
                : int.tryParse(totalRaw.toString()) ?? 0;
            final receivedPerPage = perPageRaw is int
                ? perPageRaw
                : int.tryParse(perPageRaw?.toString() ?? '') ?? requestedPerPage;

            if (receivedPerPage > 0) {
              totalPages = (total / receivedPerPage).ceil();
            }
          } else if ((pageMeta['last_page'] ??
                  nestedPagination['last_page'] ??
                  rootPagination['last_page']) !=
              null) {
            final lastPageRaw = pageMeta['last_page'] ??
                nestedPagination['last_page'] ??
                rootPagination['last_page'];
            totalPages = lastPageRaw is int
                ? lastPageRaw
                : int.tryParse(lastPageRaw?.toString() ?? '') ?? 1;
          } else if ((pageMeta['total_pages'] ??
                  nestedPagination['total_pages'] ??
                  rootPagination['total_pages']) !=
              null) {
            final totalPagesRaw = pageMeta['total_pages'] ??
                nestedPagination['total_pages'] ??
                rootPagination['total_pages'];
            totalPages = totalPagesRaw is int
                ? totalPagesRaw
                : int.tryParse(totalPagesRaw?.toString() ?? '') ?? 1;
          }

          final currentPageRaw = pageMeta['current_page'] ??
              nestedPagination['current_page'] ??
              rootPagination['current_page'];
          final lastPageRaw = pageMeta['last_page'] ??
              nestedPagination['last_page'] ??
              rootPagination['last_page'];

          final currentPageFromApi = currentPageRaw is int
              ? currentPageRaw
              : int.tryParse(currentPageRaw?.toString() ?? '');
          final lastPageFromApi = lastPageRaw is int
              ? lastPageRaw
              : int.tryParse(lastPageRaw?.toString() ?? '');
          if (lastPageFromApi != null && lastPageFromApi > totalPages) {
            totalPages = lastPageFromApi;
          }

          log.info('Page info', data: {
            'requested_page': requestedPage,
            'current_page_api': currentPageFromApi,
            'last_page_api': lastPageFromApi,
            'total_pages_api': pageMeta['total_pages'],
            'total_api': pageMeta['total'],
            'per_page_api': pageMeta['per_page'],
            'reports_count': data.length,
            'calculated_total_pages': totalPages,
          }, tag: 'TaskRemoteDataSource');

          final totalApiText = pageMeta['total']?.toString() ?? '-';
          log.info(
            'Pagination summary',
            data: {
              'page': requestedPage,
              'reports': data.length,
              'total_api': totalApiText,
              'total_pages': totalPages,
            },
            tag: 'TaskRemoteDataSource',
          );
        }

        // Parse tasks (defensive cast)
        final pageTasks = data
            .map((json) => _toMapOrNull(json))
            .whereType<Map<String, dynamic>>()
            .map(_parseReportModel)
            .toList();
        allTasks.addAll(pageTasks);

        log.info(
          'Page date distribution',
          data: {
            'page': requestedPage,
            'date_buckets': _buildDateBucketsFromModels(pageTasks),
          },
          tag: 'TaskRemoteDataSource',
        );

        // Fallback pagination strategy:
        // jika metadata total/last_page tidak dikirim backend,
        // lanjutkan ke halaman berikut selama halaman saat ini "penuh".
        // Ini mencegah berhenti di page 1 saat data sebenarnya masih ada.
        if (pageTasks.length >= requestedPerPage && requestedPage >= totalPages) {
          totalPages = requestedPage + 1;
        }

        log.info('Page fetched', data: {
          'page': requestedPage,
          'count': pageTasks.length,
          'total_so_far': allTasks.length
        }, tag: 'TaskRemoteDataSource');

        requestedPage++;
        if (requestedPage > maxPages && requestedPage <= totalPages) {
          reachedMaxPagesGuard = true;
        }
      } while (requestedPage <= totalPages && requestedPage <= maxPages);

      if (reachedMaxPagesGuard) {
        log.warning(
          'Pagination stopped by maxPages safety guard (partial data possible)',
          data: {
            'max_pages': maxPages,
            'next_page': requestedPage,
            'total_pages': totalPages,
            'fetched_items': allTasks.length,
          },
          tag: 'TaskRemoteDataSource',
        );
      }

      log.info(
        'All pages date distribution',
        data: {
          'total_items': allTasks.length,
          'date_buckets': _buildDateBucketsFromModels(allTasks),
        },
        tag: 'TaskRemoteDataSource',
      );

      log.info('All tasks fetched successfully', data: {'total': allTasks.length}, tag: 'TaskRemoteDataSource');
      return allTasks;
    } catch (e) {
      log.error('Error fetching tasks', error: e, tag: 'TaskRemoteDataSource');
      throw ErrorHandler.handleException(e);
    }
  }

  @override
  Future<HseTaskModel> getTaskById(int id) async {
    try {
      log.info('Fetching task by ID', data: {'id': id}, tag: 'TaskRemoteDataSource');

      final response = await _dio.get('/hse-reports/$id');
      final data = response.data is Map
          ? (response.data['data'] as Map<String, dynamic>?)
          : (response.data as Map<String, dynamic>?);

      if (data == null) {
        throw ErrorHandler.handleException(
          BusinessException.taskNotFound(),
        );
      }

      return _parseReportModel(data);
    } catch (e) {
      log.error('Error fetching task by ID', error: e, tag: 'TaskRemoteDataSource');
      throw ErrorHandler.handleException(e);
    }
  }

  @override
  Future<HseTaskModel> getTaskByPicToken(String picToken) async {
    try {
      log.info('Fetching task by picToken', tag: 'TaskRemoteDataSource');

      // Step 1: Hit API /hse-reports/pic/{token}
      final validateResponse = await _dio.get('$_picTokenEndpoint/$picToken');

      final raw = validateResponse.data;
      final map = raw is Map<String, dynamic>
          ? raw
          : raw is Map
              ? Map<String, dynamic>.from(raw)
              : <String, dynamic>{};

      // Format baru backend: { token_valid, authorized, data: {...report...} }
      final tokenValid = _resolveBool(
            map['token_valid'] ?? map['valid'] ?? map['is_valid'],
          ) ??
          true;
      if (!tokenValid) {
        throw ErrorHandler.handleException(
          ValidationException.invalidInput(
            message: 'Token laporan tidak valid atau sudah kedaluwarsa.',
          ),
        );
      }

      final data = map['data'];
      if (data is Map<String, dynamic>) {
        log.debug(
          'Resolved report directly from picToken endpoint',
          data: {'id': data['id'], 'source': 'direct_data'},
          tag: 'TaskRemoteDataSource',
        );
        return _parseReportModel(data);
      }
      if (data is Map) {
        final report = Map<String, dynamic>.from(data);
        log.debug(
          'Resolved report directly from picToken endpoint',
          data: {'id': report['id'], 'source': 'direct_data'},
          tag: 'TaskRemoteDataSource',
        );
        return _parseReportModel(report);
      }

      // Format alternatif backend: object report langsung di root response
      final hasDirectReportId = map['id'] != null || map['report_id'] != null;
      if (hasDirectReportId) {
        log.debug(
          'Resolved report from root payload',
          data: {'id': map['id'] ?? map['report_id'], 'source': 'root_payload'},
          tag: 'TaskRemoteDataSource',
        );
        return _parseReportModel(map);
      }

      // Format lama backend: { status: success, redirect_to: ... }
      final redirectTo = map['redirect_to']?.toString();
      if (redirectTo == null || redirectTo.trim().isEmpty) {
        throw ErrorHandler.handleException(
          ValidationException.invalidInput(
            message: 'Token valid tetapi data laporan tidak ditemukan.',
          ),
        );
      }

      log.debug(
        'Got redirect URL from picToken endpoint',
        data: {'redirect_to': redirectTo},
        tag: 'TaskRemoteDataSource',
      );

      final uri = Uri.tryParse(redirectTo);
      if (uri == null || uri.pathSegments.isEmpty) {
        throw ErrorHandler.handleException(
          ValidationException.invalidInput(
            message: 'Format URL redirect tidak valid: $redirectTo',
          ),
        );
      }

      final idStr = uri.pathSegments.last;
      final int? id = int.tryParse(idStr);
      if (id == null) {
        throw ErrorHandler.handleException(
          ValidationException.invalidInput(
            message: 'Gagal mengekstrak ID laporan dari string: $idStr',
          ),
        );
      }

      log.debug('Extracted task ID from redirect URL', data: {'id': id, 'source': 'redirect_to'}, tag: 'TaskRemoteDataSource');
      return await getTaskById(id);
    } catch (e) {
      log.error('Error getting task by picToken', error: e, tag: 'TaskRemoteDataSource');
      throw ErrorHandler.handleException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> validatePicToken(String picToken) async {
    final endpoint = '$_picTokenEndpoint/$picToken';

    try {
      log.info('Validating picToken', data: {'token': picToken}, tag: 'TaskRemoteDataSource');

      final response = await _dio.get(endpoint);
      final raw = response.data;
      final map = raw is Map<String, dynamic>
          ? raw
          : raw is Map
              ? Map<String, dynamic>.from(raw)
              : <String, dynamic>{};

      final data = map['data'] is Map
          ? Map<String, dynamic>.from(map['data'] as Map)
          : map;

      final redirectTo =
          (data['redirect_to'] ?? map['redirect_to'])?.toString();
      final redirectedTaskId = _extractTaskIdFromRedirect(redirectTo);

      final tokenValid = _resolveBool(
            data['token_valid'] ??
                data['valid'] ??
                data['is_valid'] ??
                map['token_valid'] ??
                map['valid'] ??
                map['is_valid'],
          ) ??
          true;

      final authorized = _resolveBool(
            data['authorized'] ??
                data['is_authorized'] ??
                data['allowed'] ??
                map['authorized'] ??
                map['is_authorized'] ??
                map['allowed'],
          ) ??
          true;

      final result = <String, dynamic>{
        'tokenValid': tokenValid,
        'authorized': authorized,
        'taskId': data['task_id'] ??
            data['taskId'] ??
            data['id'] ??
            redirectedTaskId ??
            map['task_id'] ??
            map['taskId'] ??
            map['id'],
        'reportId': data['report_id'] ??
            data['reportId'] ??
            map['report_id'] ??
            map['reportId'],
        'areaId': data['area_id'] ??
            data['areaId'] ??
            map['area_id'] ??
            map['areaId'],
        'authorId': data['author_id'] ??
            data['authorId'] ??
            data['created_by'] ??
            data['createdBy'],
        'reason': data['reason'] ?? data['message'] ?? map['message'] ?? '',
        'raw': map,
      };

      log.debug('picToken validation result', data: {
        'tokenValid': result['tokenValid'],
        'authorized': result['authorized'],
        'taskId': result['taskId'],
      }, tag: 'TaskRemoteDataSource');

      return result;
    } on DioException catch (e) {
      final status = e.response?.statusCode ?? 0;
      final responseData = e.response?.data;
      final payload = responseData is Map
          ? Map<String, dynamic>.from(responseData as Map)
          : <String, dynamic>{};

      final redirectTo = payload['redirect_to']?.toString();
      final redirectedTaskId = _extractTaskIdFromRedirect(redirectTo);

      final tokenValid = status != 404;
      final authorized = status != 401 && status != 403;

      final result = <String, dynamic>{
        'tokenValid': tokenValid,
        'authorized': authorized,
        'taskId': payload['task_id'] ??
            payload['taskId'] ??
            payload['id'] ??
            redirectedTaskId,
        'reportId': payload['report_id'] ?? payload['reportId'],
        'areaId': payload['area_id'] ?? payload['areaId'],
        'authorId': payload['author_id'] ?? payload['authorId'],
        'reason': payload['message']?.toString() ?? e.message ?? '',
        'raw': payload,
      };

      log.debug('picToken validation from error', data: {
        'status': status,
        'tokenValid': result['tokenValid'],
        'authorized': result['authorized'],
      }, tag: 'TaskRemoteDataSource');

      return result;
    }
  }

  int? _extractTaskIdFromRedirect(String? redirectTo) {
    if (redirectTo == null || redirectTo.trim().isEmpty) return null;
    final uri = Uri.tryParse(redirectTo);
    if (uri == null || uri.pathSegments.isEmpty) return null;
    return int.tryParse(uri.pathSegments.last);
  }

  @override
  Future<HseTaskModel> createTask(
      CreateHseTaskRequest request, List<File>? photos) async {
    try {
      // Validate input sederhana
      if (request.title.trim().isEmpty) {
        throw Exception('Judul tidak boleh kosong');
      }
      if (request.areaId == null || request.areaId! <= 0) {
        throw Exception('Area ID tidak valid');
      }
      if (request.riskLevel.trim().isEmpty) {
        throw Exception('Risk level tidak boleh kosong');
      }
      if (request.rootCause.trim().isEmpty) {
        throw Exception('Root cause tidak boleh kosong');
      }
      if (request.notes.trim().isEmpty) {
        throw Exception('Notes tidak boleh kosong');
      }

      log.info('Creating task', data: {
        'title': request.title.trim(),
        'area_id': request.areaId,
        'risk_level': request.riskLevel,
      }, tag: 'TaskRemoteDataSource');

      final formData = FormData.fromMap({
        'title': request.title.trim(),
        'area_id': request.areaId,
        'risk_level': request.riskLevel.trim(),
        'root_cause': request.rootCause.trim(),
        'notes': request.notes.trim(),
      });

      // Upload photos with proper format
      if (photos != null && photos.isNotEmpty) {
        for (var i = 0; i < photos.length && i < AppEnv.maxPhotosPerTask; i++) {
          final file = await MultipartFile.fromFile(
            photos[i].path,
            filename: 'photo_${i + 1}.jpg',
          );
          formData.files.add(MapEntry('photos[$i]', file));
        }
      }

      final response = await _dio.post(
        '/hse-reports',
        data: formData,
      );

      final data = response.data is Map
          ? (response.data['data'] as Map<String, dynamic>?)
          : (response.data as Map<String, dynamic>?);

      if (data == null) {
        throw Exception('Failed to create report: ${response.data}');
      }

      log.info('Task created successfully', data: {'id': data['id']}, tag: 'TaskRemoteDataSource');

      return _parseReportModel(data);
    } catch (e) {
      log.error('Error creating task', error: e, tag: 'TaskRemoteDataSource');

      // Extract user-friendly error message for 422
      if (e is DioException && e.response?.statusCode == 422) {
        final responseData = e.response?.data;
        String errorMsg = 'Validasi data gagal.';

        if (responseData is Map<String, dynamic>) {
          errorMsg = responseData['message']?.toString() ?? errorMsg;
          final errors = responseData['errors'];

          if (errors is Map) {
            final errorDetail = StringBuffer('$errorMsg\n\n');
            errors.forEach((key, value) {
              if (value is List) {
                errorDetail.writeln('• ${value.join(", ")}');
              } else {
                errorDetail.writeln('• $value');
              }
            });
            // Lempar exception dengan pesan rapih yang akan dibaca oleh UI
            throw Exception(errorDetail.toString().trim());
          }
        }
        throw Exception(errorMsg);
      }

      // Re-throw generic exception for other errors
      if (e is Exception) rethrow;
      throw Exception('Gagal membuat laporan: ${e.toString()}');
    }
  }

  @override
  Future<HseTaskModel> updateTask(int id, CreateHseTaskRequest request,
      {List<File>? photos, String? mode}) async {
    try {
      log.info('Updating task', data: {'id': id, 'mode': mode}, tag: 'TaskRemoteDataSource');

      final formData = FormData.fromMap({
        if (mode != null) 'mode': mode,
        'area_id': request.areaId,
        'risk_level': request.riskLevel,
        'root_cause': request.rootCause,
        'notes': request.notes,
      });

      if (photos != null && photos.isNotEmpty) {
        for (var i = 0; i < photos.length && i < AppEnv.maxPhotosPerTask; i++) {
          final file = await MultipartFile.fromFile(
            photos[i].path,
            filename: 'photo_${i + 1}.jpg',
          );
          formData.files.add(MapEntry('photos[$i]', file));
        }
      }

      final response = await _dio.put(
        '/hse-reports/$id',
        data: formData,
      );

      final data = response.data is Map
          ? (response.data['data'] as Map<String, dynamic>?)
          : (response.data as Map<String, dynamic>?);

      if (data == null) {
        throw ErrorHandler.handleException(
          BusinessException.invalidOperation(
            message: 'Failed to update report',
          ),
        );
      }

      log.info('Task updated successfully', data: {'id': id}, tag: 'TaskRemoteDataSource');

      return _parseReportModel(data);
    } catch (e) {
      log.error('Error updating task', error: e, tag: 'TaskRemoteDataSource');
      throw ErrorHandler.handleException(e);
    }
  }

  @override
  Future<HseTaskModel> cancelTask(int id, String canceledBy) async {
    try {
      log.info('Canceling task', data: {'id': id, 'canceled_by': canceledBy}, tag: 'TaskRemoteDataSource');

      final response = await _dio.patch(
        '/hse-reports/$id',
        data: {
          'mode': 'cancel',
          'cancelled_by': canceledBy,
        },
      );

      final data = response.data is Map<String, dynamic>
          ? response.data['data']
          : response.data['data'];

      log.info('Task canceled successfully', data: {'id': id, 'canceled_by': canceledBy}, tag: 'TaskRemoteDataSource');

      return _parseReportModel(data);
    } catch (e) {
      log.error('Error canceling task', error: e, tag: 'TaskRemoteDataSource');
      throw ErrorHandler.handleException(e);
    }
  }

  @override
  Future<List<HseStaffModel>> fetchStaffs() async {
    try {
      log.info('Fetching staffs list', tag: 'TaskRemoteDataSource');

      final response = await _dio.get('/hse/staffs');

      final List<dynamic> data = _extractListData(response.data);

      final staffs = data.map((json) {
        return HseStaffModel.fromJson(json as Map<String, dynamic>);
      }).toList();

      log.info('Staffs fetched successfully', data: {'count': staffs.length}, tag: 'TaskRemoteDataSource');

      return staffs;
    } catch (e) {
      log.error('Error fetching staffs', error: e, tag: 'TaskRemoteDataSource');
      throw ErrorHandler.handleException(e);
    }
  }

  @override
  Future<List<HseStaffModel>> fetchPicUsers() async {
    try {
      log.info('Fetching PIC users list', tag: 'TaskRemoteDataSource');

      final response = await _dio.get('/hse/pic-users');

      final responseData = response.data;
      List<dynamic> users = [];

      if (responseData is Map) {
        final map = responseData as Map<String, dynamic>;
        users = map['users'] as List<dynamic>? ??
                 map['data'] as List<dynamic>? ??
                 _extractListData(responseData);
      } else if (responseData is List) {
        users = responseData;
      }

      final picUsers = users.map((json) {
        return HseStaffModel.fromJson(json as Map<String, dynamic>);
      }).toList();

      log.info('PIC users fetched successfully', data: {'count': picUsers.length}, tag: 'TaskRemoteDataSource');

      return picUsers;
    } catch (e) {
      log.error('Error fetching PIC users', error: e, tag: 'TaskRemoteDataSource');
      throw ErrorHandler.handleException(e);
    }
  }

  HseTaskModel _parseReportModel(Map<String, dynamic> json) {
    final title = json['title']?.toString().trim().isNotEmpty == true
        ? json['title']?.toString().trim()
        : json['name']?.toString().trim();

    final parsedPhotos = _parsePhotos(json['photos']);

      return HseTaskModel(
      id: _toInt(json['id']),
      code: json['code']?.toString() ?? '',
      userId: _toInt(json['user_id'] ??
          json['userId'] ??
          json['author_id'] ??
          json['authorId'] ??
          json['created_by_id'] ??
          json['createdById'] ??
          json['created_by'] ??
          json['createdBy']),
      areaId: _toInt(json['area_id'] ?? json['areaId']),
      name: title,
      riskLevel:
          json['risk_level']?.toString() ?? json['riskLevel']?.toString() ?? '',
      rootCause:
          json['root_cause']?.toString() ?? json['rootCause']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      picToken: json['pic_token']?.toString() ?? json['picToken']?.toString(),
      photos: parsedPhotos,
      followUps: _parseFollowUps(json['follow_ups'])
          .followedBy(_parseFollowUps(json['followUps']))
          .toList(),
      date: json['date']?.toString() ?? json['created_at']?.toString(),
      userName: json['user']?.toString() ??
          json['created_by']?.toString() ??
          json['user_name']?.toString() ??
          json['username']?.toString(),
    );
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool? _resolveBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    if (normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes' ||
        normalized == 'valid' ||
        normalized == 'authorized') {
      return true;
    }
    if (normalized == 'false' ||
        normalized == '0' ||
        normalized == 'no' ||
        normalized == 'invalid' ||
        normalized == 'unauthorized') {
      return false;
    }
    return null;
  }

  List<String> _parsePhotos(dynamic raw) {
    if (raw is List) {
      return raw
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (raw is Map) {
      return raw.values
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return <String>[];
  }

  List<Map<String, dynamic>> _parseFollowUps(dynamic raw) {
    if (raw is! List) return <Map<String, dynamic>>[];
    return raw
        .map(_toMapOrNull)
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  Map<String, int> _buildDateBucketsFromModels(List<HseTaskModel> tasks,
      {int maxBuckets = 12}) {
    final buckets = <String, int>{};
    for (final task in tasks) {
      final key = _extractDateKey(task.date);
      buckets[key] = (buckets[key] ?? 0) + 1;
    }

    final sortedKeys = buckets.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    final result = <String, int>{};
    for (final key in sortedKeys.take(maxBuckets)) {
      result[key] = buckets[key] ?? 0;
    }
    return result;
  }

  String _extractDateKey(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) return 'unknown';
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return 'invalid';
    final y = parsed.year.toString().padLeft(4, '0');
    final m = parsed.month.toString().padLeft(2, '0');
    final d = parsed.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Map<String, dynamic>? _toMapOrNull(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  List<dynamic> _extractListData(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      final data = map['data'];
      if (data is List) return data;
      if (data is Map) {
        final reports = data['reports'];
        if (reports is List) return reports;
        final nested = data['data'];
        if (nested is List) return nested;
        final items = data['items'];
        if (items is List) return items;
      }
      final items = map['items'];
      if (items is List) return items;
      final reports = map['reports'];
      if (reports is List) return reports;
    }
    return <dynamic>[];
  }
}
