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
  final _widthController = TextEditingController(text: '10.0');
  final _heightController = TextEditingController(text: '10.0');
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Property Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildInputField(
              controller: _nameController,
              label: 'Land Name',
              hint: 'e.g. Sunny Valley Plot',
              icon: Icons.landscape_rounded,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Land name is required';
                if (v.length < 5) return 'Name must be at least 5 characters';
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Describe the soil, location, and potential...',
              icon: Icons.description_rounded,
              maxLines: 4,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Description is required';
                if (v.length < 20)
                  return 'Please provide more detail (min 20 chars)';
                return null;
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Spatial Dimensions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    controller: _widthController,
                    label: 'Width',
                    hint: 'Meters',
                    icon: Icons.straighten_rounded,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      final val = double.tryParse(v ?? '');
                      if (val == null) return 'Invalid';
                      if (val < 10 || val > 500) return '10-500m only';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildInputField(
                    controller: _heightController,
                    label: 'Height',
                    hint: 'Meters',
                    icon: Icons.square_foot_rounded,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      final val = double.tryParse(v ?? '');
                      if (val == null) return 'Invalid';
                      if (val < 10 || val > 500) return '10-500m only';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Boundaries',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _isMapView = true),
                  icon: const Icon(
                    Icons.map_rounded,
                    color: Colors.green,
                    size: 20,
                  ),
                  label: const Text(
                    'DEFINE ON MAP',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _isMapView = true),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1D21),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedPoints.length >= 3
                        ? Colors.green.withOpacity(0.3)
                        : Colors.white.withOpacity(0.05),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            (_selectedPoints.length >= 3
                                    ? Colors.green
                                    : Colors.white)
                                .withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.polyline_rounded,
                        color: _selectedPoints.length >= 3
                            ? Colors.green
                            : Colors.white38,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedPoints.isEmpty
                                ? 'Perimeter not set'
                                : '${_selectedPoints.length} Points Defined',
                            style: TextStyle(
                              color: _selectedPoints.length >= 3
                                  ? Colors.green
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedPoints.length < 3
                                ? 'Tap to draw land boundaries'
                                : 'Geometry verified and valid',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white12,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 15),
            prefixIcon: Icon(icon, color: Colors.white24, size: 20),
            filled: true,
            fillColor: const Color(0xFF1A1D21),
            contentPadding: const EdgeInsets.all(20),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.green, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 2),
            ),
            errorStyle: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
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
              userAgentPackageName: 'com.farmy.app',
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
        'width_m': double.parse(_widthController.text),
        'height_m': double.parse(_heightController.text),
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
