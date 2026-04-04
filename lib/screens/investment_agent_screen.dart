import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/investment_agent_service.dart';

class InvestmentAgentScreen extends StatefulWidget {
  const InvestmentAgentScreen({super.key});

  @override
  State<InvestmentAgentScreen> createState() => _InvestmentAgentScreenState();
}

class _InvestmentAgentScreenState extends State<InvestmentAgentScreen> {
  final InvestmentAgentService _agentService = InvestmentAgentService();
  final TextEditingController _preferencesController = TextEditingController();
  
  String? _recommendation;
  bool _isLoading = false;
  String? _error;

  void _getRecommendation() async {
    final prefs = _preferencesController.text.trim();
    if (prefs.isEmpty) {
      setState(() => _error = "Please enter your preferences.");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _recommendation = null;
    });

    try {
      final result = await _agentService.getRecommendations(prefs);
      setState(() {
        _recommendation = result;
      });
    } catch (e) {
      setState(() {
        _error = "Failed to fetch recommendations. Please try again.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Smart Investment Agent'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'AI Investment Advisor',
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Describe your investment preferences. The AI will recommend 3 diversified farms considering weather risk and farmer reliability.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _preferencesController,
                maxLines: 3,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'e.g., I want to invest up to \$5000 in fruit farms with low risk.',
                  hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                  filled: true,
                  fillColor: colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _getRecommendation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Get Recommendations',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              _buildResultContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Analyzing farms, weather stats & reliability...',
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: TextStyle(color: colorScheme.error),
        ),
      );
    }

    if (_recommendation != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Markdown(
          data: _recommendation!,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(color: colorScheme.onSurface),
            h1: theme.textTheme.headlineLarge,
            h2: theme.textTheme.headlineMedium,
            h3: theme.textTheme.headlineSmall,
            listBullet: TextStyle(color: theme.primaryColor),
          ),
          shrinkWrap: true,
        ),
      );
    }

    return Center(
      child: Text(
        'Your recommendations will appear here.',
        style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
      ),
    );
  }
}
