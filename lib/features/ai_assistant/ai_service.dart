import 'dart:async';

import 'package:dio/dio.dart';

import '../../services/auth_service.dart';
import 'ai_models.dart';

class AiServiceException implements Exception {
  final String code;
  final String message;
  final bool retriable;

  const AiServiceException({
    required this.code,
    required this.message,
    this.retriable = false,
  });

  @override
  String toString() => 'AiServiceException($code): $message';
}

class AiAssistantResponse {
  final AiChatThread chat;
  final List<AiChatMessage> messages;

  const AiAssistantResponse({required this.chat, required this.messages});
}

class AiAssistantService {
  final Dio _dio;

  AiAssistantService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AuthService.baseUrl,
              connectTimeout: const Duration(seconds: 8),
              sendTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 14),
              validateStatus: (status) => status != null && status < 600,
            ),
          );

  Future<bool> checkBackendHealth() async {
    try {
      final response = await _dio.get(
        '/api/v1/health',
        options: Options(
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );

      final statusCode = response.statusCode ?? 500;
      if (statusCode < 200 || statusCode >= 300) {
        return false;
      }

      final body = _asMap(response.data);
      if (body.isEmpty) {
        return true;
      }

      return body['success'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<List<AiChatThread>> fetchChats({int limit = 40}) async {
    return _executeWithRetry(() async {
      try {
        final response = await _dio.get(
          '/api/v1/ai/chats',
          queryParameters: {'limit': limit},
          options: await _authOptions(),
        );

        final body = _asMap(response.data);
        final statusCode = response.statusCode ?? 500;
        if (statusCode >= 200 && statusCode < 300 && body['success'] == true) {
          final data = _asMap(body['data']);
          final chatsValue = data['chats'];
          if (chatsValue is List) {
            return chatsValue
                .whereType<Map>()
                .map((item) => AiChatThread.fromMap(item))
                .toList();
          }
          return <AiChatThread>[];
        }

        throw AiServiceException(
          code: _extractErrorCode(body, statusCode),
          message: _extractErrorMessage(body, statusCode),
          retriable: _isRetriableStatus(statusCode),
        );
      } on DioException catch (error) {
        throw _fromDioError(error);
      }
    });
  }

  Future<AiChatThread> createChat({String? title}) async {
    return _executeWithRetry(() async {
      try {
        final response = await _dio.post(
          '/api/v1/ai/chats',
          data: {if ((title ?? '').trim().isNotEmpty) 'title': title!.trim()},
          options: await _authOptions(),
        );

        final statusCode = response.statusCode ?? 500;
        final body = _asMap(response.data);
        if (statusCode >= 200 && statusCode < 300 && body['success'] == true) {
          final data = _asMap(body['data']);
          return AiChatThread.fromMap(_asMap(data['chat']));
        }

        throw AiServiceException(
          code: _extractErrorCode(body, statusCode),
          message: _extractErrorMessage(body, statusCode),
          retriable: _isRetriableStatus(statusCode),
        );
      } on DioException catch (error) {
        throw _fromDioError(error);
      }
    }, maxRetries: 0);
  }

  Future<AiChatThread> renameChat({
    required String chatId,
    required String title,
  }) async {
    return _executeWithRetry(() async {
      try {
        final response = await _dio.patch(
          '/api/v1/ai/chats/$chatId',
          data: {'title': title.trim()},
          options: await _authOptions(),
        );

        final statusCode = response.statusCode ?? 500;
        final body = _asMap(response.data);
        if (statusCode >= 200 && statusCode < 300 && body['success'] == true) {
          final data = _asMap(body['data']);
          return AiChatThread.fromMap(_asMap(data['chat']));
        }

        throw AiServiceException(
          code: _extractErrorCode(body, statusCode),
          message: _extractErrorMessage(body, statusCode),
          retriable: _isRetriableStatus(statusCode),
        );
      } on DioException catch (error) {
        throw _fromDioError(error);
      }
    });
  }

  Future<void> deleteChat(String chatId) async {
    await _executeWithRetry(() async {
      try {
        final response = await _dio.delete(
          '/api/v1/ai/chats/$chatId',
          options: await _authOptions(),
        );

        final statusCode = response.statusCode ?? 500;
        final body = _asMap(response.data);
        if (statusCode >= 200 && statusCode < 300 && body['success'] == true) {
          return;
        }

        throw AiServiceException(
          code: _extractErrorCode(body, statusCode),
          message: _extractErrorMessage(body, statusCode),
          retriable: _isRetriableStatus(statusCode),
        );
      } on DioException catch (error) {
        throw _fromDioError(error);
      }
    });
  }

  Future<List<AiChatMessage>> fetchMessages({
    required String chatId,
    int limit = 300,
  }) async {
    return _executeWithRetry(() async {
      try {
        final response = await _dio.get(
          '/api/v1/ai/chats/$chatId/messages',
          queryParameters: {'limit': limit},
          options: await _authOptions(),
        );

        final statusCode = response.statusCode ?? 500;
        final body = _asMap(response.data);
        if (statusCode >= 200 && statusCode < 300 && body['success'] == true) {
          final data = _asMap(body['data']);
          final messagesValue = data['messages'];
          if (messagesValue is List) {
            return messagesValue
                .whereType<Map>()
                .map((item) => AiChatMessage.fromMap(item))
                .toList();
          }
          return <AiChatMessage>[];
        }

        throw AiServiceException(
          code: _extractErrorCode(body, statusCode),
          message: _extractErrorMessage(body, statusCode),
          retriable: _isRetriableStatus(statusCode),
        );
      } on DioException catch (error) {
        throw _fromDioError(error);
      }
    });
  }

  Future<AiAssistantResponse> sendChatMessage({
    required String chatId,
    required String message,
    CancelToken? cancelToken,
  }) async {
    return _executeWithRetry(() async {
      try {
        final response = await _dio.post(
          '/api/v1/ai/chats/$chatId/messages',
          data: {'message': message},
          options: await _authOptions(),
          cancelToken: cancelToken,
        );

        final statusCode = response.statusCode ?? 500;
        final body = _asMap(response.data);

        if (statusCode >= 200 && statusCode < 300 && body['success'] == true) {
          final data = _asMap(body['data']);
          return AiAssistantResponse(
            chat: AiChatThread.fromMap(_asMap(data['chat'])),
            messages: _messagesFromData(data),
          );
        }

        final messageText = _extractErrorMessage(body, statusCode);
        final code = _extractErrorCode(body, statusCode);

        throw AiServiceException(
          code: code,
          message: messageText,
          retriable: _isRetriableStatus(statusCode),
        );
      } on DioException catch (error) {
        throw _fromDioError(error);
      }
    }, maxRetries: 0);
  }

  Future<AiAssistantResponse> editAndResendMessage({
    required String chatId,
    required String messageId,
    required String message,
    CancelToken? cancelToken,
  }) async {
    return _executeWithRetry(() async {
      try {
        final response = await _dio.post(
          '/api/v1/ai/chats/$chatId/messages/$messageId/resend',
          data: {'message': message},
          options: await _authOptions(),
          cancelToken: cancelToken,
        );

        final statusCode = response.statusCode ?? 500;
        final body = _asMap(response.data);
        if (statusCode >= 200 && statusCode < 300 && body['success'] == true) {
          final data = _asMap(body['data']);
          return AiAssistantResponse(
            chat: AiChatThread.fromMap(_asMap(data['chat'])),
            messages: _messagesFromData(data),
          );
        }

        throw AiServiceException(
          code: _extractErrorCode(body, statusCode),
          message: _extractErrorMessage(body, statusCode),
          retriable: _isRetriableStatus(statusCode),
        );
      } on DioException catch (error) {
        throw _fromDioError(error);
      }
    }, maxRetries: 0);
  }

  Future<T> _executeWithRetry<T>(
    Future<T> Function() action, {
    int maxRetries = 2,
  }) async {
    AiServiceException? lastException;

    for (int attempt = 0; attempt <= maxRetries; attempt += 1) {
      try {
        return await action();
      } on AiServiceException catch (error) {
        lastException = error;

        if (attempt >= maxRetries || !error.retriable) {
          rethrow;
        }

        final backoff = Duration(milliseconds: 350 * (attempt + 1));
        await Future<void>.delayed(backoff);
      }
    }

    throw lastException ??
        const AiServiceException(
          code: 'AI_UNKNOWN',
          message: 'Unexpected AI request failure.',
        );
  }

  Future<Options> _authOptions() async {
    final token = await AuthService.getAccessToken();
    if (token == null || token.trim().isEmpty) {
      throw const AiServiceException(
        code: 'AUTH_REQUIRED',
        message: 'Session expired. Please login again.',
        retriable: false,
      );
    }

    return Options(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  List<AiChatMessage> _messagesFromData(Map<String, dynamic> data) {
    final messagesValue = data['messages'];
    if (messagesValue is List) {
      return messagesValue
          .whereType<Map>()
          .map((item) => AiChatMessage.fromMap(item))
          .toList();
    }
    return <AiChatMessage>[];
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, val) => MapEntry('$key', val));
    }
    return <String, dynamic>{};
  }

  String _extractErrorMessage(Map<String, dynamic> body, int statusCode) {
    final errorObject = body['error'];
    if (errorObject is Map) {
      final normalized = _asMap(errorObject);
      final message = normalized['message'] as String?;
      if (message != null && message.trim().isNotEmpty) {
        return message.trim();
      }
    }

    final directMessage = body['message'] as String?;
    if (directMessage != null && directMessage.trim().isNotEmpty) {
      return directMessage.trim();
    }

    if (statusCode == 401 || statusCode == 403) {
      return 'Authentication failed. Please login again.';
    }

    if (statusCode == 404) {
      return 'Requested AI resource was not found.';
    }

    return 'AI service temporarily unavailable.';
  }

  String _extractErrorCode(Map<String, dynamic> body, int statusCode) {
    final errorObject = body['error'];
    if (errorObject is Map) {
      final normalized = _asMap(errorObject);
      final code = normalized['code'] as String?;
      if (code != null && code.trim().isNotEmpty) {
        return code.trim();
      }
    }

    if (statusCode == 401 || statusCode == 403) {
      return 'AUTH_ERROR';
    }

    if (statusCode == 404) {
      return 'AI_RESOURCE_NOT_FOUND';
    }

    return 'AI_REQUEST_FAILED';
  }

  bool _isRetriableStatus(int statusCode) {
    return statusCode == 408 ||
        statusCode == 429 ||
        statusCode == 500 ||
        statusCode == 502 ||
        statusCode == 503 ||
        statusCode == 504;
  }

  AiServiceException _fromDioError(DioException error) {
    final statusCode = error.response?.statusCode;

    if (error.type == DioExceptionType.cancel) {
      return const AiServiceException(
        code: 'REQUEST_CANCELLED',
        message: 'Request was cancelled.',
        retriable: false,
      );
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const AiServiceException(
        code: 'TIMEOUT',
        message:
            'The AI assistant is taking too long to respond. Please retry.',
        retriable: true,
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return const AiServiceException(
        code: 'NETWORK_ERROR',
        message: 'Network connection failed. Please check your internet.',
        retriable: true,
      );
    }

    if (statusCode != null) {
      final body = _asMap(error.response?.data);
      return AiServiceException(
        code: _extractErrorCode(body, statusCode),
        message: _extractErrorMessage(body, statusCode),
        retriable: _isRetriableStatus(statusCode),
      );
    }

    return const AiServiceException(
      code: 'SERVER_UNREACHABLE',
      message: 'Unable to contact backend service.',
      retriable: true,
    );
  }
}
