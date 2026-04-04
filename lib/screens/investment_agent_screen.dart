import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/investment_agent_service.dart';
import 'package:intl/intl.dart';

class InvestmentAgentScreen extends StatefulWidget {
  const InvestmentAgentScreen({super.key});

  @override
  State<InvestmentAgentScreen> createState() => _InvestmentAgentScreenState();
}

class _InvestmentAgentScreenState extends State<InvestmentAgentScreen> {
  final InvestmentAgentService _agentService = InvestmentAgentService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  
  List<Map<String, dynamic>> _messages = [];
  List<dynamic> _availableFarms = [];
  String? _sessionId;
  bool _isLoading = false;
  List<dynamic> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _agentService.getSessionHistory();
    setState(() {
      _history = history;
    });
  }

  Future<void> _loadSession(String sessionId) async {
    setState(() => _isLoading = true);
    final session = await _agentService.getSessionDetails(sessionId);
    if (session != null) {
      setState(() {
        _sessionId = sessionId;
        _messages = List<Map<String, dynamic>>.from(session['messages']);
        _availableFarms = session['context_data'] ?? [];
      });
      Navigator.pop(context); // Close drawer
      _scrollToBottom();
    }
    setState(() => _isLoading = false);
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
    _scrollToBottom();

    try {
      final result = await _agentService.getRecommendations(text, sessionId: _sessionId);
      if (result != null) {
        setState(() {
          _sessionId = result['sessionId'];
          _messages = List<Map<String, dynamic>>.from(result['history']);
          _availableFarms = result['farms'] ?? [];
        });
        _scrollToBottom();
        _loadHistory();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to reach AI Strategy Analyst.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strategic Portfolio Analyst'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () {
              setState(() {
                _sessionId = null;
                _messages = [];
                _availableFarms = [];
              });
            },
            tooltip: 'New Session',
          )
        ],
      ),
      drawer: _buildHistoryDrawer(),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty ? _buildWelcome() : _buildChatList(),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildHistoryDrawer() {
    final theme = Theme.of(context);
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: theme.primaryColor),
            child: const Center(
              child: Text(
                'Investment Strategy Chronicles',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final session = _history[index];
                final date = DateTime.parse(session['createdAt']);
                return ListTile(
                  leading: const Icon(Icons.history_edu),
                  title: Text(session['title'] ?? 'Strategy Session', maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(DateFormat('MMM d, HH:mm').format(date)),
                  onTap: () => _loadSession(session['id']),
                  selected: _sessionId == session['id'],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_graph, size: 64, color: Theme.of(context).primaryColor.withOpacity(0.5)),
            const SizedBox(height: 24),
            const Text(
              'Welcome to Strategic Analysis',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tell me your budget and risk preference, and I will draft a diversified portfolio across our top performing farms.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _chatScrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isUser = msg['role'] == 'user';
        
        return Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: isUser ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: isUser ? null : Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: isUser
                  ? Text(msg['content'], style: const TextStyle(color: Colors.white))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MarkdownBody(
                          data: msg['content'].toString(),
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                          ),
                        ),
                        if (index == _messages.length - 1 && !isUser && _availableFarms.isNotEmpty)
                          _buildFarmSuggestions(),
                      ],
                    ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildFarmSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          child: Text('Discussed Farms:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _availableFarms.length,
            itemBuilder: (context, fIdx) {
              final farm = _availableFarms[fIdx];
              return InkWell(
                onTap: () {
                  _messageController.text = "Tell me more about ${farm['name']}. Why is it a good choice?";
                },
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(farm['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('\$${farm['price']}', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.wb_sunny_outlined, size: 10, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(farm['weatherRiskScore'], style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInputArea() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Enter preferences or ask details...',
                  hintStyle: const TextStyle(fontSize: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: theme.scaffoldBackgroundColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: theme.primaryColor,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
