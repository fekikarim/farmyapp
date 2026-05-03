import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/hedera_service.dart';
import 'package:farmyapp/l10n/app_localizations.dart';

class HederaRegistryScreen extends StatefulWidget {
  const HederaRegistryScreen({super.key});

  @override
  State<HederaRegistryScreen> createState() => _HederaRegistryScreenState();
}

class _HederaRegistryScreenState extends State<HederaRegistryScreen>
    with SingleTickerProviderStateMixin {
  List<HederaEntry> _entries = [];
  bool _isLoading = true;
  String? _error;
  late AnimationController _animController;

  // Hedera brand colors mapped to app theme
  static const Color _brandPrimary = Color(0xFF90A53E);
  static const Color _brandDark = Color(0xFF1A2111);
  static const Color _brandAccent = Color(0xFFC5D196);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _load();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await HederaService.getMyRegistry();
      if (mounted) setState(() { _entries = data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF1A2111),
                          const Color(0xFF0D1208),
                          const Color(0xFF121A0A)
                        ]
                      : [
                          theme.colorScheme.surface,
                          _brandPrimary.withOpacity(0.05),
                          theme.colorScheme.surface,
                        ],
                ),
              ),
            ),
          ),

          // Floating glow orbs (more visible in dark mode, subtle in light)
          Positioned(
            top: -60, right: -40,
            child: AnimatedBuilder(
              animation: _animController,
              builder: (_, __) => Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _brandPrimary.withOpacity(isDark ? 0.18 + _animController.value * 0.06 : 0.08 + _animController.value * 0.03),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 80, left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF4F7035).withOpacity(isDark ? 0.25 : 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: RefreshIndicator(
              onRefresh: _load,
              color: _brandPrimary,
              backgroundColor: theme.colorScheme.surface,
              child: Column(
                children: [
                  _buildHeader(context, theme, isDark),
                  if (!_isLoading && _error == null) _buildStats(context, theme, isDark),
                  Expanded(child: _buildBody(context, theme, isDark)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new, color: theme.iconTheme.color?.withOpacity(0.8), size: 18),
          ),
          const SizedBox(width: 12),
          // Hedera logo-style icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF90A53E), Color(0xFF4F7035)],
              ),
              boxShadow: [
                BoxShadow(
                  color: _brandPrimary.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text('H', style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: -1,
              )),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.hederaRegistryUpper,
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                AppLocalizations.of(context)!.immutableOnChainRecords,
                style: TextStyle(
                  color: isDark ? _brandAccent.withOpacity(0.7) : theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (!_isLoading)
            GestureDetector(
              onTap: _load,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : _brandPrimary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? Colors.white10 : _brandPrimary.withOpacity(0.1)),
                ),
                child: Icon(Icons.refresh_rounded, color: isDark ? Colors.white54 : theme.iconTheme.color?.withOpacity(0.6), size: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, ThemeData theme, bool isDark) {
    final rentals = _entries.where((e) => e.type == 'land_rental').length;
    final items = _entries.where((e) => e.type == 'item_purchase' || e.type == 'product_purchase').length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          _buildStatCard(context, theme, isDark, AppLocalizations.of(context)!.totalLabel, _entries.length.toString(), Icons.link_rounded),
          const SizedBox(width: 12),
          _buildStatCard(context, theme, isDark, AppLocalizations.of(context)!.rentalsLabel, rentals.toString(), Icons.landscape_rounded),
          const SizedBox(width: 12),
          _buildStatCard(context, theme, isDark, AppLocalizations.of(context)!.purchasesLabel, items.toString(), Icons.shopping_bag_outlined),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, ThemeData theme, bool isDark, String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? _brandPrimary.withOpacity(0.2) : _brandPrimary.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : _brandPrimary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              color: isDark ? Colors.white.withOpacity(0.02) : Colors.transparent,
              child: Column(
                children: [
                  Icon(icon, color: _brandPrimary, size: 18),
                  const SizedBox(height: 6),
                  Text(value, style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  )),
                  Text(label, style: TextStyle(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                    fontSize: 10,
                    letterSpacing: 0.5,
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme, bool isDark) {
    if (_isLoading) return _buildLoader(context, theme, isDark);
    if (_error != null) return _buildError(context, theme, isDark);
    if (_entries.isEmpty) return _buildEmpty(context, theme, isDark);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      itemCount: _entries.length,
      itemBuilder: (context, i) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (i.clamp(0, 10)) * 60),
          curve: Curves.easeOut,
          builder: (_, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          ),
          child: _buildEntryCard(context, theme, isDark, _entries[i]),
        );
      },
    );
  }

  Widget _buildEntryCard(BuildContext context, ThemeData theme, bool isDark, HederaEntry entry) {
    final isRental = entry.type == 'land_rental';
    final typeColor = isRental ? const Color(0xFF4ADE80) : _brandPrimary;
    final typeIcon = isRental ? Icons.landscape_rounded : Icons.shopping_bag_outlined;
    final shortTxId = entry.hederaTransactionId.length > 24
        ? '${entry.hederaTransactionId.substring(0, 24)}...'
        : entry.hederaTransactionId;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? _brandPrimary.withOpacity(0.25) : _brandPrimary.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : _brandPrimary.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 // Header row
                 Row(
                   children: [
                     Container(
                       padding: const EdgeInsets.all(10),
                       decoration: BoxDecoration(
                         color: typeColor.withOpacity(0.12),
                         borderRadius: BorderRadius.circular(12),
                         border: Border.all(color: typeColor.withOpacity(0.2)),
                       ),
                       child: Icon(typeIcon, color: typeColor, size: 18),
                     ),
                     const SizedBox(width: 12),
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(
                             _capitalize(entry.label),
                             style: TextStyle(
                               color: theme.textTheme.bodyLarge?.color,
                               fontWeight: FontWeight.w700,
                               fontSize: 14,
                             ),
                           ),
                           Text(
                             entry.sublabel,
                             style: TextStyle(
                               color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                               fontSize: 11,
                             ),
                             maxLines: 1,
                             overflow: TextOverflow.ellipsis,
                           ),
                         ],
                       ),
                     ),
                     if (entry.amount != null)
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                         decoration: BoxDecoration(
                           color: const Color(0xFF4ADE80).withOpacity(0.1),
                           borderRadius: BorderRadius.circular(8),
                         ),
                         child: Text(
                           '\$${entry.amount!.toStringAsFixed(2)}',
                           style: const TextStyle(
                             color: Color(0xFF4ADE80),
                             fontWeight: FontWeight.w800,
                             fontSize: 13,
                           ),
                         ),
                       ),
                   ],
                 ),

                 const SizedBox(height: 14),

                 // Hedera TX section
                 Container(
                   padding: const EdgeInsets.all(12),
                   decoration: BoxDecoration(
                     color: isDark ? _brandDark.withOpacity(0.6) : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                     borderRadius: BorderRadius.circular(12),
                     border: Border.all(color: _brandPrimary.withOpacity(0.15)),
                   ),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Row(
                         children: [
                           const Icon(Icons.verified_rounded, color: Color(0xFF90A53E), size: 13),
                           const SizedBox(width: 5),
                           Text(
                             AppLocalizations.of(context)!.hederaConsensusServiceUpper,
                             style: TextStyle(
                               color: isDark ? _brandAccent.withOpacity(0.8) : _brandPrimary.withOpacity(0.8),
                               fontSize: 9,
                               fontWeight: FontWeight.w800,
                               letterSpacing: 1.0,
                             ),
                           ),
                         ],
                       ),
                       const SizedBox(height: 6),
                       Row(
                         children: [
                           Expanded(
                             child: Text(
                               shortTxId,
                               style: TextStyle(
                                 color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                                 fontFamily: 'monospace',
                                 fontSize: 11,
                               ),
                             ),
                           ),
                           const SizedBox(width: 8),
                           // Copy button
                           GestureDetector(
                             onTap: () {
                               Clipboard.setData(ClipboardData(text: entry.hederaTransactionId));
                               ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(
                                   content: Text(AppLocalizations.of(context)!.transactionIdCopied),
                                   backgroundColor: _brandPrimary,
                                   behavior: SnackBarBehavior.floating,
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                   duration: const Duration(seconds: 2),
                                 ),
                               );
                             },
                             child: Icon(Icons.copy_rounded, size: 16, color: theme.iconTheme.color?.withOpacity(0.6)),
                           ),
                           const SizedBox(width: 10),
                           // HashScan button
                           GestureDetector(
                             onTap: () => _openHashScan(entry.hashScanUrl),
                             child: Container(
                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                               decoration: BoxDecoration(
                                 gradient: const LinearGradient(
                                   colors: [Color(0xFF90A53E), Color(0xFF4F7035)],
                                 ),
                                 borderRadius: BorderRadius.circular(6),
                                 boxShadow: [
                                   BoxShadow(
                                     color: _brandPrimary.withOpacity(0.3),
                                     blurRadius: 4,
                                     offset: const Offset(0, 2),
                                   )
                                 ],
                               ),
                               child: const Row(
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                   Icon(Icons.open_in_new_rounded, size: 10, color: Colors.white),
                                   SizedBox(width: 4),
                                   Text('HashScan', style: TextStyle(
                                     color: Colors.white,
                                     fontSize: 10,
                                     fontWeight: FontWeight.bold,
                                   )),
                                 ],
                               ),
                             ),
                           ),
                         ],
                       ),
                     ],
                   ),
                 ),

                 const SizedBox(height: 10),

                 // Footer: date + status
                 Row(
                   children: [
                     Icon(Icons.access_time_rounded, size: 11, color: theme.iconTheme.color?.withOpacity(0.4)),
                     const SizedBox(width: 4),
                     Text(
                       _formatDate(entry.timestamp),
                       style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.6), fontSize: 10),
                     ),
                     const Spacer(),
                     _buildStatusPill(context, entry.status),
                   ],
                 ),
               ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill(BuildContext context, String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'paid':
      case 'approved':
        color = const Color(0xFF4ADE80);
        break;
      case 'pending':
        color = const Color(0xFFFBBF24);
        break;
      case 'rejected':
        color = const Color(0xFFF87171);
        break;
      default:
        color = Theme.of(context).disabledColor;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        _translateStatus(context, status).toUpperCase(),
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildLoader(BuildContext context, ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animController,
            builder: (_, __) => Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _brandPrimary.withOpacity(0.2 + _animController.value * 0.2),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                color: _brandPrimary,
                strokeWidth: 2.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context)!.fetchingBlockchainRecords,
              style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFF87171), size: 48),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.failedToLoadRecords, style: TextStyle(color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8))),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(AppLocalizations.of(context)!.retry),
            style: ElevatedButton.styleFrom(
              backgroundColor: _brandPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, ThemeData theme, bool isDark) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _brandPrimary.withOpacity(0.08),
                  border: Border.all(color: _brandPrimary.withOpacity(0.2)),
                ),
                child: Center(
                  child: Text('H', style: TextStyle(
                    color: _brandPrimary.withOpacity(0.6),
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                  )),
                ),
              ),
              const SizedBox(height: 20),
              Text(AppLocalizations.of(context)!.noBlockchainRecordsYet,
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(AppLocalizations.of(context)!.makePurchaseImmutableRecordsHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13, height: 1.5)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return AppLocalizations.of(context)!.justNow;
    if (diff.inHours < 1) return AppLocalizations.of(context)!.minutesAgo(diff.inMinutes.toString());
    if (diff.inDays < 1) return AppLocalizations.of(context)!.hoursAgo(diff.inHours.toString());
    if (diff.inDays < 7) return AppLocalizations.of(context)!.daysAgo(diff.inDays.toString());
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s.split(' ').map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }

  Future<void> _openHashScan(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.couldNotOpenHashScan)),
        );
      }
    }
  }

  String _translateStatus(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status.toLowerCase()) {
      case 'paid':
        return l10n.paidUpper;
      case 'approved':
      case 'verified':
        return l10n.approvedUpper;
      case 'pending':
        return l10n.pendingUpper;
      case 'rejected':
      case 'failed':
        return l10n.rejectedUpper;
      default:
        return status;
    }
  }
}
