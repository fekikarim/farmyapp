import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:marquee/marquee.dart';
import '../services/investment_agent_service.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/land_model.dart';
import 'investor/land_details_screen.dart';
import '../services/land_service.dart';
import '../services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:farmyapp/l10n/app_localizations.dart';

class InvestmentAgentScreen extends StatefulWidget {
  final Map<String, dynamic>? initialContext;
  final String? initialMessage;

  const InvestmentAgentScreen({
    super.key,
    this.initialContext,
    this.initialMessage,
  });

  @override
  State<InvestmentAgentScreen> createState() => _InvestmentAgentScreenState();
}

class _InvestmentAgentScreenState extends State<InvestmentAgentScreen> {
  final InvestmentAgentService _agentService = InvestmentAgentService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  
  List<Map<String, dynamic>> _messages = [];
  List<dynamic> _availableFarms = [];
  Map<String, dynamic>? _lastTools;
  String? _sessionId;
  bool _isLoading = false;
  List<dynamic> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    if (widget.initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendInitialMessage();
      });
    }
  }

  void _sendInitialMessage() {
    _messageController.text = widget.initialMessage!;
    _sendMessage(userContext: widget.initialContext);
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
        _messages = List<Map<String, dynamic>>.from(session['messages'] ?? []);
        _availableFarms = session['context_data'] ?? [];
      });
      Navigator.pop(context); // Close drawer
      _scrollToBottom();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _deleteSession(String sessionId) async {
    final success = await _agentService.deleteSession(sessionId);
    if (success) {
      if (_sessionId == sessionId) {
        setState(() {
          _sessionId = null;
          _messages = [];
          _availableFarms = [];
        });
      }
      _loadHistory();
    }
  }

  void _sendMessage({Map<String, dynamic>? userContext}) async {
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
      final result = await _agentService.getRecommendations(text, sessionId: _sessionId, userContext: userContext);
      if (result != null && mounted) {
        setState(() {
          _sessionId = result['sessionId'];
          _messages = List<Map<String, dynamic>>.from(result['history'] ?? []);
          _availableFarms = result['farms'] ?? [];
          _lastTools = result['tools'];
        });
        _scrollToBottom();
        _loadHistory();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.failedReachAnalyst)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
        title: Text(AppLocalizations.of(context)!.strategicPortfolioAnalystTitle),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Credits display
          Consumer<AuthProvider>(
            builder: (context, auth, _) => Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.green, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${auth.user?.credits.toStringAsFixed(2) ?? "0.00"}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: AppLocalizations.of(context)!.sessionHistoryTooltip,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () {
              setState(() {
                _sessionId = null;
                _messages = [];
                _availableFarms = [];
                _lastTools = null;
              });
            },
            tooltip: AppLocalizations.of(context)!.newSessionTooltip,
          )
        ],
      ),
      endDrawer: _buildHistoryDrawer(),
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
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.investmentStrategyChroniclesTitle,
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
                  title: Text(session['title'] ?? AppLocalizations.of(context)!.strategySessionDefault, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(DateFormat('MMM d, HH:mm').format(date)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                    onPressed: () => _deleteSession(session['id']),
                  ),
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
            Text(
              AppLocalizations.of(context)!.welcomeStrategicAnalysis,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.investmentAgentWelcomeDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
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
                          shrinkWrap: true,
                          onTapLink: (text, href, title) {
                            if (href != null) {
                              _handleInteractiveLink(href);
                            }
                          },
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 13, height: 1.4),
                            a: TextStyle(color: Theme.of(context).primaryColor, decoration: TextDecoration.underline, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (index == _messages.length - 1 && !isUser) ...[
                          if (_lastTools != null) _buildLiveToolsRow(),
                          if (_availableFarms.isNotEmpty) _buildFarmSuggestions(),
                        ],
                      ],
                    ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildLiveToolsRow() {
    final market = _lastTools?['market'];
    final weather = _lastTools?['weather'];

    // Handle API-Ninjas structure: {'Wheat': { price: ...}, ...}
    String marketDisplay = 'Stable';
    if (market != null) {
      if (market is Map && market.containsKey('Wheat')) {
        final wheat = market['Wheat'];
        final price = (wheat is Map) ? wheat['price'] : wheat;
        if (price != null) {
          final priceStr = price.toString();
          // Only add $ if it doesn't already have a prefix (like "Simulated" or "$")
          if (priceStr.startsWith('Simulated') || priceStr.startsWith('\$')) {
            marketDisplay = "Wheat: $priceStr";
          } else {
            marketDisplay = "Wheat: \$$priceStr";
          }
        }
      } else if (market.containsKey('grainPrice')) {
        marketDisplay = market['grainPrice'];
      }
    }

    String weatherDisplay = weather?['temp'] ?? weather?['temperature'] ?? '24°C';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(AppLocalizations.of(context)!.consultedLiveData, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blueAccent)),
        ),
        Row(
          children: [
            _buildSmallToolCard(
              title: AppLocalizations.of(context)!.marketLabel,
              icon: Icons.trending_up,
              data: marketDisplay,
              onTap: () {
                 _messageController.text = "Explain the current market trend for Wheat and Corn.";
              }
            ),
            const SizedBox(width: 8),
            _buildSmallToolCard(
              title: AppLocalizations.of(context)!.weatherLabel,
              icon: Icons.wb_sunny_outlined,
              data: weatherDisplay,
              onTap: () {
                 _messageController.text = "Tell me more about the weather forecast for my region.";
              }
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallToolCard({required String title, required IconData icon, required String data, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: Colors.blueAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title, 
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    SizedBox(
                      height: 16,
                      child: Marquee(
                        text: data,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        scrollAxis: Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        blankSpace: 40.0,
                        velocity: 30.0,
                        pauseAfterRound: const Duration(seconds: 1),
                        startPadding: 0.0,
                        accelerationDuration: const Duration(seconds: 1),
                        accelerationCurve: Curves.linear,
                        decelerationDuration: const Duration(milliseconds: 500),
                        decelerationCurve: Curves.easeOut,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFarmSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(AppLocalizations.of(context)!.suggestedRealEstate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.green)),
        ),
        SizedBox(
          height: 125,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _availableFarms.length,
            itemBuilder: (context, fIdx) {
              final farm = _availableFarms[fIdx];
              return Container(
                width: 170,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.withOpacity(0.1)),
                ),
                child: InkWell(
                  onTap: () {
                    if (farm['fullData'] != null) {
                      final landObj = Land.fromJson(farm['fullData']);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LandDetailsScreen(land: landObj)),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(farm['name'] ?? AppLocalizations.of(context)!.unknownFarm, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text('${farm['price'] ?? '0'} ${AppLocalizations.of(context)!.tndPerMeter}', style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(farm['weatherRiskScore'] ?? 'N/A', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.green),
                          ],
                        ),
                      ],
                    ),
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
                  hintText: AppLocalizations.of(context)!.enterPreferencesHint,
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
                icon: const Icon(Icons.insights, color: Colors.white, size: 20),
                onPressed: () => _sendMessage(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleInteractiveLink(String href) async {
    final uri = Uri.parse(href);
    if (uri.scheme == 'farmy') {
      if (uri.host == 'land') {
        final landId = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
        if (landId != null) {
          _showLoadingOverlay();
          try {
            final land = await LandService.getLandById(landId);
            if (mounted && land != null) {
              Navigator.pop(context); // Remove loading
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LandDetailsScreen(land: land)),
              );
            }
          } catch (e) {
            if (mounted) Navigator.pop(context);
          }
        }
      } else if (uri.host == 'asset') {
        // farmy://asset/category/variantId
        if (uri.pathSegments.length >= 2) {
          final category = uri.pathSegments[0];
          final variantId = uri.pathSegments[1];
          _showAssetInfoSheet(category, variantId);
        }
      } else if (uri.host == 'worker') {
        final workerId = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
        if (workerId != null) {
          _showWorkerInfoSheet(workerId);
        }
      }
    }
  }

  void _showLoadingOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _showWorkerInfoSheet(String workerId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: _fetchWorkerDetails(workerId),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final worker = snap.data;
            if (worker == null) return const SizedBox();

            final String name = worker['user']?['profile']?['name'] ?? 'Worker';
            final String bio = worker['bio'] ?? '';
            final String rating = worker['rating']?.toString() ?? '0.0';
            final String rate = worker['hourly_rate']?.toString() ?? '0';

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(AppLocalizations.of(context)!.laborMarketLabel, style: const TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (bio.isNotEmpty) Text(bio, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _statChip(AppLocalizations.of(context)!.rateLabel, '$rate TND/hr'),
                      const SizedBox(width: 8),
                      _statChip(AppLocalizations.of(context)!.ratingLabel, '$rating/5.0'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _fetchWorkerDetails(String workerId) async {
    try {
      final baseUrl = dotenv.get('API_BASE_URL', fallback: 'http://192.168.0.133:3001');
      final response = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse('$baseUrl/api/v1/worker-profile/$workerId'),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'] as Map<String, dynamic>?;
      }
    } catch (e) {
      debugPrint('_fetchWorkerDetails error: $e');
    }
    return null;
  }

  void _showAssetInfoSheet(String category, String variantId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: _fetchVariantDetails(category, variantId),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final variant = snap.data;
            if (variant == null) return const SizedBox();

            final String name = variant['type']?['name'] ?? variant['variant_code'] ?? 'Item';
            final String description = variant['type']?['description'] ?? '';
            final Map<String, dynamic> attrs = Map<String, dynamic>.from(variant['attributes'] ?? {});

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(category.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 12),
                  if (description.isNotEmpty) Text(description, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.specificationsLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _statChip(AppLocalizations.of(context)!.priceLabel, variant['base_price'].toString()),
                      for (var attr in attrs.entries) _statChip(attr.key, attr.value.toString()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _statChip(String label, String value) {
    return Chip(
      label: Text('$label: $value', style: const TextStyle(fontSize: 10)),
      backgroundColor: Colors.grey.withOpacity(0.1),
    );
  }

  Future<Map<String, dynamic>?> _fetchVariantDetails(String category, String variantId) async {
    try {
      final baseUrl = dotenv.get('API_BASE_URL', fallback: 'http://192.168.0.133:3001');
      final response = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse('$baseUrl/api/v1/assets/$category/variants/$variantId'),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'] as Map<String, dynamic>?;
      }
    } catch (e) {
      debugPrint('_fetchVariantDetails error: $e');
    }
    return null;
  }
}
