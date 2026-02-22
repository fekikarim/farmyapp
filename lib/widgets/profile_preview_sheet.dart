import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class ProfilePreviewSheet extends StatefulWidget {
  final String userId;
  final User? initialUser;

  const ProfilePreviewSheet({
    super.key,
    required this.userId,
    this.initialUser,
  });

  static Future<void> show(
    BuildContext context,
    String userId, {
    User? initialUser,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          ProfilePreviewSheet(userId: userId, initialUser: initialUser),
    );
  }

  @override
  State<ProfilePreviewSheet> createState() => _ProfilePreviewSheetState();
}

class _ProfilePreviewSheetState extends State<ProfilePreviewSheet> {
  User? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _user = widget.initialUser;
    // Always fetch to ensure dynamic sync with backend (latest stats/rentals)
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    if (_user == null) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final user = await AuthService.fetchPublicProfile(widget.userId);
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
          if (user == null) _error = 'Profile not found or private';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Only show error if we don't even have initial data
          if (_user == null) {
            _error = 'Failed to load profile. Please check your connection.';
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: _isLoading
            ? _buildShimmer(isDark)
            : _error != null
            ? _buildErrorView(theme)
            : _buildContent(theme, isDark),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, bool isDark) {
    final profile = _user?.profile;
    final name = profile?.name ?? _user?.email.split('@').first ?? 'User';
    final headline = profile?.headline;
    final bio = profile?.bio;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Background Cover (Blurred or generic)
                if (profile?.picture != null)
                  Image.network(
                    '${AuthService.baseUrl}${profile!.picture}',
                    fit: BoxFit.cover,
                  ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(color: Colors.black.withOpacity(0.3)),
                ),
                // Close button
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // Center Content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.primary.withOpacity(
                        0.2,
                      ),
                      backgroundImage: profile?.picture != null
                          ? NetworkImage(
                              '${AuthService.baseUrl}${profile?.picture}',
                            )
                          : null,
                      child: profile?.picture == null
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_user?.isVerified ?? false) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                    if (headline != null && headline.isNotEmpty)
                      Text(
                        headline,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (_user?.role.toLowerCase() == 'investor')
                      _buildStat(
                        'Lands Rented',
                        '${_user?.rentedLandsCount ?? 0}',
                        Icons.landscape,
                      )
                    else
                      _buildStat(
                        'Completeness',
                        '${profile?.completenessScore ?? 0}%',
                        Icons.analytics,
                      ),
                    _buildStat(
                      'Role',
                      _user?.role.toUpperCase() ?? 'USER',
                      Icons.badge,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                if (bio != null && bio.isNotEmpty) ...[
                  Text(
                    'About',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    bio,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Portfolio Links
                if (profile?.linkedin != null || profile?.website != null) ...[
                  Text(
                    'Direct Links',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (profile?.linkedin != null)
                    _buildLinkTile(
                      Icons.link,
                      'LinkedIn Profile',
                      profile!.linkedin!,
                      theme,
                    ),
                  if (profile?.website != null)
                    _buildLinkTile(
                      Icons.language,
                      'Website',
                      profile!.website!,
                      theme,
                    ),
                ],

                const SizedBox(height: 48),
                // Professional Footer
                Center(
                  child: Text(
                    'Farmy Community Member since ${DateFormat('MMMM yyyy').format(_user?.createdAt ?? DateTime.now())}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildLinkTile(
    IconData icon,
    String label,
    String url,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          const Icon(Icons.open_in_new, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Column(
        children: [
          Container(height: 200, color: Colors.white),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    2,
                    (i) => Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(width: 60, height: 12, color: Colors.white),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Container(width: 150, height: 24, color: Colors.white),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_person_outlined,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Privacy Restricted',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
