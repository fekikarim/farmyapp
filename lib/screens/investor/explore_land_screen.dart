import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../providers/land_provider.dart';
import '../../models/land_model.dart';
import 'land_details_screen.dart';

class InvestorExploreLandScreen extends StatefulWidget {
  const InvestorExploreLandScreen({super.key});

  @override
  State<InvestorExploreLandScreen> createState() =>
      _InvestorExploreLandScreenState();
}

class _InvestorExploreLandScreenState extends State<InvestorExploreLandScreen> {
  bool _isMapView = false;
  bool _isSatellite = true;
  bool _is3D = false;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LandProvider>().fetchAllLands();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Explore Lands',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(_isMapView ? Icons.list : Icons.map),
            onPressed: () => setState(() => _isMapView = !_isMapView),
          ),
        ],
      ),
      body: Consumer<LandProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${provider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: () => provider.fetchAllLands(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.allLands.isEmpty) {
            return const Center(
              child: Text('No lands available at the moment.'),
            );
          }

          return _isMapView
              ? _buildMapView(provider.allLands)
              : _buildListView(provider.allLands);
        },
      ),
    );
  }

  Widget _buildListView(List<Land> lands) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lands.length,
      itemBuilder: (context, index) {
        final land = lands[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LandDetailsScreen(land: land),
              ),
            ),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1500382017468-9049fee74a62?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            land.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Available',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        land.description ?? 'No description provided.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.grid_on,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${land.gridWidth}x${land.gridHeight} Plots',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const Spacer(),
                          const Text(
                            'Price starting from 1,200 TND',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapView(List<Land> lands) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter:
                lands.isNotEmpty &&
                    lands[0].boundaries != null &&
                    lands[0].boundaries!.isNotEmpty
                ? lands[0].boundaries![0]
                : const LatLng(36.8065, 10.1815),
            initialZoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: _isSatellite
                  ? "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
                  : "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: 'com.farmyapp',
            ),
            PolygonLayer(
              polygons: lands
                  .where(
                    (l) => l.boundaries != null && l.boundaries!.isNotEmpty,
                  )
                  .map(
                    (land) => Polygon(
                      points: land.boundaries!,
                      color: Colors.green.withOpacity(0.3),
                      borderColor: Colors.white,
                      borderStrokeWidth: 2,
                      isFilled: true,
                      label: land.name,
                    ),
                  )
                  .toList(),
            ),
            MarkerLayer(
              markers: lands
                  .where(
                    (l) => l.boundaries != null && l.boundaries!.isNotEmpty,
                  )
                  .map(
                    (land) => Marker(
                      point: land.boundaries![0],
                      width: 120,
                      height: 60,
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LandDetailsScreen(land: land),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(
                                land.name,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.location_on,
                              color: Colors.green,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: Column(
            children: [
              FloatingActionButton.small(
                heroTag: 'map_type',
                onPressed: () => setState(() => _isSatellite = !_isSatellite),
                backgroundColor: Colors.white,
                child: Icon(
                  _isSatellite ? Icons.map : Icons.satellite_alt,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: '3d_view',
                onPressed: () {
                  setState(() {
                    _is3D = !_is3D;
                    _mapController.rotate(_is3D ? 45.0 : 0.0);
                  });
                },
                backgroundColor: _is3D ? Colors.green : Colors.white,
                child: Icon(
                  Icons.view_in_ar,
                  color: _is3D ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
