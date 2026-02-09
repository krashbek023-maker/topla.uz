import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// API Error types
enum ApiErrorType {
  network,
  server,
  auth,
  validation,
  notFound,
  rateLimit,
  timeout,
  unknown,
}

/// API Exception class
class ApiException implements Exception {
  final String message;
  final ApiErrorType type;
  final int? statusCode;
  final dynamic originalError;

  ApiException({
    required this.message,
    required this.type,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'ApiException: $message (type: $type)';

  /// Get user-friendly message in Uzbek
  String get userMessage {
    switch (type) {
      case ApiErrorType.network:
        return 'Internet aloqasi yo\'q. Iltimos, tarmoqni tekshiring.';
      case ApiErrorType.server:
        return 'Server bilan muammo. Keyinroq urinib ko\'ring.';
      case ApiErrorType.auth:
        return 'Avtorizatsiya xatosi. Qaytadan kiring.';
      case ApiErrorType.validation:
        return message;
      case ApiErrorType.notFound:
        return 'Ma\'lumot topilmadi.';
      case ApiErrorType.rateLimit:
        return 'Juda ko\'p so\'rov. Biroz kuting.';
      case ApiErrorType.timeout:
        return 'So\'rov vaqti tugadi. Qayta urinib ko\'ring.';
      case ApiErrorType.unknown:
        return 'Noma\'lum xatolik yuz berdi.';
    }
  }

  /// Get icon for error type
  IconData get icon {
    switch (type) {
      case ApiErrorType.network:
        return Icons.wifi_off;
      case ApiErrorType.server:
        return Icons.cloud_off;
      case ApiErrorType.auth:
        return Icons.lock_outline;
      case ApiErrorType.validation:
        return Icons.warning_amber;
      case ApiErrorType.notFound:
        return Icons.search_off;
      case ApiErrorType.rateLimit:
        return Icons.speed;
      case ApiErrorType.timeout:
        return Icons.timer_off;
      case ApiErrorType.unknown:
        return Icons.error_outline;
    }
  }
}

/// API Error Handler
class ApiErrorHandler {
  /// Parse and convert exceptions to ApiException
  static ApiException handle(dynamic error) {
    // Network errors
    if (error is SocketException) {
      return ApiException(
        message: 'No internet connection',
        type: ApiErrorType.network,
        originalError: error,
      );
    }

    // Timeout errors
    if (error is TimeoutException) {
      return ApiException(
        message: 'Request timeout',
        type: ApiErrorType.timeout,
        originalError: error,
      );
    }

    // Supabase/PostgrestException errors
    if (error is PostgrestException) {
      return _handlePostgrestError(error);
    }

    // Auth errors
    if (error is AuthException) {
      return ApiException(
        message: error.message,
        type: ApiErrorType.auth,
        statusCode: int.tryParse(error.statusCode ?? ''),
        originalError: error,
      );
    }

    // Already ApiException
    if (error is ApiException) {
      return error;
    }

    // Unknown error
    return ApiException(
      message: error.toString(),
      type: ApiErrorType.unknown,
      originalError: error,
    );
  }

  static ApiException _handlePostgrestError(PostgrestException error) {
    final code = error.code;
    final message = error.message;

    // Check for specific error codes
    if (code == '23505') {
      return ApiException(
        message: 'Bu ma\'lumot allaqachon mavjud',
        type: ApiErrorType.validation,
        originalError: error,
      );
    }

    if (code == '23503') {
      return ApiException(
        message: 'Bog\'liq ma\'lumot topilmadi',
        type: ApiErrorType.validation,
        originalError: error,
      );
    }

    if (code == '42501') {
      return ApiException(
        message: 'Ruxsat yo\'q',
        type: ApiErrorType.auth,
        originalError: error,
      );
    }

    if (code == 'PGRST116') {
      return ApiException(
        message: 'Ma\'lumot topilmadi',
        type: ApiErrorType.notFound,
        originalError: error,
      );
    }

    return ApiException(
      message: message,
      type: ApiErrorType.server,
      originalError: error,
    );
  }

  /// Execute API call with error handling
  static Future<T> execute<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } catch (e) {
      throw handle(e);
    }
  }

  /// Execute with retry
  static Future<T> executeWithRetry<T>(
    Future<T> Function() apiCall, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;

    while (true) {
      try {
        return await apiCall();
      } catch (e) {
        attempts++;
        final error = handle(e);

        // Don't retry auth or validation errors
        if (error.type == ApiErrorType.auth ||
            error.type == ApiErrorType.validation ||
            error.type == ApiErrorType.notFound) {
          throw error;
        }

        if (attempts >= maxRetries) {
          throw error;
        }

        // Exponential backoff
        await Future.delayed(delay * attempts);
      }
    }
  }

  /// Show error snackbar
  static void showErrorSnackbar(BuildContext context, dynamic error) {
    final apiError = error is ApiException ? error : handle(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(apiError.icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(apiError.userMessage),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
  }) async {
    final apiError = error is ApiException ? error : handle(error);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: Icon(
          apiError.icon,
          size: 48,
          color: Colors.red,
        ),
        title: const Text('Xatolik'),
        content: Text(
          apiError.userMessage,
          textAlign: TextAlign.center,
        ),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              child: const Text('Qayta urinish'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Result wrapper for API calls
class ApiResult<T> {
  final T? data;
  final ApiException? error;
  final bool isSuccess;

  ApiResult._({this.data, this.error, required this.isSuccess});

  factory ApiResult.success(T data) => ApiResult._(data: data, isSuccess: true);

  factory ApiResult.failure(ApiException error) =>
      ApiResult._(error: error, isSuccess: false);

  /// Execute and return result
  static Future<ApiResult<T>> from<T>(Future<T> Function() apiCall) async {
    try {
      final data = await apiCall();
      return ApiResult.success(data);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  /// Map success value
  ApiResult<R> map<R>(R Function(T data) mapper) {
    final currentData = data;
    if (isSuccess && currentData != null) {
      return ApiResult.success(mapper(currentData));
    }
    return ApiResult.failure(error!);
  }

  /// Get data or throw
  T getOrThrow() {
    if (isSuccess && data != null) {
      return data as T;
    }
    throw error!;
  }

  /// Get data or default
  T getOrDefault(T defaultValue) {
    if (isSuccess && data != null) {
      return data as T;
    }
    return defaultValue;
  }
}
