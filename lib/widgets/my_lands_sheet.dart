import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/land_provider.dart';
import '../models/land_model.dart';
import '../models/land_rental_model.dart';
import '../game/game_screen.dart';

class MyLandsBottomSheet extends StatefulWidget {
  const MyLandsBottomSheet({super.key});

  @override
  State<MyLandsBottomSheet> createState() => _MyLandsBottomSheetState();
}

class _MyLandsBottomSheetState extends State<MyLandsBottomSheet> {
  @override
  void initState() {
    super.initState();
    // Fetch PAID rentals when sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LandProvider>().fetchMyRentals(true, paymentStatus: 'paid');
    });
  }

  @override
  Widget build(BuildContext context) {
    final landProvider = Provider.of<LandProvider>(context);
    final myRentals = landProvider.myRentals; // Use rentals instead of lands
    final isLoading = landProvider.isLoading;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.landscape, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'My Lands',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : myRentals.isEmpty
                    ? _buildEmptyState()
                    : _buildLandGrid(myRentals),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.landscape_outlined, size: 60, color: Theme.of(context).disabledColor),
          const SizedBox(height: 16),
          Text(
            'No lands found',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You haven\'t rented any lands yet.',
            style: TextStyle(color: Theme.of(context).disabledColor),
          ),
        ],
      ),
    );
  }

  Widget _buildLandGrid(List<LandRental> rentals) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8, // Taller items
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: rentals.length,
      itemBuilder: (context, index) {
        final rental = rentals[index];
        if (rental.land == null) {
          return const SizedBox.shrink(); // Skip if land data is missing
        }
        return _buildLandCard(context, rental.land!);
      },
    );
  }

  Widget _buildLandCard(BuildContext context, Land land) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
            GestureDetector(
              onTap: () {
                // Determine if we should allow playing (e.g. only if active/owned)
                // For now, allow all.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(land: land),
                  ),
                );
              },
              child: Image.asset(
                'assets/game_images/default_farm_collectionView.jpg',
                fit: BoxFit.cover,
              ),
            ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.grid_on,
                          size: 12,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${land.gridWidth}x${land.gridHeight}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  land.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: land.isActive ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      land.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
