import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:topla_app/services/api_error_handler.dart';

void main() {
  group('ApiException Tests', () {
    test('should create network error', () {
      final error = ApiException(
        message: 'No connection',
        type: ApiErrorType.network,
      );

      expect(error.type, equals(ApiErrorType.network));
      expect(error.userMessage, contains('Internet'));
    });

    test('should create server error', () {
      final error = ApiException(
        message: 'Server error',
        type: ApiErrorType.server,
        statusCode: 500,
      );

      expect(error.type, equals(ApiErrorType.server));
      expect(error.statusCode, equals(500));
      expect(error.userMessage, contains('Server'));
    });

    test('should create auth error', () {
      final error = ApiException(
        message: 'Unauthorized',
        type: ApiErrorType.auth,
      );

      expect(error.type, equals(ApiErrorType.auth));
      expect(error.userMessage, contains('Avtorizatsiya'));
    });

    test('should create validation error with custom message', () {
      final error = ApiException(
        message: 'Email noto\'g\'ri',
        type: ApiErrorType.validation,
      );

      expect(error.type, equals(ApiErrorType.validation));
      expect(error.userMessage, equals('Email noto\'g\'ri'));
    });

    test('should have correct icons for each type', () {
      expect(
        ApiException(message: '', type: ApiErrorType.network).icon,
        isNotNull,
      );
      expect(
        ApiException(message: '', type: ApiErrorType.server).icon,
        isNotNull,
      );
      expect(
        ApiException(message: '', type: ApiErrorType.auth).icon,
        isNotNull,
      );
      expect(
        ApiException(message: '', type: ApiErrorType.timeout).icon,
        isNotNull,
      );
    });
  });

  group('ApiErrorHandler Tests', () {
    test('should handle SocketException as network error', () {
      final error = ApiErrorHandler.handle(
        const SocketException('Connection failed'),
      );

      expect(error.type, equals(ApiErrorType.network));
    });

    test('should handle TimeoutException', () {
      final error = ApiErrorHandler.handle(
        TimeoutException('Request timeout'),
      );

      expect(error.type, equals(ApiErrorType.timeout));
    });

    test('should handle unknown error', () {
      final error = ApiErrorHandler.handle(Exception('Unknown'));

      expect(error.type, equals(ApiErrorType.unknown));
    });

    test('should pass through ApiException', () {
      final original = ApiException(
        message: 'Test',
        type: ApiErrorType.validation,
      );

      final handled = ApiErrorHandler.handle(original);

      expect(handled, equals(original));
    });
  });

  group('ApiResult Tests', () {
    test('should create success result', () {
      final result = ApiResult.success('data');

      expect(result.isSuccess, isTrue);
      expect(result.data, equals('data'));
      expect(result.error, isNull);
    });

    test('should create failure result', () {
      final error = ApiException(
        message: 'Error',
        type: ApiErrorType.server,
      );
      final result = ApiResult.failure(error);

      expect(result.isSuccess, isFalse);
      expect(result.data, isNull);
      expect(result.error, equals(error));
    });

    test('should map success value', () {
      final result = ApiResult.success(5);
      final mapped = result.map((data) => data * 2);

      expect(mapped.isSuccess, isTrue);
      expect(mapped.data, equals(10));
    });

    test('should not map failure value', () {
      final error = ApiException(
        message: 'Error',
        type: ApiErrorType.server,
      );
      final result = ApiResult<int>.failure(error);
      final mapped = result.map((data) => data * 2);

      expect(mapped.isSuccess, isFalse);
      expect(mapped.error, equals(error));
    });

    test('getOrThrow should return data on success', () {
      final result = ApiResult.success('data');
      expect(result.getOrThrow(), equals('data'));
    });

    test('getOrThrow should throw on failure', () {
      final error = ApiException(
        message: 'Error',
        type: ApiErrorType.server,
      );
      final result = ApiResult<String>.failure(error);

      expect(() => result.getOrThrow(), throwsA(isA<ApiException>()));
    });

    test('getOrDefault should return data on success', () {
      final result = ApiResult.success('data');
      expect(result.getOrDefault('default'), equals('data'));
    });

    test('getOrDefault should return default on failure', () {
      final error = ApiException(
        message: 'Error',
        type: ApiErrorType.server,
      );
      final result = ApiResult<String>.failure(error);

      expect(result.getOrDefault('default'), equals('default'));
    });
  });

  group('ApiErrorHandler.execute Tests', () {
    test('should return value on success', () async {
      final result = await ApiErrorHandler.execute(() async => 'success');
      expect(result, equals('success'));
    });

    test('should throw ApiException on error', () async {
      expect(
        () => ApiErrorHandler.execute(() async {
          throw const SocketException('No internet');
        }),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
