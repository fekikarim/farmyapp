import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:farmyapp/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'ai_controller.dart';
import 'ai_models.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/typing_indicator.dart';

class AiAssistantScreen extends ConsumerStatefulWidget {
  final String? initialMessage;
  final String? initialLocation;
  final String? initialCrop;

  const AiAssistantScreen({
    super.key,
    this.initialMessage,
    this.initialLocation,
    this.initialCrop,
  });

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _voiceReady = false;
  bool _isListening = false;
  bool _voiceOutputEnabled = true;
  bool _isTogglingListening = false;
  int _voiceSessionToken = 0;
  String _recognizedText = '';

  int _lastMessageCount = 0;
  bool _lastSendingState = false;
  String? _lastSpokenMessageId;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    Future<void>.microtask(() async {
      await ref.read(aiAssistantControllerProvider.notifier).initialize();
      if (_isDisposed || !mounted) return;
      await _initializeVoice();
      if (_isDisposed || !mounted) return;

      if ((widget.initialMessage ?? '').trim().isNotEmpty) {
        _messageController.text = widget.initialMessage!.trim();
        await _sendMessage();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _speechToText.stop();
    _tts.stop();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeVoice() async {
    final available = await _speechToText.initialize(
      onStatus: (status) {
        if (_isDisposed || !mounted) return;
        final lowered = status.toLowerCase();
        if (lowered == 'notlistening' || lowered == 'done') {
          _voiceSessionToken += 1;
          _recognizedText = '';
          setState(() => _isListening = false);
        }
      },
      onError: (_) {
        if (_isDisposed || !mounted) return;
        _voiceSessionToken += 1;
        _recognizedText = '';
        setState(() => _isListening = false);
      },
    );

    await _tts.awaitSpeakCompletion(true);
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.47);

    if (_isDisposed || !mounted) return;
    setState(() {
      _voiceReady = available;
    });
  }

  Future<void> _toggleListening(AiAssistantState state) async {
    if (_isDisposed || !mounted || _isTogglingListening) return;

    _isTogglingListening = true;

    if (!_voiceReady) {
      _isTogglingListening = false;
      if (_isDisposed || !mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.voiceInputNotAvailable),
        ),
      );
      return;
    }

    try {
      if (_isListening) {
        // Invalidate current callbacks before awaiting stop so no stale text
        // can be injected while the button is visually in disabled state.
        _voiceSessionToken += 1;
        if (!_isDisposed && mounted) {
          setState(() => _isListening = false);
        }
        await _speechToText.stop();
        _recognizedText = '';
        return;
      }

      // Start each voice session from a clean state so transcripts never accumulate.
      if (!_isDisposed && mounted) {
        // Optimistic state update so icon changes instantly when user taps mic.
        setState(() => _isListening = true);
      }
      await _speechToText.cancel();
      _voiceSessionToken += 1;
      final sessionToken = _voiceSessionToken;
      _recognizedText = '';
      _messageController.clear();

      final localeId = _speechLocaleId(_messageController.text);

      final started = await _speechToText.listen(
        localeId: localeId,
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
          partialResults: true,
        ),
        onResult: (result) {
          if (_isDisposed || !mounted) return;
          if (sessionToken != _voiceSessionToken) return;

          _recognizedText = result.recognizedWords;
          setState(() {
            // Always replace, never append.
            _messageController.text = _recognizedText;
            _messageController.selection = TextSelection.fromPosition(
              TextPosition(offset: _messageController.text.length),
            );
          });

          if (result.finalResult && !_isDisposed && mounted) {
            if (sessionToken != _voiceSessionToken) return;
            _voiceSessionToken += 1;
            _recognizedText = '';
            setState(() => _isListening = false);
          }
        },
      );

      if (!started) {
        _voiceSessionToken += 1;
        _recognizedText = '';
        if (!_isDisposed && mounted) {
          setState(() => _isListening = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.unableToStartVoiceInput,
              ),
            ),
          );
        }
      }
    } finally {
      _isTogglingListening = false;
    }
  }

  Future<void> _speakAssistantMessage(String text) async {
    if (_isDisposed || !_voiceOutputEnabled || text.trim().isEmpty) return;

    final languageCode = _ttsLanguageCode(text);

    await _tts.stop();
    if (_isDisposed || !_voiceOutputEnabled) return;
    await _tts.setLanguage(languageCode);
    if (_isDisposed || !_voiceOutputEnabled) return;
    await _tts.speak(_cleanForTts(text));
  }

  Future<void> _toggleVoiceOutput() async {
    if (_isDisposed || !mounted) return;

    final nextValue = !_voiceOutputEnabled;

    if (!nextValue) {
      // Muting must immediately stop any speech already in progress.
      await _tts.stop();
    }

    if (_isDisposed || !mounted) return;
    setState(() {
      _voiceOutputEnabled = nextValue;
    });
  }

  Future<void> _speakMessageFromBubble(AiChatMessage message) async {
    if (_isDisposed || !mounted) return;

    if (!_voiceOutputEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.voiceOutputMuted),
        ),
      );
      return;
    }

    final text = message.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.messageNoReadableText)),
      );
      return;
    }

    _lastSpokenMessageId = message.id;
    try {
      await _speakAssistantMessage(text);
    } catch (_) {
      if (_isDisposed || !mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.unableToPlayVoiceOutput)),
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_isDisposed || !mounted) return;

    final raw = _messageController.text.trim();
    if (raw.isEmpty) return;

    if (_isListening) {
      _voiceSessionToken += 1;
      await _speechToText.stop();
      _recognizedText = '';
      if (!_isDisposed && mounted) {
        setState(() => _isListening = false);
      }
    }

    _messageController.clear();

    try {
      await ref
          .read(aiAssistantControllerProvider.notifier)
          .sendMessage(message: raw);

      if (_isDisposed || !mounted) return;
    } catch (_) {
      if (_isDisposed || !mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.couldNotSendMessage),
        ),
      );
    }
  }

  Future<void> _editAndResend(AiChatMessage message) async {
    if (_isDisposed || !mounted) return;
    var editedText = message.text;

    final nextMessage = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.editAndResend),
          content: TextFormField(
            initialValue: editedText,
            onChanged: (value) => editedText = value,
            minLines: 2,
            maxLines: 6,
            autofocus: true,
            onFieldSubmitted: (value) {
              Navigator.of(dialogContext).pop(value);
            },
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.updateYourMessage,
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(editedText),
              child: Text(AppLocalizations.of(context)!.resend),
            ),
          ],
        );
      },
    );

    if (_isDisposed || !mounted) return;
    final normalized = (nextMessage ?? '').trim();

    if (normalized.isEmpty) return;

    await ref
        .read(aiAssistantControllerProvider.notifier)
        .editAndResendMessage(messageId: message.id, message: normalized);
  }

  Future<void> _copyAssistantText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (_isDisposed || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.responseCopied)),
    );
  }

  Future<void> _openRenameChatDialog(AiChatThread chat) async {
    if (_isDisposed || !mounted) return;
    var titleDraft = chat.title;

    final nextTitle = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.renameChat),
        content: TextFormField(
          initialValue: titleDraft,
          onChanged: (value) => titleDraft = value,
          autofocus: true,
          maxLength: 180,
          onFieldSubmitted: (value) {
            Navigator.of(dialogContext).pop(value);
          },
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.chatTitle,
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(titleDraft),
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );

    if (_isDisposed || !mounted) return;
    final normalized = (nextTitle ?? '').trim();
    if (normalized.isEmpty) {
      return;
    }

    if (normalized != chat.title.trim()) {
      await ref
          .read(aiAssistantControllerProvider.notifier)
          .renameChat(chatId: chat.id, title: normalized);
    }
  }

  Future<void> _confirmDeleteChat(AiChatThread chat) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteChat),
        content: Text(AppLocalizations.of(context)!.deleteChatConfirmation(chat.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC63D3D),
            ),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (_isDisposed || !mounted) return;
    if (shouldDelete == true) {
      await ref
          .read(aiAssistantControllerProvider.notifier)
          .deleteChat(chat.id);
    }
  }

  void _handleChatMenuAction(String action, AiChatThread chat) {
    if (action == 'rename') {
      _openRenameChatDialog(chat);
      return;
    }

    if (action == 'delete') {
      _confirmDeleteChat(chat);
    }
  }

  bool _isCompactTopBar(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 420;
  }

  Future<void> _closeAssistantScreen() async {
    if (_isDisposed || !mounted) return;

    if (_isListening) {
      await _speechToText.stop();
      if (_isDisposed || !mounted) return;
      setState(() => _isListening = false);
    }

    await _tts.stop();
    if (_isDisposed || !mounted) return;

    await Navigator.of(context).maybePop();
  }

  void _handleTopBarAction(String value) {
    if (_isDisposed || !mounted) return;

    if (value == 'sync') {
      ref.read(aiAssistantControllerProvider.notifier).refreshBackendStatus();
      return;
    }

    if (value == 'new') {
      ref.read(aiAssistantControllerProvider.notifier).createChat();
    }
  }

  void _scrollToBottom() {
    if (_isDisposed || !mounted) return;
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiAssistantControllerProvider);
    final sendingJustFinished = _lastSendingState && !state.isSending;
    final compactTopBar = _isCompactTopBar(context);

    if (_lastMessageCount != state.messages.length ||
        _lastSendingState != state.isSending) {
      _lastMessageCount = state.messages.length;
      _lastSendingState = state.isSending;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isDisposed || !mounted) return;
        _scrollToBottom();
      });
    }

    if (sendingJustFinished && state.messages.isNotEmpty) {
      final lastMessage = state.messages.last;
      if (_voiceOutputEnabled &&
          lastMessage.role == AiMessageRole.assistant &&
          _lastSpokenMessageId != lastMessage.id) {
        _lastSpokenMessageId = lastMessage.id;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (_isDisposed || !mounted) return;
          try {
            await _speakAssistantMessage(lastMessage.text);
          } catch (_) {
            // Keep chat flow responsive if TTS fails.
          }
        });
      }
    }

    final theme = Theme.of(context);
    final activeChat = state.activeChat;

    return Scaffold(
      drawer: _buildChatDrawer(state),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C8A55),
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Text(
                activeChat?.title ?? AppLocalizations.of(context)!.aiAssistant,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: state.isOffline || !state.isBackendReachable
                    ? const Color(0xFFFFCC80)
                    : const Color(0xFF9EF5C8),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _voiceOutputEnabled
                ? AppLocalizations.of(context)!.muteVoiceOutput
                : AppLocalizations.of(context)!.enableVoiceOutput,
            onPressed: () async {
              await _toggleVoiceOutput();
            },
            icon: Icon(
              _voiceOutputEnabled ? Icons.volume_up : Icons.volume_off,
            ),
          ),
          if (compactTopBar)
            PopupMenuButton<String>(
              tooltip: AppLocalizations.of(context)!.moreActions,
              onSelected: _handleTopBarAction,
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'sync',
                  child: Text(AppLocalizations.of(context)!.syncBackend),
                ),
                PopupMenuItem<String>(value: 'new', child: Text(AppLocalizations.of(context)!.newChat)),
              ],
            )
          else ...[
            IconButton(
              tooltip: AppLocalizations.of(context)!.syncBackend,
              onPressed: () {
                ref
                    .read(aiAssistantControllerProvider.notifier)
                    .refreshBackendStatus();
              },
              icon: const Icon(Icons.sync),
            ),
            IconButton(
              tooltip: AppLocalizations.of(context)!.newChat,
              onPressed: () {
                ref.read(aiAssistantControllerProvider.notifier).createChat();
              },
              icon: const Icon(Icons.add_comment_outlined),
            ),
          ],
          IconButton(
            tooltip: AppLocalizations.of(context)!.closeAssistant,
            onPressed: () async {
              await _closeAssistantScreen();
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Column(
        children: [
          if (state.isSyncingBackend)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: const Color(0xFFE4F2FF),
              child: Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.syncingWithBackend,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0D4A7A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (!state.isOffline && !state.isBackendReachable)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: const Color(0xFFFFF1D6),
              child: Row(
                children: [
                  Icon(Icons.sync_problem, size: 16, color: Color(0xFF8A5A00)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.backendDisconnected,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8A5A00),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (state.isOffline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: const Color(0xFFFFF4D1),
              child: Row(
                children: [
                  Icon(Icons.wifi_off, size: 16, color: Color(0xFFA06A00)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.offlineModeCached,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFA06A00),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: !state.hasActiveChat
                ? _buildNoChatState(theme)
                : state.messages.isEmpty
                ? _buildEmptyState(theme)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    itemCount:
                        state.messages.length + (state.isSending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.messages.length) {
                        return const TypingIndicator();
                      }

                      final message = state.messages[index];
                      final canEdit =
                          message.role == AiMessageRole.user &&
                          !state.isSending;
                      final canCopy = message.role == AiMessageRole.assistant;
                      final canSpeak = message.role == AiMessageRole.assistant;

                      return ChatBubble(
                        message: message,
                        onCopy: canCopy
                            ? () => _copyAssistantText(message.text)
                            : null,
                        onSpeak: canSpeak
                            ? () => _speakMessageFromBubble(message)
                            : null,
                        onEditResend: canEdit
                            ? () => _editAndResend(message)
                            : null,
                      );
                    },
                  ),
          ),
          if ((state.error ?? '').isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEFEF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFD1D1)),
              ),
              child: Text(
                state.error!,
                style: const TextStyle(
                  color: Color(0xFF8A1F1F),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          _buildComposer(state),
        ],
      ),
    );
  }

  Widget _buildChatDrawer(AiAssistantState state) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.conversations,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: AppLocalizations.of(context)!.newChat,
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await ref
                          .read(aiAssistantControllerProvider.notifier)
                          .createChat();
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: state.chats.isEmpty
                  ? Center(child: Text(AppLocalizations.of(context)!.noConversationsYet))
                  : ListView.separated(
                      itemCount: state.chats.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final chat = state.chats[index];
                        final isActive = chat.id == state.activeChatId;
                        return ListTile(
                          selected: isActive,
                          selectedTileColor: const Color(
                            0xFF2C8A55,
                          ).withValues(alpha: 0.08),
                          leading: Icon(
                            isActive
                                ? Icons.forum_rounded
                                : Icons.chat_bubble_outline,
                            color: isActive
                                ? const Color(0xFF2C8A55)
                                : Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          title: Text(
                            chat.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: (chat.lastPreview ?? '').trim().isNotEmpty
                              ? Text(
                                  chat.lastPreview!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          onTap: () async {
                            Navigator.of(context).pop();
                            await ref
                                .read(aiAssistantControllerProvider.notifier)
                                .selectChat(chat.id);
                          },
                          trailing: PopupMenuButton<String>(
                            onSelected: (action) =>
                                _handleChatMenuAction(action, chat),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'rename',
                                child: Text(AppLocalizations.of(context)!.rename),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(AppLocalizations.of(context)!.delete),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoChatState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.forum_outlined,
              size: 52,
              color: Color(0xFF2C8A55),
            ),
            const SizedBox(height: 14),
            Text(
              AppLocalizations.of(context)!.startANewConversation,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.createChatDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                ref.read(aiAssistantControllerProvider.notifier).createChat();
              },
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)!.newChat),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF2C8A55).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: Color(0xFF2C8A55),
                size: 42,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              AppLocalizations.of(context)!.askAnythingAboutFarm,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.aiAssistantDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.7,
                ),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer(AiAssistantState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.12),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Semantics(
              button: true,
              label: AppLocalizations.of(context)!.voiceInput,
              child: Material(
                color: _isListening
                    ? const Color(0xFFE85151)
                    : const Color(0xFF2C8A55),
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: _isListening
                      ? AppLocalizations.of(context)!.disableVoiceInput
                      : AppLocalizations.of(context)!.enableVoiceInput,
                  onPressed: state.isSending
                      ? null
                      : () => _toggleListening(state),
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_off,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 4,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  if (!state.isSending) {
                    _sendMessage();
                  }
                },
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.askFarmingQuestion,
                  hintStyle: TextStyle(
                    fontSize: 15,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.72),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              button: true,
              label: AppLocalizations.of(context)!.sendMessage,
              child: Material(
                color: state.isSending ? Colors.grey : const Color(0xFF2C8A55),
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: state.isSending ? null : _sendMessage,
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _speechLocaleId(String message) {
    final code = _languageCode(message);
    switch (code) {
      case 'ar':
        return 'ar_TN';
      case 'fr':
        return 'fr_FR';
      default:
        return 'en_US';
    }
  }

  String _ttsLanguageCode(String message) {
    final code = _languageCode(message);
    switch (code) {
      case 'ar':
        return 'ar-TN';
      case 'fr':
        return 'fr-FR';
      default:
        return 'en-US';
    }
  }

  String _languageCode(String text) {
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

  String _cleanForTts(String input) {
    return input
        .replaceAll(RegExp(r'\*\*|__|`|#+\s*'), ' ')
        .replaceAll(RegExp(r'\[(.*?)\]\((.*?)\)'), r'$1')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
