import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/ai_service.dart';
import '../models/user_model.dart';

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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Matching'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMatches,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _matches.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No matches found',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We\'ll notify you when we find potential matches!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
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
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Theme.of(context).primaryColor,
                                  child: match.avatarUrl.isNotEmpty
                                      ? null // Would load image here
                                      : Text(
                                          match.name[0].toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
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
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                      Text(
                                        '${match.role} • ${match.location}',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => _sendMatchRequest(match),
                                  child: const Text('Connect'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              match.description,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: match.interests.map((interest) => Chip(
                                label: Text(interest),
                                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}