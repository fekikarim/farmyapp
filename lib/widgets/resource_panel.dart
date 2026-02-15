import 'package:flutter/material.dart';
import '../models/land_resource_model.dart';
import '../services/shop_service.dart';

class ResourcePanel extends StatefulWidget {
  final String landId;

  const ResourcePanel({super.key, required this.landId});

  @override
  State<ResourcePanel> createState() => _ResourcePanelState();
}

class _ResourcePanelState extends State<ResourcePanel> {
  bool _isLoading = true;
  List<LandResource> _resources = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch raw data
      final data = await ShopService.getLandResources(widget.landId);
      
      // Parse data into models
      if (mounted) {
        setState(() {
          _resources = data.map((json) => LandResource.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load resources: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.95), // Dark slate background
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.inventory, color: Colors.blueAccent, size: 28),
                ),
                const SizedBox(width: 16),
                const Text(
                  'RESOURCES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, color: Colors.white10),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                : _errorMessage != null
                    ? _buildErrorView()
                    : _resources.isEmpty
                        ? _buildEmptyView()
                        : _buildResourceList(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Unknown error',
            style: const TextStyle(color: Colors.redAccent),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadResources,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white10),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco_outlined, size: 64, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            'No resources stored yet',
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _resources.length,
      itemBuilder: (context, index) {
        final resource = _resources[index];
        final type = resource.resourceType;
        final percentage = resource.percentageFull / 100;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: type?.iconUrl != null && type!.iconUrl!.isNotEmpty
                  ? Image.network(type.iconUrl!, errorBuilder: (_,__,___) => const Icon(Icons.grass, color: Colors.white54))
                  : const Icon(Icons.grass, color: Colors.white54),
              ),
              const SizedBox(width: 16),
              
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          type?.name ?? 'Unknown Resource',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${resource.quantity.toStringAsFixed(0)} / ${resource.maxCapacity.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.white10,
                        color: _getProgressColor(percentage),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Color _getProgressColor(double percentage) {
    if (percentage > 0.9) return Colors.redAccent;
    if (percentage > 0.5) return Colors.blueAccent;
    return Colors.greenAccent;
  }
}
