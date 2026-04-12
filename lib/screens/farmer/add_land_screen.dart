import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../../providers/land_provider.dart';
import '../../utils/geometry_utils.dart';

class FarmerAddLandScreen extends StatefulWidget {
  const FarmerAddLandScreen({super.key});

  @override
  State<FarmerAddLandScreen> createState() => _FarmerAddLandScreenState();
}

class _FarmerAddLandScreenState extends State<FarmerAddLandScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController(text: '1200.0');
  final _widthController = TextEditingController(text: '10.0');
  final _heightController = TextEditingController(text: '10.0');
  bool _isLoading = false;

  List<LatLng> _selectedPoints = [];
  bool _isMapView = false;
  bool _isSatellite = true;
  final MapController _mapController = MapController();

  // Advanced Map Tools
  int _selectedToolIndex = 0; // 0: Draw, 1: Move Point, 2: Move Plot, 3: Delete
  int? _draggingPointIndex;
  bool _isDraggingPlot = false;
  bool _hasConflict = false;
  bool _hasInvalidGeometry = false;

  bool get _hasShapeIssue => _hasConflict || _hasInvalidGeometry;

  @override
  void initState() {
    super.initState();
    // Fetch all lands to check for conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LandProvider>().fetchAllLands();
    });
  }

  void _checkConflicts() {
    final allLands = context.read<LandProvider>().allLands;
    final bool hasInvalidGeometry =
        _selectedPoints.length >= 3 &&
        GeometryUtils.hasSelfIntersections(_selectedPoints);
    bool conflict = false;

    if (!hasInvalidGeometry && _selectedPoints.length >= 3) {
      for (var existingLand in allLands) {
        if (existingLand.boundaries != null &&
            existingLand.boundaries!.length >= 3) {
          if (GeometryUtils.doPolygonsIntersect(
            _selectedPoints,
            existingLand.boundaries!,
          )) {
            conflict = true;
            break;
          }
        }
      }
    }

    _syncDimensionFieldsFromBoundary();

    _hasInvalidGeometry = hasInvalidGeometry;
    _hasConflict = conflict;
  }

  void _syncDimensionFieldsFromBoundary() {
    if (_selectedPoints.length < 3) return;

    final bounds = GeometryUtils.estimateBoundsMeters(_selectedPoints);
    final width = bounds.widthMeters.clamp(10.0, 500.0);
    final height = bounds.heightMeters.clamp(10.0, 500.0);

    final widthText = width.toStringAsFixed(1);
    final heightText = height.toStringAsFixed(1);

    if (_widthController.text != widthText) {
      _widthController.text = widthText;
    }
    if (_heightController.text != heightText) {
      _heightController.text = heightText;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'List New Land',
          style: TextStyle(color: theme.textTheme.titleLarge?.color),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textTheme.titleLarge?.color),
        actions: [
          if (_isMapView)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _hasShapeIssue
                  ? null
                  : () => setState(() => _isMapView = false),
            ),
        ],
      ),
      body: _isMapView ? _buildMapPicker() : _buildForm(),
      bottomNavigationBar: _isMapView
          ? null
          : Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: ElevatedButton(
                onPressed: (_isLoading || _hasShapeIssue) ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: _hasShapeIssue ? Colors.grey : Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
              ),
            ),
    );
  }

  Widget _buildForm() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Property Details',
              style: TextStyle(
                color: theme.textTheme.titleLarge?.color,
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
            const SizedBox(height: 20),
            _buildInputField(
              controller: _priceController,
              label: 'Monthly Rent Price (TND)',
              hint: '1200.0',
              icon: Icons.payments_rounded,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'Price cannot be empty';
                final val = double.tryParse(v.trim());
                if (val == null) return 'Please enter a valid numeric amount';
                if (val <= 0) return 'Price must be greater than 0';
                if (val > 1000000) return 'Price exceeds maximum allowed limit';
                return null;
              },
            ),
            const SizedBox(height: 32),
            Text(
              'Spatial Dimensions',
              style: TextStyle(
                color: theme.textTheme.titleLarge?.color,
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
                    label: 'Width (Auto)',
                    hint: 'Auto from boundary',
                    icon: Icons.straighten_rounded,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    readOnly: true,
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
                    label: 'Height (Auto)',
                    hint: 'Auto from boundary',
                    icon: Icons.square_foot_rounded,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    readOnly: true,
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
                Text(
                  'Boundaries',
                  style: TextStyle(
                    color: theme.textTheme.titleLarge?.color,
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
                  color: _hasShapeIssue
                      ? Colors.red.withOpacity(0.05)
                      : theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _hasShapeIssue
                        ? Colors.red
                        : (_selectedPoints.length >= 3
                              ? Colors.green.withOpacity(0.3)
                              : (isDark ? Colors.white : Colors.black)
                                    .withOpacity(0.05)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _hasShapeIssue
                            ? Colors.red.withOpacity(0.1)
                            : (_selectedPoints.length >= 3
                                      ? Colors.green
                                      : (isDark ? Colors.white : Colors.black))
                                  .withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _hasShapeIssue
                            ? Icons.warning_rounded
                            : Icons.polyline_rounded,
                        color: _hasShapeIssue
                            ? Colors.red
                            : (_selectedPoints.length >= 3
                                  ? Colors.green
                                  : (isDark ? Colors.white38 : Colors.black38)),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _hasInvalidGeometry
                                ? 'Invalid Geometry'
                                : (_hasConflict
                                      ? 'Conflict Detected'
                                      : (_selectedPoints.isEmpty
                                            ? 'Perimeter not set'
                                            : '${_selectedPoints.length} Points Defined')),
                            style: TextStyle(
                              color: _hasShapeIssue
                                  ? Colors.red
                                  : (_selectedPoints.length >= 3
                                        ? Colors.green
                                        : theme.textTheme.bodyLarge?.color),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _hasInvalidGeometry
                                ? 'Polygon edges intersect. Adjust points to fix shape.'
                                : (_hasConflict
                                      ? 'Overlaps with existing land'
                                      : (_selectedPoints.length < 3
                                            ? 'Tap to draw land boundaries'
                                            : 'Geometry verified and valid')),
                            style: TextStyle(
                              color: _hasShapeIssue
                                  ? Colors.red.withOpacity(0.7)
                                  : (isDark ? Colors.white38 : Colors.black38),
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
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.38),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          readOnly: readOnly,
          keyboardType: keyboardType,
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 16,
          ),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.24),
              fontSize: 15,
            ),
            prefixIcon: Icon(
              icon,
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.24),
              size: 20,
            ),
            filled: true,
            fillColor: theme.cardColor,
            contentPadding: const EdgeInsets.all(20),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
              ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final allLands = context.watch<LandProvider>().allLands;

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(36.8065, 10.1815),
            initialZoom: 15.0,
            onTap: (tapPosition, latLng) {
              if (_selectedToolIndex == 0) {
                // DRAW MODE
                setState(() {
                  _selectedPoints.add(latLng);
                  _checkConflicts();
                });
              } else if (_selectedToolIndex == 1) {
                // MOVE POINT MODE - Tap empty space deselects
                setState(() => _draggingPointIndex = null);
              }
            },
            interactionOptions: InteractionOptions(
              flags:
                  _selectedToolIndex ==
                      2 // If moving plot, disable map drag
                  ? InteractiveFlag.rotate |
                        InteractiveFlag.pinchZoom |
                        InteractiveFlag.doubleTapZoom
                  : InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: _isSatellite
                  ? "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
                  : "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: 'com.farmy.app',
              tileBuilder: (context, tileWidget, tile) {
                if (_isSatellite || !isDark) return tileWidget;
                return ColorFiltered(
                  colorFilter: const ColorFilter.matrix([
                    -1,
                    0,
                    0,
                    0,
                    255,
                    0,
                    -1,
                    0,
                    0,
                    255,
                    0,
                    0,
                    -1,
                    0,
                    255,
                    0,
                    0,
                    0,
                    1,
                    0,
                  ]),
                  child: tileWidget,
                );
              },
            ),

            // Render Existing Lands
            PolygonLayer(
              polygons: allLands.where((l) => l.boundaries != null).map((land) {
                return Polygon(
                  points: land.boundaries!,
                  color: Colors.red.withOpacity(0.15), // Conflict zones
                  borderColor: Colors.red.withOpacity(0.5),
                  borderStrokeWidth: 1,
                  isFilled: true,
                );
              }).toList(),
            ),

            // Render Current Polygon
            if (_selectedPoints.isNotEmpty)
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: _selectedPoints,
                    color: _hasConflict
                        ? Colors.red.withOpacity(0.4)
                        : Colors.green.withOpacity(0.4),
                    borderColor: _hasConflict ? Colors.red : Colors.white,
                    borderStrokeWidth: 3,
                    isFilled: true,
                  ),
                ],
              ),

            // Interactive Markers
            MarkerLayer(
              markers: _selectedPoints.asMap().entries.map((entry) {
                final idx = entry.key;
                final point = entry.value;
                final isSelected = _draggingPointIndex == idx;

                return Marker(
                  point: point,
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onPanStart: (details) {
                      if (_selectedToolIndex == 1) {
                        setState(() => _draggingPointIndex = idx);
                      } else if (_selectedToolIndex == 2) {
                        setState(() {
                          _isDraggingPlot = true;
                        });
                      }
                    },
                    onPanUpdate: (details) {
                      if (_selectedToolIndex == 1 &&
                          _draggingPointIndex != null) {
                        // Move single point
                        final pointOffset = _mapController.camera
                            .latLngToScreenPoint(point);
                        final newScreenPoint = Point<double>(
                          pointOffset.x + details.delta.dx,
                          pointOffset.y + details.delta.dy,
                        );
                        final newLatLng = _mapController.camera.pointToLatLng(
                          newScreenPoint,
                        );

                        setState(() {
                          _selectedPoints[idx] = newLatLng;
                          _checkConflicts();
                        });
                      } else if (_selectedToolIndex == 2 && _isDraggingPlot) {
                        // Move entire plot (Incremental)
                        final pointOffset = _mapController.camera
                            .latLngToScreenPoint(point);
                        final newScreenPoint = Point<double>(
                          pointOffset.x + details.delta.dx,
                          pointOffset.y + details.delta.dy,
                        );
                        final newLatLng = _mapController.camera.pointToLatLng(
                          newScreenPoint,
                        );

                        final latDelta = newLatLng.latitude - point.latitude;
                        final lngDelta = newLatLng.longitude - point.longitude;

                        setState(() {
                          for (int i = 0; i < _selectedPoints.length; i++) {
                            _selectedPoints[i] = LatLng(
                              _selectedPoints[i].latitude + latDelta,
                              _selectedPoints[i].longitude + lngDelta,
                            );
                          }
                          _checkConflicts();
                        });
                      }
                    },
                    onPanEnd: (_) {
                      setState(() {
                        _draggingPointIndex = null;
                        _isDraggingPlot = false;
                        _checkConflicts();
                      });
                    },
                    onTap: () {
                      if (_selectedToolIndex == 3) {
                        // DELETE TOOL
                        setState(() {
                          _selectedPoints.removeAt(idx);
                          _checkConflicts();
                        });
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 20, // Hitbox
                          height: 20,
                          decoration: BoxDecoration(
                            color: _selectedToolIndex == 3
                                ? Colors.red
                                : (_selectedToolIndex == 1 && isSelected
                                      ? Colors.yellow
                                      : Colors.white),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _hasConflict ? Colors.red : Colors.green,
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _selectedToolIndex == 3
                              ? const Icon(
                                  Icons.close,
                                  size: 12,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        // Tool Palette
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildToolButton(0, Icons.edit_location_alt_rounded, 'Draw'),
                _buildToolButton(1, Icons.open_with_rounded, 'Move Point'),
                _buildToolButton(2, Icons.drag_indicator_rounded, 'Move All'),
                _buildToolButton(3, Icons.delete_outline_rounded, 'Delete'),
              ],
            ),
          ),
        ),

        // Instructions
        Positioned(
          top: 100,
          left: 40,
          right: 40,
          child: AnimatedOpacity(
            opacity: _selectedPoints.isEmpty ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Select "Draw" and tap map to add points',
                style: TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),

        // Validation Warning
        if (_hasShapeIssue)
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _hasInvalidGeometry
                          ? 'Invalid geometry! Boundary edges intersect each other.'
                          : 'Boundary conflict! Overlaps with an existing property.',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        Positioned(
          bottom: 20,
          left: 20,
          child: FloatingActionButton.extended(
            heroTag: 'clear_points',
            onPressed: () {
              setState(() {
                _selectedPoints.clear();
                _checkConflicts();
              });
            },
            label: const Text('Clear'),
            icon: const Icon(Icons.clear),
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            elevation: 2,
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
                backgroundColor: theme.cardColor,
                foregroundColor: theme.iconTheme.color,
                elevation: 2,
                child: Icon(_isSatellite ? Icons.map : Icons.satellite_alt),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.extended(
                heroTag: 'confirm_map',
                onPressed: _hasShapeIssue
                    ? null
                    : () => setState(() => _isMapView = false),
                label: const Text('Confirm'),
                icon: const Icon(Icons.check),
                backgroundColor: _hasShapeIssue ? Colors.grey : Colors.green,
                foregroundColor: Colors.white,
                elevation: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToolButton(int index, IconData icon, String label) {
    final isSelected = _selectedToolIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedToolIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.green.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? Colors.green
                  : Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Colors.green
                    : Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPoints.length < 3) {
      _showErrorSnackBar('Please select at least 3 points on the map.');
      return;
    }
    if (_hasInvalidGeometry) {
      _showErrorSnackBar(
        'Cannot publish: Invalid geometry. Boundary edges intersect.',
      );
      return;
    }
    if (_hasConflict) {
      _showErrorSnackBar('Cannot publish: Boundary conflicts detected.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await context.read<LandProvider>().createLand({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text),
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
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  void _showErrorDialog(String error) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
            const SizedBox(width: 12),
            Text(
              'Publishing Failed',
              style: TextStyle(color: theme.textTheme.titleLarge?.color),
            ),
          ],
        ),
        content: Text(
          error,
          style: TextStyle(
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'RETRY',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Listing Published!',
              style: TextStyle(
                color: theme.textTheme.titleLarge?.color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your land is now live and visible to potential investors.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Back to management
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
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
