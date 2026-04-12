import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'ai_models.dart';
import 'ai_service.dart';

final aiAssistantServiceProvider = Provider<AiAssistantService>((ref) {
  return AiAssistantService();
});

final aiAssistantControllerProvider =
    StateNotifierProvider<AiAssistantController, AiAssistantState>((ref) {
      final service = ref.watch(aiAssistantServiceProvider);
      return AiAssistantController(service);
    });

class AiAssistantController extends StateNotifier<AiAssistantState> {
  AiAssistantController(this._service) : super(const AiAssistantState());

  final AiAssistantService _service;
  final Connectivity _connectivity = Connectivity();

  static const String _cacheBoxName = 'ai_assistant_cache';
  static const String _stateBoxName = 'ai_assistant_state';
  static const Duration _cacheTtl = Duration(hours: 24);
  static const Duration _debounceDuration = Duration(milliseconds: 320);
  static const Duration _healthSyncInterval = Duration(seconds: 25);
  static const Duration _syncCooldown = Duration(seconds: 8);

  Box<dynamic>? _cacheBox;
  Box<dynamic>? _stateBox;
  final Map<String, List<AiChatMessage>> _messagesByChat =
      <String, List<AiChatMessage>>{};

  StreamSubscription<dynamic>? _connectivitySubscription;
  Timer? _healthTimer;

  bool _initialized = false;
  bool _isDisposed = false;
  bool _isSyncInProgress = false;
  DateTime _lastSyncAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastMessageSentAt = DateTime.fromMillisecondsSinceEpoch(0);
  CancelToken? _activeCancelToken;

  Future<void> initialize() async {
    if (_initialized) return;

    await Hive.initFlutter();
    _cacheBox = await Hive.openBox<dynamic>(_cacheBoxName);
    _stateBox = await Hive.openBox<dynamic>(_stateBoxName);

    final chats = <AiChatThread>[];
    final storedChats = _stateBox?.get('chats');
    if (storedChats is List) {
      for (final item in storedChats) {
        if (item is Map) {
          chats.add(AiChatThread.fromMap(item));
        }
      }
    }

    final storedMessagesByChat = _stateBox?.get('messagesByChat');
    if (storedMessagesByChat is Map) {
      for (final entry in storedMessagesByChat.entries) {
        final key = entry.key;
        final value = entry.value;
        if (key is String && value is List) {
          final parsed = <AiChatMessage>[];
          for (final item in value) {
            if (item is Map) {
              parsed.add(AiChatMessage.fromMap(item));
            }
          }
          _messagesByChat[key] = parsed;
        }
      }
    }

    final storedActiveChatId = _stateBox?.get('activeChatId') as String?;
    final activeChatId = _resolveInitialActiveChatId(chats, storedActiveChatId);
    final activeMessages = activeChatId != null
        ? (_messagesByChat[activeChatId] ?? const [])
        : const <AiChatMessage>[];

    state = state.copyWith(
      chats: chats,
      activeChatId: activeChatId,
      messages: activeMessages,
      clearError: true,
    );

    _initialized = true;
    await refreshBackendStatus(showSyncState: false);
    _startConnectivitySync();
    _startHealthPolling();

    if (state.isBackendReachable) {
      await synchronizeFromBackend(createIfEmpty: state.chats.isEmpty);
    }
  }

  Future<void> refreshBackendStatus({bool showSyncState = true}) async {
    if (_isDisposed) return;

    if (showSyncState) {
      state = state.copyWith(isSyncingBackend: true);
    }

    final offline = await _isOffline();
    if (offline) {
      if (_isDisposed) return;
      state = state.copyWith(
        isOffline: true,
        isBackendReachable: false,
        isSyncingBackend: false,
      );
      return;
    }

    final wasReachable = state.isBackendReachable;
    final reachable = await _service.checkBackendHealth();
    if (_isDisposed) return;

    state = state.copyWith(
      isOffline: false,
      isBackendReachable: reachable,
      isSyncingBackend: false,
    );

    if (reachable && (!wasReachable || showSyncState)) {
      await synchronizeFromBackend(
        createIfEmpty: state.chats.isEmpty,
        force: showSyncState,
      );
    }
  }

