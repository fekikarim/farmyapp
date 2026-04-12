import 'dart:convert';

enum AiMessageRole { user, assistant, system }

class AiChatThread {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastMessageAt;
  final String? lastPreview;

  const AiChatThread({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageAt,
    this.lastPreview,
  });

  AiChatThread copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastMessageAt,
    String? lastPreview,
    bool clearLastMessageAt = false,
    bool clearLastPreview = false,
  }) {
    return AiChatThread(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessageAt: clearLastMessageAt
          ? null
          : (lastMessageAt ?? this.lastMessageAt),
      lastPreview: clearLastPreview ? null : (lastPreview ?? this.lastPreview),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'lastPreview': lastPreview,
    };
  }

  factory AiChatThread.fromMap(Map<dynamic, dynamic> map) {
    final createdAt =
        DateTime.tryParse((map['createdAt'] as String?) ?? '') ??
        DateTime.now();

    return AiChatThread(
      id:
          (map['id'] as String?) ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: ((map['title'] as String?) ?? 'New chat').trim(),
      createdAt: createdAt,
      updatedAt:
          DateTime.tryParse((map['updatedAt'] as String?) ?? '') ?? createdAt,
      lastMessageAt: DateTime.tryParse((map['lastMessageAt'] as String?) ?? ''),
      lastPreview: (map['lastPreview'] as String?)?.trim(),
    );
  }
}

class AiChatMessage {
  final String id;
  final String chatId;
  final AiMessageRole role;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? editedFromMessageId;
  final bool fromCache;

  const AiChatMessage({
    required this.id,
    required this.chatId,
    required this.role,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    this.editedFromMessageId,
    this.fromCache = false,
  });

  AiChatMessage copyWith({
    String? id,
    String? chatId,
    AiMessageRole? role,
    String? text,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? editedFromMessageId,
    bool clearEditedFromMessageId = false,
    bool? fromCache,
  }) {
    return AiChatMessage(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      role: role ?? this.role,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      editedFromMessageId: clearEditedFromMessageId
          ? null
          : (editedFromMessageId ?? this.editedFromMessageId),
      fromCache: fromCache ?? this.fromCache,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'chat_id': chatId,
      'role': role.name,
      'text': text,
      'content': text,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'editedFromMessageId': editedFromMessageId,
      'edited_from_message_id': editedFromMessageId,
      'fromCache': fromCache,
    };
  }

  factory AiChatMessage.fromMap(Map<dynamic, dynamic> map) {
    final roleName = (map['role'] as String?) ?? AiMessageRole.assistant.name;
    final createdAt =
        DateTime.tryParse((map['createdAt'] as String?) ?? '') ??
        DateTime.now();

    final resolvedRole = switch (roleName) {
      'user' => AiMessageRole.user,
      'system' => AiMessageRole.system,
      _ => AiMessageRole.assistant,
    };

    return AiChatMessage(
      id:
          (map['id'] as String?) ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: (map['chatId'] as String?) ?? (map['chat_id'] as String?) ?? '',
      role: resolvedRole,
      text: (map['text'] as String?) ?? (map['content'] as String?) ?? '',
      createdAt: createdAt,
      updatedAt:
          DateTime.tryParse((map['updatedAt'] as String?) ?? '') ?? createdAt,
      editedFromMessageId:
          (map['editedFromMessageId'] as String?) ??
          (map['edited_from_message_id'] as String?),
      fromCache: (map['fromCache'] as bool?) ?? false,
    );
  }
}

class AiAssistantState {
  final List<AiChatThread> chats;
  final String? activeChatId;
  final List<AiChatMessage> messages;
  final bool isLoadingChats;
  final bool isLoadingMessages;
  final bool isSending;
  final String? error;
  final bool isOffline;
  final bool isBackendReachable;
  final bool isSyncingBackend;

  const AiAssistantState({
    this.chats = const [],
    this.activeChatId,
    this.messages = const [],
    this.isLoadingChats = false,
    this.isLoadingMessages = false,
    this.isSending = false,
    this.error,
    this.isOffline = false,
    this.isBackendReachable = true,
    this.isSyncingBackend = false,
  });

  bool get hasActiveChat =>
      activeChatId != null && activeChatId!.trim().isNotEmpty;

  AiChatThread? get activeChat {
    final id = activeChatId;
    if (id == null) return null;

    for (final chat in chats) {
      if (chat.id == id) {
        return chat;
      }
    }
    return null;
  }

  AiAssistantState copyWith({
    List<AiChatThread>? chats,
    String? activeChatId,
    bool clearActiveChatId = false,
    List<AiChatMessage>? messages,
    bool? isLoadingChats,
    bool? isLoadingMessages,
    bool? isSending,
    String? error,
    bool clearError = false,
    bool? isOffline,
    bool? isBackendReachable,
    bool? isSyncingBackend,
  }) {
    return AiAssistantState(
      chats: chats ?? this.chats,
      activeChatId: clearActiveChatId
          ? null
          : (activeChatId ?? this.activeChatId),
      messages: messages ?? this.messages,
      isLoadingChats: isLoadingChats ?? this.isLoadingChats,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : (error ?? this.error),
      isOffline: isOffline ?? this.isOffline,
      isBackendReachable: isBackendReachable ?? this.isBackendReachable,
      isSyncingBackend: isSyncingBackend ?? this.isSyncingBackend,
    );
  }
}

String normalizeMessage(String input) {
  return input.trim().replaceAll(RegExp(r'\s+'), ' ');
}

String cacheKeyForQuestion({required String chatId, required String message}) {
  final source = jsonEncode({
    'chatId': chatId,
    'message': normalizeMessage(message).toLowerCase(),
  });

  return base64UrlEncode(utf8.encode(source));
}
