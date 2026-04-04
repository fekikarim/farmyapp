import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class FarmerAgentScreen extends StatefulWidget {
  final String? landId;
  final String? initialMessage;
  final Map<String, dynamic>? initialContext;

  const FarmerAgentScreen({super.key, this.landId, this.initialMessage, this.initialContext});

  @override
  State<FarmerAgentScreen> createState() => _FarmerAgentScreenState();
}

class _FarmerAgentScreenState extends State<FarmerAgentScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  List<dynamic> _history = [];
  String? _sessionId;
  bool _isLoading = false;
  Map<String, dynamic>? _context;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    if (widget.initialMessage != null) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
        _messageController.text = widget.initialMessage!;
        _sendMessage();
      });
    } else {
      _fetchAnalysis(); // Get initial snapshot
    }
  }

  Future<void> _loadHistory() async {
    try {
      final baseUrl = dotenv.get('API_BASE_URL', fallback: 'http://192.168.0.133:3001');
      final response = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse('$baseUrl/api/v1/farmer-agent/history'),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() {
          _history = body['data'];
        });
      }
    } catch (e) {
      debugPrint('FarmerAgent History Error: $e');
    }
  }

  Future<void> _loadSession(String sessionId) async {
    setState(() => _isLoading = true);
    try {
      final baseUrl = dotenv.get('API_BASE_URL', fallback: 'http://192.168.0.133:3001');
      final response = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse('$baseUrl/api/v1/farmer-agent/session/$sessionId'),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final session = body['data'];
        setState(() {
          _sessionId = sessionId;
          _messages = List<Map<String, dynamic>>.from(session['messages'] ?? []);
          _context = session['context_data'];
        });
        Navigator.pop(context); // Close drawer
      }
    } catch (e) {
      debugPrint('FarmerAgent Load Session Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSession(String sessionId) async {
    try {
      final baseUrl = dotenv.get('API_BASE_URL', fallback: 'http://192.168.0.133:3001');
      final response = await AuthService.authenticatedRequest(
        'DELETE',
        Uri.parse('$baseUrl/api/v1/farmer-agent/session/$sessionId'),
      );
      if (response.statusCode == 200) {
        if (_sessionId == sessionId) {
          setState(() {
            _sessionId = null;
            _messages = [];
            _context = null;
          });
        }
        _loadHistory();
      }
    } catch (e) {
      debugPrint('FarmerAgent Delete Error: $e');
    }
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
          if (_sessionId != null) 'sessionId': _sessionId,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() {
          _context = body['data']['context'];
          _sessionId = body['data']['sessionId'];
          _messages.add({
            'role': 'assistant',
            'content': body['data']['analysis'],
            'timestamp': DateTime.now().toIso8601String(),
          });
        });
        _loadHistory();
        Future.delayed(const Duration(milliseconds: 100), () => _scrollToBottom());
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
      final baseUrl = dotenv.get('API_BASE_URL', fallback: 'http://192.168.0.133:3001');
      final response = await AuthService.authenticatedRequest(
        'POST',
        Uri.parse('$baseUrl/api/v1/farmer-agent/analyze'),
        body: jsonEncode({
          'landId': widget.landId,
          'question': text,
          'sessionId': _sessionId,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() {
          _sessionId = body['data']['sessionId'];
          _messages.add({
            'role': 'assistant',
            'content': body['data']['analysis'],
            'timestamp': DateTime.now().toIso8601String(),
          });
        });
        _loadHistory();
        Future.delayed(const Duration(milliseconds: 100), () => _scrollToBottom());
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
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: 'Session History',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () {
              setState(() {
                _sessionId = null;
                _messages = [];
                _context = null;
              });
              _fetchAnalysis();
            },
            tooltip: 'New Session',
          )
        ],
      ),
      endDrawer: _buildHistoryDrawer(),
      body: Column(
        children: [
          if (_context != null) 
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildSummaryCards(),
            ),
          Expanded(
            child: ListView.builder(
              controller: _chatScrollController,
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
                        blockquoteDecoration: BoxDecoration(
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

  void _scrollToBottom() {
    if (_chatScrollController.hasClients) {
      _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildHistoryDrawer() {
    final theme = Theme.of(context);
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green.shade800),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_edu_rounded, color: Colors.white, size: 40),
                  SizedBox(height: 12),
                  Text(
                    'Harvest Chronicles',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _history.isEmpty
                ? const Center(child: Text('No history yet'))
                : ListView.builder(
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final session = _history[index];
                      final date = DateTime.parse(session['createdAt']);
                      return ListTile(
                        leading: const Icon(Icons.forum_outlined, color: Colors.green),
                        title: Text(session['title'] ?? 'Farm Analysis', maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(DateFormat('MMM d, HH:mm').format(date)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                          onPressed: () => _deleteSession(session['id']),
                        ),
                        onTap: () => _loadSession(session['id']),
                        selected: _sessionId == session['id'],
                        selectedTileColor: Colors.green.withOpacity(0.1),
                      );
                    },
                  ),
          ),
        ],
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