  void _startConnectivitySync() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((_) {
      refreshBackendStatus(showSyncState: false);
    });
  }

  void _startHealthPolling() {
    _healthTimer?.cancel();
    _healthTimer = Timer.periodic(_healthSyncInterval, (_) {
      refreshBackendStatus(showSyncState: false);
    });
  }

  Future<void> synchronizeFromBackend({
    bool createIfEmpty = false,
    bool force = false,
  }) async {
    if (_isDisposed) return;
    if (!state.isBackendReachable || state.isOffline) return;
    if (_isSyncInProgress) return;

    if (!force) {
      final now = DateTime.now();
      if (now.difference(_lastSyncAt) < _syncCooldown) {
        return;
      }
    }

    _isSyncInProgress = true;

    state = state.copyWith(isLoadingChats: true, clearError: true);

    try {
      var chats = await _service.fetchChats(limit: 40);
      if (chats.isEmpty && createIfEmpty) {
        final created = await _service.createChat();
        chats = [created];
      }

      final activeChatId = _resolveInitialActiveChatId(
        chats,
        state.activeChatId,
      );
      List<AiChatMessage> messages = const <AiChatMessage>[];

      if (activeChatId != null) {
        messages = await _service.fetchMessages(chatId: activeChatId);
        _messagesByChat[activeChatId] = messages;
      }

      state = state.copyWith(
        chats: chats,
        activeChatId: activeChatId,
        messages: messages,
        isLoadingChats: false,
        isLoadingMessages: false,
        isOffline: false,
        isBackendReachable: true,
        clearError: true,
      );
      await _persistState();
      _lastSyncAt = DateTime.now();
    } on AiServiceException catch (error) {
      final networkRelated = _isNetworkErrorCode(error.code);
      state = state.copyWith(
        isLoadingChats: false,
        isLoadingMessages: false,
        error: error.message,
        isBackendReachable: !networkRelated,
        isOffline: networkRelated,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingChats: false,
        isLoadingMessages: false,
        error: 'Failed to sync chats from backend.',
      );
    } finally {
      _isSyncInProgress = false;
    }
  }

  Future<void> createChat({String? title}) async {
    if (!_initialized) {
      await initialize();
    }

    if (state.isOffline || !state.isBackendReachable) {
      state = state.copyWith(
        error: 'Cannot create a new chat while backend is offline.',
      );
      return;
    }

    state = state.copyWith(isLoadingChats: true, clearError: true);
    try {
      final chat = await _service.createChat(title: title);
      final chats = [chat, ...state.chats.where((item) => item.id != chat.id)];
      _messagesByChat.putIfAbsent(chat.id, () => <AiChatMessage>[]);

      state = state.copyWith(
        chats: chats,
        activeChatId: chat.id,
        messages: const <AiChatMessage>[],
        isLoadingChats: false,
        clearError: true,
      );
      await _persistState();
    } on AiServiceException catch (error) {
      state = state.copyWith(isLoadingChats: false, error: error.message);
    }
  }

  Future<void> selectChat(String chatId) async {
    if (chatId.trim().isEmpty) return;
    if (state.activeChatId == chatId) return;

    final localMessages = _messagesByChat[chatId] ?? const <AiChatMessage>[];
    state = state.copyWith(
      activeChatId: chatId,
      messages: localMessages,
      isLoadingMessages: true,
      clearError: true,
    );

    if (state.isOffline || !state.isBackendReachable) {
      state = state.copyWith(isLoadingMessages: false);
      await _persistState();
      return;
    }

    try {
      final messages = await _service.fetchMessages(chatId: chatId);
      _messagesByChat[chatId] = messages;
      state = state.copyWith(
        messages: messages,
        isLoadingMessages: false,
        clearError: true,
      );
      await _persistState();
    } on AiServiceException catch (error) {
      state = state.copyWith(isLoadingMessages: false, error: error.message);
    }
  }

  Future<void> renameChat({
    required String chatId,
    required String title,
  }) async {
    final normalized = title.trim();
    if (normalized.length < 2) {
      state = state.copyWith(
        error: 'Chat title must be at least 2 characters.',
      );
      return;
    }

    try {
      final updated = await _service.renameChat(
        chatId: chatId,
        title: normalized,
      );
      final chats = state.chats
          .map((item) => item.id == chatId ? updated : item)
          .toList(growable: false);
      state = state.copyWith(chats: chats, clearError: true);
      await _persistState();
    } on AiServiceException catch (error) {
      state = state.copyWith(error: error.message);
    }
  }

  Future<void> deleteChat(String chatId) async {
    if (chatId.trim().isEmpty) return;

    try {
      await _service.deleteChat(chatId);
      _messagesByChat.remove(chatId);

      final chats = state.chats
          .where((item) => item.id != chatId)
          .toList(growable: false);

      final nextActive = _resolveInitialActiveChatId(
        chats,
        state.activeChatId == chatId ? null : state.activeChatId,
      );

      state = state.copyWith(
        chats: chats,
        activeChatId: nextActive,
        clearActiveChatId: nextActive == null,
        messages: nextActive == null
            ? const <AiChatMessage>[]
            : (_messagesByChat[nextActive] ?? const <AiChatMessage>[]),
        clearError: true,
      );

      await _persistState();

      if (nextActive != null && state.isBackendReachable && !state.isOffline) {
        await selectChat(nextActive);
      }
    } on AiServiceException catch (error) {
      state = state.copyWith(error: error.message);
    }
  }

  Future<void> sendMessage({required String message}) async {
    if (!_initialized) {
      await initialize();
    }

    final normalized = normalizeMessage(message);
    if (normalized.isEmpty) return;

    if (state.isSending) return;

    final now = DateTime.now();
    if (now.difference(_lastMessageSentAt) < _debounceDuration) {
      return;
    }
    _lastMessageSentAt = now;

    var activeChatId = state.activeChatId;
    if (activeChatId == null) {
      if (state.isOffline || !state.isBackendReachable) {
        state = state.copyWith(
          error: 'Backend is offline. Reconnect to create a new chat.',
        );
        return;
      }

      try {
        final created = await _service.createChat();
        activeChatId = created.id;
        final chats = [
          created,
          ...state.chats.where((item) => item.id != created.id),
        ];
        _messagesByChat[created.id] = const <AiChatMessage>[];
        state = state.copyWith(
          chats: chats,
          activeChatId: created.id,
          messages: const <AiChatMessage>[],
        );
      } on AiServiceException catch (error) {
        state = state.copyWith(error: error.message);
        return;
      }
    }

    final chatId = activeChatId;

    final tempUser = AiChatMessage(
      id: 'tmp-${now.microsecondsSinceEpoch}',
      chatId: chatId,
      role: AiMessageRole.user,
      text: normalized,
      createdAt: now,
      updatedAt: now,
    );

    final optimisticMessages = [...state.messages, tempUser];
    _messagesByChat[chatId] = optimisticMessages;

    state = state.copyWith(
      messages: optimisticMessages,
      isSending: true,
      clearError: true,
    );
    await _persistState();

    final cacheKey = cacheKeyForQuestion(chatId: chatId, message: normalized);

    try {
      final offline = await _isOffline();
      if (offline) {
        final cached = _readCachedResponse(cacheKey);
        if (cached != null) {
          await _appendAssistantMessage(
            chatId: chatId,
            text: cached,
            fromCache: true,
            isOffline: true,
          );
          return;
        }

        await _appendAssistantMessage(
          chatId: chatId,
          text: _offlineFallback(_detectLanguage(normalized)),
          fromCache: false,
          isOffline: true,
        );

        state = state.copyWith(
          error: _offlineError(_detectLanguage(normalized)),
          isSending: false,
          isOffline: true,
        );
        return;
      }

      if (!state.isBackendReachable) {
        final backendNowReachable = await _service.checkBackendHealth();
        if (!backendNowReachable) {
          final cached = _readCachedResponse(cacheKey);
          if (cached != null) {
            await _appendAssistantMessage(
              chatId: chatId,
              text: cached,
              fromCache: true,
              isOffline: false,
            );
            state = state.copyWith(
              error: 'Backend is unreachable. Using cached response.',
              isSending: false,
              isOffline: false,
              isBackendReachable: false,
            );
            return;
          }

          await _appendAssistantMessage(
            chatId: chatId,
            text: _friendlyFailure(
              'Backend unreachable',
              _detectLanguage(normalized),
            ),
            fromCache: false,
            isOffline: false,
          );
          state = state.copyWith(
            error: 'Backend service is unavailable right now.',
            isSending: false,
            isOffline: false,
            isBackendReachable: false,
          );
          return;
        }

        state = state.copyWith(
          isBackendReachable: true,
          isOffline: false,
          isSyncingBackend: false,
        );
      }

      _activeCancelToken?.cancel('Superseded by newer request');
      _activeCancelToken = CancelToken();

      final response = await _service.sendChatMessage(
        chatId: chatId,
        message: normalized,
        cancelToken: _activeCancelToken,
      );

      String assistantReply = '';
      for (final item in response.messages.reversed) {
        if (item.role == AiMessageRole.assistant) {
          assistantReply = item.text;
          break;
        }
      }
      if (assistantReply.trim().isNotEmpty) {
        await _writeCache(cacheKey, assistantReply);
      }

      final chats = _upsertChat(state.chats, response.chat);
      _messagesByChat[chatId] = response.messages;

      state = state.copyWith(
        chats: chats,
        messages: response.messages,
        clearError: true,
        isSending: false,
        isBackendReachable: true,
        isOffline: false,
      );
    } on AiServiceException catch (error) {
      if (error.code == 'REQUEST_CANCELLED') {
        state = state.copyWith(isSending: false, isOffline: false);
        return;
      }

      final networkRelated =
          error.code == 'NETWORK_ERROR' ||
          error.code == 'TIMEOUT' ||
          error.code == 'SERVER_UNREACHABLE';

      final cached = _readCachedResponse(cacheKey);
      if (cached != null) {
        await _appendAssistantMessage(
          chatId: chatId,
          text: cached,
          fromCache: true,
          isOffline: false,
        );

        state = state.copyWith(
          error: error.message,
          isSending: false,
          isOffline: networkRelated,
          isBackendReachable: !networkRelated,
        );
        return;
      }

      await _appendAssistantMessage(
        chatId: chatId,
        text: _friendlyFailure(error.message, _detectLanguage(normalized)),
        fromCache: false,
        isOffline: false,
      );

      state = state.copyWith(
        error: error.message,
        isSending: false,
        isOffline: networkRelated,
        isBackendReachable: !networkRelated,
      );
    } catch (error) {
      final normalizedError = _normalizeUnexpectedError(error);
      final backendLikelyDown =
          normalizedError.contains('Network connection failed') ||
          normalizedError.contains('Unable to contact backend');
      final cached = _readCachedResponse(cacheKey);
      if (cached != null) {
        await _appendAssistantMessage(
          chatId: chatId,
          text: cached,
          fromCache: true,
          isOffline: false,
        );
        state = state.copyWith(
          error: normalizedError,
          isSending: false,
          isOffline: backendLikelyDown,
          isBackendReachable: !backendLikelyDown,
        );
        return;
      }

      await _appendAssistantMessage(
        chatId: chatId,
        text: _friendlyFailure(normalizedError, _detectLanguage(normalized)),
        fromCache: false,
        isOffline: false,
      );

      state = state.copyWith(
        error: normalizedError,
        isSending: false,
        isOffline: backendLikelyDown,
        isBackendReachable: !backendLikelyDown,
      );
    } finally {
      state = state.copyWith(isSending: false);
      try {
        await _persistState();
      } catch (_) {
        // Keep messaging flow alive even if local persistence fails.
      }
    }
  }

  Future<void> editAndResendMessage({
    required String messageId,
    required String message,
  }) async {
    final chatId = state.activeChatId;
    if (chatId == null || chatId.trim().isEmpty) {
      state = state.copyWith(error: 'Open a chat before editing messages.');
      return;
    }

    final normalized = normalizeMessage(message);
    if (normalized.isEmpty) return;

    state = state.copyWith(isSending: true, clearError: true);
    try {
      final response = await _service.editAndResendMessage(
        chatId: chatId,
        messageId: messageId,
        message: normalized,
      );

      final chats = _upsertChat(state.chats, response.chat);
      _messagesByChat[chatId] = response.messages;
      state = state.copyWith(
        chats: chats,
        messages: response.messages,
        isSending: false,
        clearError: true,
      );
      await _persistState();
    } on AiServiceException catch (error) {
      state = state.copyWith(isSending: false, error: error.message);
    } catch (_) {
      state = state.copyWith(
        isSending: false,
        error: 'Failed to edit and resend the selected message.',
      );
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _healthTimer?.cancel();
    _connectivitySubscription?.cancel();
    _activeCancelToken?.cancel('Controller disposed');
    super.dispose();
  }

  Future<void> _appendAssistantMessage({
    required String chatId,
    required String text,
    required bool fromCache,
    required bool isOffline,
  }) async {
    final now = DateTime.now();
    final message = AiChatMessage(
      id: now.microsecondsSinceEpoch.toString(),
      chatId: chatId,
      role: AiMessageRole.assistant,
      text: text,
      createdAt: now,
      updatedAt: now,
      fromCache: fromCache,
    );

    final nextMessages = [...state.messages, message];
    _messagesByChat[chatId] = nextMessages;

    state = state.copyWith(messages: nextMessages, isOffline: isOffline);

    await _persistState();
  }

  Future<void> _persistState() async {
    final stateBox = _stateBox;
    if (stateBox == null) return;

    await stateBox.put(
      'chats',
      state.chats.map((item) => item.toMap()).toList(),
    );
    await stateBox.put('activeChatId', state.activeChatId);

    final serializedMessages = <String, List<Map<String, dynamic>>>{};
    _messagesByChat.forEach((chatId, messages) {
      serializedMessages[chatId] = messages
          .map((item) => item.toMap())
          .toList();
    });

    await stateBox.put('messagesByChat', serializedMessages);
  }

  Future<void> _writeCache(String key, String value) async {
    await _cacheBox?.put(key, {
      'reply': value,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  String? _readCachedResponse(String key) {
    final raw = _cacheBox?.get(key);
    if (raw is! Map) return null;

    final replyValue = raw['reply'];
    final createdAtValue = raw['createdAt'];

    final reply = replyValue is String ? replyValue : replyValue?.toString();

    int? createdAt;
    if (createdAtValue is int) {
      createdAt = createdAtValue;
    } else if (createdAtValue is num) {
      createdAt = createdAtValue.toInt();
    } else if (createdAtValue != null) {
      createdAt = int.tryParse(createdAtValue.toString());
    }

    if (reply == null || reply.trim().isEmpty || createdAt == null) {
      return null;
    }

    final age = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(createdAt),
    );

    if (age > _cacheTtl) {
      _cacheBox?.delete(key);
      return null;
    }

    return reply;
  }

  Future<bool> _isOffline() async {
    try {
      final dynamic result = await _connectivity.checkConnectivity();
      if (result is List<ConnectivityResult>) {
        return result.every((item) => item == ConnectivityResult.none);
      }
      if (result is ConnectivityResult) {
        return result == ConnectivityResult.none;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  bool _isNetworkErrorCode(String code) {
    return code == 'NETWORK_ERROR' ||
        code == 'TIMEOUT' ||
        code == 'SERVER_UNREACHABLE';
  }

  String _offlineFallback(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return 'لا يوجد اتصال بالإنترنت حاليا. حاول مرة أخرى لاحقا أو استخدم الردود المحفوظة.';
      case 'fr':
        return 'Vous êtes hors ligne. Reessayez plus tard ou consultez les reponses en cache.';
      default:
        return 'You are currently offline. Try again later or rely on cached responses.';
    }
  }

  String _offlineError(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return 'لا يوجد اتصال، ولا توجد إجابة محفوظة لهذا السؤال.';
      case 'fr':
        return 'Mode hors ligne: aucune reponse en cache pour cette question.';
      default:
        return 'Offline mode: no cached answer found for this question.';
    }
  }

  String _detectLanguage(String text) {
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(text)) {
      return 'ar';
    }

    if (RegExp(
      r'(\bbonjour\b|\bmerci\b|\bquand\b|\bpourquoi\b|\bcomment\b|[éèàùâêîôûç])',
      caseSensitive: false,
    ).hasMatch(text)) {
      return 'fr';
    }

    return 'en';
  }

  String _normalizeUnexpectedError(Object error) {
    final message = error.toString();

    if (message.contains('SocketException')) {
      return 'Network connection failed. Please check your internet.';
    }

    if (message.contains('FormatException') ||
        message.contains('type') && message.contains('is not a subtype')) {
      return 'Invalid response received from AI service.';
    }

    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '').trim();
    }

    if (message.trim().isEmpty) {
      return 'Unexpected error while reaching AI assistant.';
    }

    return message;
  }

  String _friendlyFailure(String technicalMessage, String languageCode) {
    switch (languageCode) {
      case 'ar':
        return 'الخدمة غير متاحة مؤقتا. يرجى المحاولة بعد قليل.';
      case 'fr':
        return 'Le service IA est temporairement indisponible. Veuillez reessayer.';
      default:
        return 'AI service is temporarily unavailable. Please retry shortly.';
    }
  }

  String? _resolveInitialActiveChatId(
    List<AiChatThread> chats,
    String? preferred,
  ) {
    if (chats.isEmpty) return null;
    final preferredId = (preferred ?? '').trim();
    if (preferredId.isNotEmpty) {
      final exists = chats.any((chat) => chat.id == preferredId);
      if (exists) return preferredId;
    }
    return chats.first.id;
  }

  List<AiChatThread> _upsertChat(List<AiChatThread> source, AiChatThread chat) {
    final next = [...source.where((item) => item.id != chat.id), chat];
    next.sort((a, b) {
      final aDate = a.lastMessageAt ?? a.updatedAt;
      final bDate = b.lastMessageAt ?? b.updatedAt;
      return bDate.compareTo(aDate);
    });
    return next;
  }
}
