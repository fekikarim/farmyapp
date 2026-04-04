import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class FarmerAgentScreen extends StatefulWidget {
  final String? landId;

  const FarmerAgentScreen({super.key, this.landId});

  @override
  State<FarmerAgentScreen> createState() => _FarmerAgentScreenState();
}

class _FarmerAgentScreenState extends State<FarmerAgentScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  Map<String, dynamic>? _context;

  @override
  void initState() {
    super.initState();
    _fetchAnalysis(); // Get initial snapshot
  }

  Future<void> _fetchAnalysis() async {
    setState(() => _isLoading = true);
    try {
      final baseUrl = dotenv.get('API_BASE_URL', fallback: 'http://192.168.0.133:3001');
      final response = await AuthService.authenticatedRequest(
        'POST',
        Uri.parse('$baseUrl/api/v1/farmer-agent/analyze'),
        body: jsonEncode({
          if (widget.landId != null) 'landId': widget.landId,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() {
          _context = body['data']['context'];
          _messages.add({
            'role': 'assistant',
            'content': body['data']['analysis'],
            'timestamp': DateTime.now().toIso8601String(),
          });
        });
      }
    } catch (e) {
      debugPrint('FarmerAgentScreen Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    setState(() {
      _messages.add({
        'role': 'user',
        'content': text,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _isLoading = true;
    });

    try {
      // Re-using the analysis endpoint for now but we could add a chat endpoint
      // For brevity, we pass context as "preferences" or prompt
      final baseUrl = dotenv.get('API_BASE_URL', fallback: 'http://192.168.0.133:3001');
      final response = await AuthService.authenticatedRequest(
        'POST',
        Uri.parse('$baseUrl/api/v1/farmer-agent/analyze'),
        body: jsonEncode({
          'landId': widget.landId,
          'question': text, // The backend needs to handle this
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': body['data']['analysis'],
            'timestamp': DateTime.now().toIso8601String(),
          });
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Production Guru'),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          if (_context != null) 
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildSummaryCards(),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _messages.length,
              itemBuilder: (ctx, idx) {
                final msg = _messages[idx];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isUser ? theme.primaryColor : theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                    ),
                    child: MarkdownBody(
                      data: msg['content'],
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(color: isUser ? Colors.white : theme.textTheme.bodyMedium?.color, fontSize: 13, height: 1.4),
                        h1: TextStyle(color: isUser ? Colors.white : theme.textTheme.titleLarge?.color, fontWeight: FontWeight.bold),
                        h2: TextStyle(color: isUser ? Colors.white : theme.textTheme.titleMedium?.color, fontWeight: FontWeight.bold),
                        h3: TextStyle(color: isUser ? Colors.white : theme.textTheme.titleSmall?.color, fontWeight: FontWeight.bold),
                        strong: TextStyle(color: isUser ? Colors.white : theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold),
                        listBullet: TextStyle(color: isUser ? Colors.white70 : theme.textTheme.bodySmall?.color, fontSize: 14),
                        blockquote: BoxDecoration(
                          color: isUser ? Colors.white12 : theme.dividerColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        code: TextStyle(
                          backgroundColor: isUser ? Colors.black26 : theme.dividerColor.withOpacity(0.1),
                          color: isUser ? Colors.white : theme.primaryColor,
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          _buildInputArea(theme),
        ],
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor, 
        border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.1)))
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                decoration: InputDecoration(
                  hintText: 'Ask your guru...',
                  hintStyle: TextStyle(color: theme.hintColor),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.green),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        _statCard('Capital', '${_context!['totalInvested']} TND', Icons.account_balance_wallet, Colors.blue),
        const SizedBox(width: 12),
        _statCard('Producing', '${_context!['activeAssetsCount']}', Icons.eco, Colors.green),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
