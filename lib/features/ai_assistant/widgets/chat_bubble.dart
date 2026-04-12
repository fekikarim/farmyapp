import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';

import '../ai_models.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    this.onCopy,
    this.onSpeak,
    this.onEditResend,
  });

  final AiChatMessage message;
  final VoidCallback? onCopy;
  final VoidCallback? onSpeak;
  final VoidCallback? onEditResend;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == AiMessageRole.user;
    final theme = Theme.of(context);
    final assistantTextColor = theme.brightness == Brightness.dark
        ? const Color(0xFFF3F4F6)
        : const Color(0xFF1F2937);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF2C8A55) : theme.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          border: isUser
              ? null
              : Border.all(color: theme.dividerColor.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (isUser)
              Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  height: 1.45,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              MarkdownBody(
                data: message.text,
                shrinkWrap: true,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    color: assistantTextColor,
                    fontSize: 15.5,
                    height: 1.5,
                  ),
                  listBullet: TextStyle(
                    color: assistantTextColor,
                    fontSize: 14.5,
                    height: 1.45,
                  ),
                  strong: TextStyle(
                    color: assistantTextColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.5,
                  ),
                ),
              ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEditResend != null)
                  IconButton(
                    onPressed: onEditResend,
                    visualDensity: VisualDensity.compact,
                    iconSize: 15,
                    splashRadius: 16,
                    tooltip: 'Edit and resend',
                    color: isUser ? Colors.white70 : theme.iconTheme.color,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                if (onCopy != null)
                  IconButton(
                    onPressed: onCopy,
                    visualDensity: VisualDensity.compact,
                    iconSize: 15,
                    splashRadius: 16,
                    tooltip: 'Copy',
                    color: isUser ? Colors.white70 : theme.iconTheme.color,
                    icon: const Icon(Icons.content_copy_outlined),
                  ),
                if (onSpeak != null)
                  IconButton(
                    onPressed: onSpeak,
                    visualDensity: VisualDensity.compact,
                    iconSize: 15,
                    splashRadius: 16,
                    tooltip: 'Read aloud',
                    color: isUser ? Colors.white70 : theme.iconTheme.color,
                    icon: const Icon(Icons.volume_up_outlined),
                  ),
                if (message.fromCache)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      'Cached',
                      style: TextStyle(
                        color: isUser
                            ? Colors.white70
                            : theme.textTheme.bodySmall?.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Text(
                  DateFormat('HH:mm').format(message.createdAt),
                  style: TextStyle(
                    color: isUser ? Colors.white70 : Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
