import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../providers/land_provider.dart';

class FarmerAddLandScreen extends StatefulWidget {
  const FarmerAddLandScreen({super.key});

  @override
  State<FarmerAddLandScreen> createState() => _FarmerAddLandScreenState();
}

class _FarmerAddLandScreenState extends State<FarmerAddLandScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _widthController = TextEditingController(text: '10');
  final _heightController = TextEditingController(text: '10');
  bool _isLoading = false;

  List<LatLng> _selectedPoints = [];
  bool _isMapView = false;
  bool _isSatellite = true;
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List New Land'),
        actions: [
          if (_isMapView)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () => setState(() => _isMapView = false),
            ),
        ],
      ),
      body: _isMapView ? _buildMapPicker() : _buildForm(),
      bottomNavigationBar: _isMapView
          ? null
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
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
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'PUBLISH LISTING',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'General Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Land Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            const Text(
              'Grid Dimensions (meters)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _widthController,
                    decoration: const InputDecoration(
                      labelText: 'Width',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(
                      labelText: 'Height',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Boundaries Selection',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _isMapView = true),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('OPEN MAP'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.layers,
                    color: _selectedPoints.length >= 3
                        ? Colors.green
                        : Colors.grey,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _selectedPoints.isEmpty
                        ? 'No boundaries selected'
                        : '${_selectedPoints.length} points selected',
                    style: TextStyle(
                      color: _selectedPoints.length >= 3
                          ? Colors.green
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (_selectedPoints.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Tap on the map to define the perimeter of your land.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPicker() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(36.8065, 10.1815),
            initialZoom: 15.0,
            onTap: (tapPosition, latLng) {
              setState(() {
                _selectedPoints.add(latLng);
              });
            },
          ),
          children: [
            TileLayer(
              urlTemplate: _isSatellite
                  ? "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
                  : "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: 'com.farmy.app.v1',
            ),
            if (_selectedPoints.isNotEmpty)
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: _selectedPoints,
                    color: Colors.green.withOpacity(0.4),
                    borderColor: Colors.white,
                    borderStrokeWidth: 3,
                    isFilled: true,
                  ),
                ],
              ),
            MarkerLayer(
              markers: _selectedPoints
                  .map(
                    (p) => Marker(
                      point: p,
                      child: const Icon(
                        Icons.circle,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Tap on the map to add points and define the land boundaries.',
              style: TextStyle(color: Colors.white, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          child: FloatingActionButton.extended(
            heroTag: 'clear_points',
            onPressed: () => setState(() => _selectedPoints.clear()),
            label: const Text('Clear'),
            icon: const Icon(Icons.clear),
            backgroundColor: Colors.redAccent,
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: 'map_type_picker',
                onPressed: () => setState(() => _isSatellite = !_isSatellite),
                backgroundColor: Colors.white,
                child: Icon(
                  _isSatellite ? Icons.map : Icons.satellite_alt,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.extended(
                heroTag: 'confirm_map',
                onPressed: () => setState(() => _isMapView = false),
                label: const Text('Confirm'),
                icon: const Icon(Icons.check),
                backgroundColor: Colors.green,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPoints.length < 3) {
      _showErrorSnackBar('Please select at least 3 points on the map.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await context.read<LandProvider>().createLand({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'grid_width': int.parse(_widthController.text),
        'grid_height': int.parse(_heightController.text),
        'boundaries': _selectedPoints
            .map((p) => [p.longitude, p.latitude])
            .toList(), // GeoJSON [lng, lat]
      });

      if (success && mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ops! Something went wrong'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            const Text(
              'Land Listed!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your land has been successfully listed and is now visible to potential investors.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Return to management
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'CONTINUE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
