import 'package:flutter/material.dart';
import '../../services/shop_service.dart';

class FarmerRentalRequestsScreen extends StatefulWidget {
  const FarmerRentalRequestsScreen({super.key});

  @override
  State<FarmerRentalRequestsScreen> createState() => _FarmerRentalRequestsScreenState();
}

class _FarmerRentalRequestsScreenState extends State<FarmerRentalRequestsScreen> {
  List<dynamic> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    final requests = await ShopService.getIncomingItemRequests();
    if (mounted) {
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleApprove(String id) async {
    final error = await ShopService.approveItemRequest(id);
    if (error == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request Approved! Item placed.'), backgroundColor: Colors.green));
        _loadRequests();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _handleReject(String id) async {
    final success = await ShopService.rejectItemRequest(id, 'Rejected by farmer');
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request Rejected.'), backgroundColor: Colors.orange));
        _loadRequests();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to reject request.'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Item Requests',
          style: TextStyle(color: theme.textTheme.titleLarge?.color),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textTheme.titleLarge?.color),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? const Center(child: Text('No pending requests.'))
              : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final req = _requests[index];
          final user = req['user'] ?? {};
          final land = req['land'] ?? {};

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor, // Add this color
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : Colors.grey).withOpacity(
                    0.05,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                     CircleAvatar(
                      radius: 24,
                      backgroundImage: user['profile'] != null && user['profile']['avatar'] != null
                          ? NetworkImage(user['profile']['avatar'])
                          : const NetworkImage('https://i.pravatar.cc/150?u=unknown'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (user['profile'] != null ? user['profile']['name'] : null) ?? 'Unknown Investor',
                            style: TextStyle(
                              color: theme.textTheme.titleLarge?.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Request to buy ${req['asset_category']}',
                            style: TextStyle(
                              color: (isDark ? Colors.white54 : Colors.black54),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                Text(
                  'REQUEST DETAILS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: (isDark ? Colors.white38 : Colors.black38),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  context,
                  Icons.landscape_rounded,
                  land['name'] ?? 'Unknown Land',
                ),
                _buildDetailRow(
                  context,
                  Icons.shopping_bag_rounded,
                  'Item: ${req['variant_id']}',
                ),
                _buildDetailRow(
                  context,
                  Icons.monetization_on_rounded,
                  'Paid: \$${req['price_paid']}',
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _handleReject(req['id']),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('REJECT', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleApprove(req['id']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('APPROVE', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: isDark ? Colors.white38 : Colors.black38),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
