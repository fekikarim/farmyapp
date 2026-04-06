import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/ai_service.dart';
// Unused import removed
import '../widgets/entitlement_gate.dart';
import '../screens/customer/subscriptions_screen.dart';

class MatchProfile {
  final String id;
  final String name;
  final String role;
  final String location;
  final String description;
  final List<String> interests;
  final String avatarUrl;

  MatchProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.location,
    required this.description,
    required this.interests,
    required this.avatarUrl,
  });
}

class SmartMatchingScreen extends StatefulWidget {
  const SmartMatchingScreen({super.key});

  @override
  State<SmartMatchingScreen> createState() => _SmartMatchingScreenState();
}

class _SmartMatchingScreenState extends State<SmartMatchingScreen> {
  final AIService _aiService = AIService();
  List<MatchProfile> _matches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      
      if (user == null) {
        print('❌ Smart Matching: User is null, using mock data fallback');
        setState(() {
          _matches = _getMockMatches('farmer');
          _isLoading = false;
        });
        return;
      }

      print('🔍 Smart Matching: Loading matches for ${user.id} (role: ${user.role})');

      // Try to load from backend
      final matches = await _aiService.getSmartMatches(user.id, user.role);
      print('📊 Smart Matching: API returned ${matches.length} matches');

      if (matches.isNotEmpty) {
        _matches = matches.map((match) => MatchProfile(
          id: match['id'],
          name: match['name'],
          role: match['role'],
          location: match['location'],
          description: match['description'],
          interests: List<String>.from(match['interests']),
          avatarUrl: match['avatarUrl'],
        )).toList();
        print('✅ Smart Matching: Using API data with ${_matches.length} matches');
      } else {
        print('ℹ️ Smart Matching: API returned empty, using mock data');
        _matches = _getMockMatches(user.role);
        print('✅ Mock data loaded: ${_matches.length} matches for role ${user.role}');
      }
    } catch (e) {
      print('❌ Smart Matching Error: $e');
      // Mock data fallback
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      final mockMatches = _getMockMatches(user?.role ?? 'farmer');
      _matches = mockMatches;
      print('✅ Smart Matching: Using mock data fallback (${_matches.length} matches)');
    }

    setState(() => _isLoading = false);
  }

  List<MatchProfile> _getMockMatches(String userRole) {
    if (userRole.toLowerCase() == 'farmer') {
      return [
        MatchProfile(
          id: '1',
          name: 'John Buyer',
          role: 'buyer',
          location: 'New York, USA',
          description: 'Looking for organic vegetables and fruits for my restaurant chain.',
          interests: ['Organic Produce', 'Local Sourcing', 'Bulk Orders'],
          avatarUrl: '',
        ),
        MatchProfile(
          id: '2',
          name: 'Sarah Investor',
          role: 'investor',
          location: 'California, USA',
          description: 'Investing in sustainable farming technologies and practices.',
          interests: ['Sustainable Farming', 'Technology', 'Long-term Investment'],
          avatarUrl: '',
        ),
      ];
    } else if (userRole.toLowerCase() == 'investor') {
      return [
        MatchProfile(
          id: '3',
          name: 'Mike Johnson',
          role: 'farmer',
          location: 'Iowa, USA',
          description: 'Family farm specializing in corn and soybeans, looking for investment to expand.',
          interests: ['Crop Farming', 'Expansion', 'Modern Equipment'],
          avatarUrl: '',
        ),
      ];
    } else {
      // For buyers
      return [
        MatchProfile(
          id: '4',
          name: 'Green Valley Farm',
          role: 'farmer',
          location: 'Oregon, USA',
          description: 'Organic farm producing seasonal vegetables and herbs.',
          interests: ['Organic Farming', 'Vegetables', 'Local Markets'],
          avatarUrl: '',
        ),
      ];
    }
  }

  Future<void> _sendMatchRequest(MatchProfile match) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) return;

    final success = await _aiService.sendMatchRequest(
      user.id,
      match.id,
      match.role,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Match request sent to ${match.name}!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send match request. Please try again.')),
      );
    }
  }

  Widget _buildPremiumPaywall() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            isDark ? const Color(0xFF1A365D) : const Color(0xFFE3F2FD),
            isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(0.15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(isDark ? 0.4 : 0.2),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.handshake_rounded,
                  size: 72,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Unlock Smart Matching',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Automatically connect with the best partners based on location, needs, and budget. Reduce friction and accelerate transactions instantly with AI.',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SubscriptionsScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.workspace_premium, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Unlock Premium Now',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smart Matching',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMatches,
          ),
        ],
      ),
      body: EntitlementGate(
        entitlementKey: 'smart_matching',
        fallback: _buildPremiumPaywall(),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.blue.shade800,
                ),
              )
            : _matches.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.shade50,
                          ),
                          child: Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.blue.shade300,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No matches found yet',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'We\'ll notify you when our Smart Engine finds potential high-quality matches!',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey.shade600,
                                  height: 1.5,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _matches.length,
                    itemBuilder: (context, index) {
                      final match = _matches[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 4,
                        shadowColor: Colors.blue.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 32,
                                      backgroundColor: Colors.blue.shade800,
                                      child: match.avatarUrl.isNotEmpty
                                          ? null // Would load image here
                                          : Text(
                                              match.name[0].toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 26,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          match.name,
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              size: 14,
                                              color: Colors.grey.shade500,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                '${match.role.toUpperCase()} • ${match.location}',
                                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  color: Colors.grey.shade600,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                match.description,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: match.interests.map((interest) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.blue.shade100),
                                  ),
                                  child: Text(
                                    interest,
                                    style: TextStyle(
                                      color: Colors.blue.shade800,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                )).toList(),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _sendMatchRequest(match),
                                  icon: const Icon(Icons.handshake),
                                  label: const Text('Connect Now'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade800,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}