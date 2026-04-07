# Error Handling & Logging Guide

> **Updated:** 2026-04-07
> **Version:** 2.0

## 📚 Overview

This app now uses a standardized error handling and logging system that provides:
- **Consistent error handling** across the entire app
- **Production-safe logging** that automatically disables sensitive info in release
- **User-friendly error messages** in Indonesian
- **Type-safe exceptions** for better error management

---

## 🎯 Error Handling

### Basic Error Handling

**In DataSources:**
```dart
try {
  final response = await _dio.get('/endpoint');
  // Handle response
} catch (e) {
  log.error('Error fetching data', error: e, tag: 'MyDataSource');
  throw ErrorHandler.handleException(e);
}
```

**In Repositories:**
```dart
try {
  return await remoteDataSource.getData();
} on AppException {
  // Re-throw AppExceptions as-is
  rethrow;
} catch (e) {
  // Convert other exceptions to AppException
  throw ErrorHandler.handleException(e);
}
```

**In Providers/ViewModels:**
```dart
try {
  final data = await repository.getData();
  state = AsyncValue.data(data);
} catch (e, st) {
  state = AsyncValue.error(e, st);
  // Error will be automatically shown in UI
}
```

**In UI Screens:**
```dart
try {
  await ref.read(provider.notifier).doSomething();
} catch (e) {
  // Option 1: Show error dialog
  context.showError(e, title: 'Gagal Memuat Data');

  // Option 2: Show error snackbar
  context.showErrorSnackbar(e);
}
```

### Custom Exceptions

**Validation Exception:**
```dart
if (email.isEmpty) {
  throw ValidationException.requiredField(fieldName: 'Email');
}

if (!email.contains('@')) {
  throw ValidationException.invalidFormat(fieldName: 'Email');
}

// With field errors
throw ValidationException.invalidInput(
  message: 'Validasi gagal',
  fieldErrors: {
    'email': ['Email tidak valid'],
    'password': ['Password terlalu pendek'],
  },
);
```

**Network Exception:**
```dart
throw NetworkException.noInternet();
throw NetworkException.requestTimeout();
throw NetworkException.serverError(statusCode: 500);
throw NetworkException.unauthorized();
throw NetworkException.forbidden();
```

**Auth Exception:**
```dart
throw AuthException.invalidCredentials();
throw AuthException.sessionExpired();
throw AuthException.notAuthenticated();
```

**Business Exception:**
```dart
throw BusinessException.taskNotFound();
throw BusinessException.areaNotFound();
throw BusinessException.invalidOperation(
  message: 'Tidak dapat menghapus task yang sudah selesai',
);
```

---

## 📝 Logging

### Log Levels

**Debug Logs (Only in DEBUG mode):**
```dart
log.debug('User clicked button', data: {'button_id': 'submit'}, tag: 'MyScreen');

// Using extension
this.logDebug('Processing data', data: {'count': 100});
```

**Info Logs:**
```dart
log.info('Task created successfully', data: {'id': 123}, tag: 'TaskRepository');

// Using extension
this.logInfo('User logged in', data: {'email': user.email});
```

**Warning Logs:**
```dart
log.warning('Cache miss for key', data: {'key': 'user_123'}, tag: 'CacheManager');

// Using extension
this.logWarning('Retrying request', data: {'attempt': 3});
```

**Error Logs:**
```dart
log.error('Failed to save data', error: e, stackTrace: st, tag: 'DataManager');

// Using extension
this.logError('API call failed', error: e);
```

**Exception Logs:**
```dart
log.exception('Unexpected error in payment flow', exception, stackTrace: st);

// Using extension
this.logException('Database error', exception);
```

### API Logging

**Request Logging:**
```dart
log.apiRequest('POST', '/tasks', body: {
  'title': 'Fix bug',
  'area_id': 1,
});
```

**Response Logging:**
```dart
log.apiResponse('POST', '/tasks', 201, data: {'id': 123});
```

### Automatic Sensitive Data Redaction

The logger automatically redacts sensitive information:
- Passwords
- Tokens (access tokens, refresh tokens)
- API keys
- Secrets
- Authorization headers

**Example:**
```dart
log.apiRequest('POST', '/login', body: {
  'email': 'user@example.com',
  'password': 'secret123',  // Will be redacted to ***REDACTED***
  'token': 'abc123',         // Will be redacted to ***REDACTED***
});

// Output:
// 🌐 [POST] /login
// Body: {email: user@example.com, password: ***REDACTED***, token: ***REDACTED***}
```

---

## 🛠️ Error UI Utilities

### Show Error Dialog

```dart
ErrorUtils.showErrorDialog(
  context,
  error,
  title: 'Gagal Memuat Data',
  onRetry: () {
    // Retry logic
  },
);

// Using extension
context.showError(error, title: 'Error', onRetry: retry);
```

### Show Error Snackbar

```dart
ErrorUtils.showErrorSnackbar(context, error);

// Using extension
context.showErrorSnackbar(error);
```

