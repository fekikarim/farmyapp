import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:farmyapp/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:farmyapp/providers/auth_provider.dart';
import 'package:farmyapp/services/ml_kit_service.dart';
import 'package:farmyapp/services/kyc_service.dart';

class KycFlowScreen extends StatefulWidget {
  final String role; // 'farmer' or 'investor'

  const KycFlowScreen({super.key, required this.role});

  @override
  State<KycFlowScreen> createState() => _KycFlowScreenState();
}

class _KycFlowScreenState extends State<KycFlowScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  late final MlKitService _mlKitService;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  int _currentStep = 0; // 0: Front, 1: Back, 2: Selfie
  bool _isProcessing = false;
  bool _showTransition = false;
  String _transitionMessage = '';
  IconData _transitionIcon = Icons.credit_card;

  final Map<String, File> _capturedFiles = {};

  @override
  void initState() {
    super.initState();
    _mlKitService = MlKitService();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.noCamerasFound)),
        );
      }
      return;
    }

    // Use front camera for selfie (step 2), back for ID (step 0, 1)
    CameraDescription cameraDescription;
    try {
      cameraDescription = _currentStep == 2
          ? cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
            )
          : cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
            );
    } catch (_) {
      // Fallback to first camera if preferred direction not found
      cameraDescription = cameras.first;
    }

    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      print('Camera Error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _mlKitService.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _showTransitionScreen(String message, IconData icon) async {
    setState(() {
      _showTransition = true;
      _transitionMessage = message;
      _transitionIcon = icon;
    });
    _animController.reset();
    _animController.forward();
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() => _showTransition = false);
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isProcessing)
      return;

    setState(() => _isProcessing = true);

    try {
      final XFile image = await _controller!.takePicture();
      final File file = File(image.path);

      // Show processing screen
      await _showProcessingScreen(file);
    } catch (e) {
      print('Capture Error: $e');
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _showProcessingScreen(File file) async {
    // Navigate to processing screen
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => _ValidationScreen(
          imageFile: file,
          step: _currentStep,
          mlKitService: _mlKitService,
        ),
      ),
    );

    if (result == true) {
      // Validation passed - save file
      String key = ['front_image', 'back_image', 'selfie_image'][_currentStep];
      _capturedFiles[key] = file;

      if (_currentStep < 2) {
        // Show transition animation
        if (_currentStep == 0) {
          await _showTransitionScreen(
            AppLocalizations.of(context)!.flipIdInstruction,
            Icons.flip,
          );
        } else if (_currentStep == 1) {
          await _showTransitionScreen(
            AppLocalizations.of(context)!.selfieInstruction,
            Icons.face,
          );
        }

        setState(() {
          _currentStep++;
          _isProcessing = false;
        });
        // Re-init camera if switching to selfie
        if (_currentStep == 2) await _initializeCamera();
      } else {
        // Submit
        await _submitKyc();
      }
    } else {
      // Validation failed - stay on same step
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _submitKyc() async {
    try {
      // Show uploading screen
      setState(() => _showTransition = true);
      _transitionMessage = AppLocalizations.of(context)!.uploadingDocuments;
      _transitionIcon = Icons.cloud_upload;
      _animController.reset();
      _animController.repeat();

      final result = await KycService.submitKyc(
        role: widget.role,
        frontImage: _capturedFiles['front_image']!,
        backImage: _capturedFiles['back_image']!,
        selfieImage: _capturedFiles['selfie_image']!,
      );

      if (mounted) {
        // Refresh user data to get new role
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.refreshUser();

        // Show success and navigate to main screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.kycSuccess(widget.role)),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to main screen
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _showTransition = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
      setState(() => _isProcessing = false);
    }
  }

  String get _instruction {
    switch (_currentStep) {
      case 0:
        return AppLocalizations.of(context)!.scanFrontId;
      case 1:
        return AppLocalizations.of(context)!.scanBackId;
      case 2:
        return AppLocalizations.of(context)!.takeSelfie;
      default:
        return '';
    }
  }

  String get _hint {
    switch (_currentStep) {
      case 0:
        return AppLocalizations.of(context)!.positionIdHint;
      case 1:
        return AppLocalizations.of(context)!.flipIdHint;
      case 2:
        return AppLocalizations.of(context)!.lookAtCameraHint;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show transition screen
    if (_showTransition) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_transitionIcon, size: 100, color: Colors.green),
                const SizedBox(height: 24),
                Text(
                  _transitionMessage,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(color: Colors.green),
              ],
            ),
          ),
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Center(child: CameraPreview(_controller!)),

          // Overlay (Darken outside)
          _buildOverlay(),

          // Instruction Text
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  _instruction,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _hint,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    shadows: const [Shadow(blurRadius: 4, color: Colors.black)],
                  ),
                ),
              ],
            ),
          ),

          // Step indicator
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStepDot(0),
                const SizedBox(width: 8),
                _buildStepDot(1),
                const SizedBox(width: 8),
                _buildStepDot(2),
              ],
            ),
          ),

          // Capture Button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : GestureDetector(
                      onTap: _takePicture,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: Colors.white.withOpacity(0.3),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
            ),
          ),

          // Back Button
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDot(int step) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? Colors.green
            : (isActive ? Colors.white : Colors.white30),
      ),
      child: isCompleted
          ? const Icon(Icons.check, size: 10, color: Colors.white)
          : null,
    );
  }

  Widget _buildOverlay() {
    return ColorFiltered(
      colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.srcOut),
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
              backgroundBlendMode: BlendMode.dstOut,
            ),
          ),
          Center(
            child: Container(
              width: _currentStep == 2
                  ? 280
                  : MediaQuery.of(context).size.width * 0.85,
              height: _currentStep == 2 ? 360 : 220,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(
                  _currentStep == 2 ? 140 : 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Validation Screen - shows after taking a picture
class _ValidationScreen extends StatefulWidget {
  final File imageFile;
  final int step;
  final MlKitService mlKitService;

  const _ValidationScreen({
    required this.imageFile,
    required this.step,
    required this.mlKitService,
  });

  @override
  State<_ValidationScreen> createState() => _ValidationScreenState();
}

class _ValidationScreenState extends State<_ValidationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isValidating = true;
  ValidationResult? _result;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _validate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _validate() async {
    ValidationResult result;

    if (widget.step == 2) {
      // Selfie
      result = await widget.mlKitService.validateFace(widget.imageFile);
    } else if (widget.step == 1) {
      // Back of ID - use looser validation
      result = await widget.mlKitService.validateIdCardBack(widget.imageFile);
    } else {
      // Front of ID - strict validation
      result = await widget.mlKitService.validateIdCard(widget.imageFile);
    }

    if (mounted) {
      setState(() {
        _isValidating = false;
        _result = result;
      });

      // Auto-close after delay if successful
      if (result.isValid) {
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Image preview
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _result == null
                        ? Colors.white30
                        : (_result!.isValid ? Colors.green : Colors.red),
                    width: 3,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.file(
                    widget.imageFile,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),

            // Status
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isValidating) ...[
                    RotationTransition(
                      turns: _controller,
                      child: const Icon(
                        Icons.sync,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      AppLocalizations.of(context)!.verifying,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ] else if (_result != null) ...[
                    Icon(
                      _result!.isValid ? Icons.check_circle : Icons.error,
                      color: _result!.isValid ? Colors.green : Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _result!.message,
                      style: TextStyle(
                        color: _result!.isValid ? Colors.green : Colors.red,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (!_result!.isValid) ...[
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context, false),
                        icon: const Icon(Icons.refresh),
                        label: Text(AppLocalizations.of(context)!.tryAgain),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
