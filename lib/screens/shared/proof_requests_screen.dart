import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/proof_service.dart';
import '../../services/auth_service.dart';
import 'package:farmyapp/l10n/app_localizations.dart';

class ProofRequestsScreen extends StatefulWidget {
  const ProofRequestsScreen({super.key});

  @override
  State<ProofRequestsScreen> createState() => _ProofRequestsScreenState();
}

class _ProofRequestsScreenState extends State<ProofRequestsScreen> {
  List<dynamic> _proofs = [];
  bool _isLoading = true;
  String? _error;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await AuthService.fetchProfile();
      _currentUserId = user?.id;
      final proofs = await ProofService.getMyProofs();
      if (mounted) {
        setState(() {
          _proofs = proofs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = AppLocalizations.of(context)!.failedToLoadProofs;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSubmitProof(String id) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.aiVerifyingProof)),
    );

    final errorOrRejectMsg = await ProofService.submitProof(id, image);

    if (mounted) {
      if (errorOrRejectMsg == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.proofVerifiedSuccessfully,
            ),
            backgroundColor: Colors.green.shade600,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorOrRejectMsg),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      _loadData(); // Refresh UI
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    switch (status.toLowerCase()) {
      case 'verified':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case 'expired':
        color = Colors.grey;
        icon = Icons.timer_off;
        break;
      case 'pending':
      default:
        color = Colors.orange;
        icon = Icons.hourglass_bottom;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            _translateStatus(context, status).toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.aiProofRequests),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.aiProofRequests),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _error != null
          ? Center(child: Text(_error!))
          : _proofs.isEmpty
          ? Center(
              child: Text(AppLocalizations.of(context)!.noProofRequestsFound),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _proofs.length,
              itemBuilder: (context, index) {
                final proof = _proofs[index];
                final isFarmer = proof['farmer_id'] == _currentUserId;
                final isPending = proof['status'] == 'pending';
                final expiresAt = DateTime.parse(proof['expires_at']);
                final isExpiredLocal =
                    isPending && expiresAt.isBefore(DateTime.now());

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isFarmer
                                  ? AppLocalizations.of(context)!.fromLabel(
                                      proof['investor_name'] ??
                                          AppLocalizations.of(
                                            context,
                                          )!.investor,
                                    )
                                  : AppLocalizations.of(context)!.toLabel(
                                      proof['farmer_name'] ??
                                          AppLocalizations.of(context)!.worker,
                                    ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            _buildStatusBadge(
                              isExpiredLocal ? 'expired' : proof['status'],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (isPending && !isExpiredLocal) ...[
                          Text(
                            AppLocalizations.of(context)!.mustSubmitBefore(
                              DateFormat.yMMMd(
                                Localizations.localeOf(context).toString(),
                              ).add_jm().format(expiresAt),
                            ),
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (proof['ai_reasoning'] != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!.aiNotes(proof['ai_reasoning'] ?? ''),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (proof['image_url'] != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              '${AuthService.baseUrl}${proof['image_url']}',
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 100,
                                width: double.infinity,
                                color: Colors.grey.withOpacity(0.1),
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (isFarmer && isPending && !isExpiredLocal) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _handleSubmitProof(proof['id']),
                              icon: const Icon(Icons.camera_alt),
                              label: Text(
                                AppLocalizations.of(context)!.submitPhotoProof,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _translateStatus(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status.toLowerCase()) {
      case 'verified':
      case 'approved':
        return l10n.verifiedUpper;
      case 'rejected':
      case 'failed':
        return l10n.rejectedUpper;
      case 'expired':
        return l10n.expiredUpper;
      case 'pending':
        return l10n.pendingUpper;
      default:
        return status;
    }
  }
}