### Get Error Icon

```dart
final icon = ErrorUtils.getIconForException(error);
// Returns: Icons.wifi_off for network errors
//          Icons.lock for auth errors
//          etc.
```

### Get Error Color

```dart
final color = ErrorUtils.getColorForException(context, error);
// Returns: Colors.orange for network errors
//          Colors.red for auth errors
//          etc.
```

---

## 📦 Environment Configuration

**In `lib/app/env/app_env.dart`:**

```dart
class AppEnv {
  // Enable logging in DEBUG mode, disable in production
  static const bool enableLogging =
    bool.fromEnvironment('DEBUG', defaultValue: true);

  // API Configuration
  static const int maxPaginationPages = 10;
  static const int defaultPaginationPageSize = 50;
  static const int maxPhotosPerTask = 3;

  // Security
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
}
```

**Usage:**
```dart
// Check if logging is enabled
if (AppEnv.enableLogging) {
  log.debug('This will only show in DEBUG mode');
}

// Use constants
final maxPages = AppEnv.maxPaginationPages;
final timeout = AppEnv.connectTimeout;
```

---

## 🔄 Migration Guide

### Migrating from Old Error Handling

**Before:**
```dart
try {
  final data = await _dio.get('/endpoint');
  return MyModel.fromJson(data);
} catch (e) {
  debugPrint('Error: $e');
  throw Exception('Gagal mengambil data: ${e.toString()}');
}
```

**After:**
```dart
try {
  log.info('Fetching data', tag: 'MyDataSource');
  final response = await _dio.get('/endpoint');
  return MyModel.fromJson(response.data);
} catch (e) {
  log.error('Error fetching data', error: e, tag: 'MyDataSource');
  throw ErrorHandler.handleException(e);
}
```

### Migrating from Old Debug Prints

**Before:**
```dart
debugPrint('[MyScreen] User clicked button');
debugPrint('[MyScreen] Data: $data');
debugPrint('[MyScreen] Error: $error');
```

**After:**
```dart
log.debug('User clicked button', tag: 'MyScreen');
log.info('Data loaded', data: data, tag: 'MyScreen');
log.error('Error occurred', error: error, tag: 'MyScreen');

// Or using extension
this.logDebug('User clicked button');
this.logInfo('Data loaded', data: data);
this.logError('Error occurred', error: error);
```

---

## 🧪 Testing Error Handling

**In Unit Tests:**
```dart
test('should throw NetworkException when no internet', () async {
  // Arrange
  when(mockDio.get(any)).thenThrow(
    DioException(
      type: DioExceptionType.unknown,
      error: SocketException('No internet'),
    ),
  );

  // Act & Assert
  expect(
    () => dataSource.getData(),
    throwsA(isA<NetworkException>()),
  );
});
```

**In Widget Tests:**
```dart
testWidgets('should show error dialog when error occurs', (tester) async {
  // Arrange
  when(ref.read(provider.future)).thenThrow(
    ValidationException.requiredField(fieldName: 'Email'),
  );

  // Act
  await tester.pumpWidget(testWidget);
  await tester.pumpAndSettle();

  // Assert
  expect(find.text('Email harus diisi.'), findsOneWidget);
});
```

---

## 📋 Best Practices

### ✅ DO
- ✅ Always use `ErrorHandler.handleException(e)` in catch blocks
- ✅ Use specific exception types when possible
- ✅ Provide user-friendly error messages in Indonesian
- ✅ Log errors with context (what operation failed)
- ✅ Use appropriate log levels (debug, info, warning, error)
- ✅ Redact sensitive information from logs
- ✅ Handle errors gracefully in UI

### ❌ DON'T
- ❌ Don't throw generic `Exception()` - use specific types
- ❌ Don't use `debugPrint()` - use `AppLogger`
- ❌ Don't log sensitive information (tokens, passwords, etc.)
- ❌ Don't ignore errors - always handle them
- ❌ Don't show stack traces to users - only in logs
- ❌ Don't use print() statements
- ❌ Don't expose technical details in error messages

---

## 🔍 Troubleshooting

**Logs not showing in production?**
- Check `AppEnv.enableLogging` is set correctly
- Remember logs are auto-disabled in release builds

**Error messages not user-friendly?**
- Make sure to use Indonesian messages
- Avoid technical jargon
- Provide actionable suggestions

**Provider invalidation causing performance issues?**
- Only invalidate providers that actually need updating
- Let Riverpod handle dependent providers automatically
- Use selective invalidation instead of blanket invalidation

---

## 📚 Additional Resources

- **Error Classes:** `lib/core/error/app_exception.dart`
- **Error Handler:** `lib/core/error/error_handler.dart`
- **Logger:** `lib/core/utils/logger.dart`
- **Error UI Utils:** `lib/core/utils/error_utils.dart`
- **Environment Config:** `lib/app/env/app_env.dart`

---

**Last Updated:** 2026-04-07
**Version:** 2.0
