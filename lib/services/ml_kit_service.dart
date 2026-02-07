import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart'
    as google_ml;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'
    as google_ml_text;
import 'package:vision_text_recognition/vision_text_recognition.dart'
    as hybrid_ocr;
import 'package:apple_vision_face_detection/apple_vision_face_detection.dart'
    as apple_vision;

/// Result class for detailed validation feedback
class ValidationResult {
  final bool isValid;
  final String message;
  ValidationResult(this.isValid, this.message);
}

class MlKitService {
  // Google ML Kit (Android)
  google_ml.FaceDetector? _googleFaceDetector;
  google_ml_text.TextRecognizer? _googleTextRecognizer;

  // Apple Vision (iOS)
  apple_vision.AppleVisionFaceDetectionController? _appleFaceDetector;

  MlKitService() {
    if (Platform.isAndroid) {
      _googleFaceDetector = google_ml.FaceDetector(
        options: google_ml.FaceDetectorOptions(
          enableContours: true,
          enableClassification: true,
          enableTracking: true,
          performanceMode: google_ml.FaceDetectorMode.accurate,
        ),
      );
      _googleTextRecognizer = google_ml_text.TextRecognizer();
    } else if (Platform.isIOS) {
      _appleFaceDetector = apple_vision.AppleVisionFaceDetectionController();
    }
  }

  // Common ID card keywords (multi-language support)
  static const List<String> _idKeywords = [
    // English
    'id', 'identity', 'identification', 'passport', 'license', 'licence',
    'name',
    'surname',
    'first name',
    'last name',
    'birth',
    'dob',
    'date of birth',
    'expiry', 'expires', 'valid', 'issued', 'nationality', 'sex', 'gender',
    'address', 'signature', 'photo', 'card', 'driver', 'national',
    // French
    'carte', 'identité', 'nom', 'prénom', 'née', 'naissance',
    // Arabic transliterated
    'bitaqa', 'hawiya',
    // Common abbreviations
    'dln', 'ssn', 'mrz',
  ];

  // Date pattern regex (common formats)
  static final RegExp _datePattern = RegExp(
    r'\b(\d{1,2}[/\-\.]\d{1,2}[/\-\.]\d{2,4})|(\d{4}[/\-\.]\d{1,2}[/\-\.]\d{1,2})\b',
  );

  // ID number pattern (alphanumeric sequences common on IDs)
  static final RegExp _idNumberPattern = RegExp(r'\b[A-Z0-9]{6,20}\b');

  /// Helper to get image size from file
  Future<Size> _getImageSize(Uint8List bytes) async {
    final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(
      bytes,
    );
    final ui.ImageDescriptor descriptor = await ui.ImageDescriptor.encoded(
      buffer,
    );
    return Size(descriptor.width.toDouble(), descriptor.height.toDouble());
  }

  /// Validates if the image is likely an ID card (FRONT - strict)
  Future<ValidationResult> validateIdCard(File imageFile) async {
    try {
      String text = '';
      String fullText = '';

      if (Platform.isIOS) {
        final Uint8List bytes = await imageFile.readAsBytes();
        final result = await hybrid_ocr.VisionTextRecognition.recognizeText(
          bytes,
        );
        text = result.fullText.toLowerCase();
        fullText = result.fullText;
      } else {
        final inputImage = google_ml_text.InputImage.fromFile(imageFile);
        final recognizedText = await _googleTextRecognizer!.processImage(
          inputImage,
        );
        text = recognizedText.text.toLowerCase();
        fullText = recognizedText.text;
      }

      print(
        '[Vision] ID Text found: ${fullText.substring(0, fullText.length.clamp(0, 100))}...',
      );

      // Check 1: Must have sufficient text
      if (text.length < 20) {
        return ValidationResult(
          false,
          'Not enough text found. Please scan a valid ID.',
        );
      }

      // Check 2: Look for ID-specific keywords
      int keywordMatches = 0;
      for (final keyword in _idKeywords) {
        if (text.contains(keyword)) {
          keywordMatches++;
        }
      }
      print('[Vision] ID Keywords matched: $keywordMatches');

      if (keywordMatches < 2) {
        return ValidationResult(
          false,
          'This doesn\'t look like an ID card. Please scan a valid government ID.',
        );
      }

      // Check 3: Look for date patterns (birth date, expiry, etc.)
      final hasDate = _datePattern.hasMatch(fullText);
      print('[Vision] Has date pattern: $hasDate');

      // Check 4: Look for ID number patterns
      final hasIdNumber = _idNumberPattern.hasMatch(fullText);
      print('[Vision] Has ID number pattern: $hasIdNumber');

      // Must have at least a date OR ID number
      if (!hasDate && !hasIdNumber) {
        return ValidationResult(
          false,
          'No ID number or date found. Please ensure the full ID is visible.',
        );
      }

      return ValidationResult(true, 'ID card validated successfully!');
    } catch (e) {
      print('Error validating ID: $e');
      return ValidationResult(false, 'Error scanning ID. Please try again.');
    }
  }

  /// Validates the BACK of an ID card (moderate checks - backs have less text but should have numbers/barcodes)
  Future<ValidationResult> validateIdCardBack(File imageFile) async {
    try {
      String text = '';
      String fullText = '';

      if (Platform.isIOS) {
        final Uint8List bytes = await imageFile.readAsBytes();
        final result = await hybrid_ocr.VisionTextRecognition.recognizeText(
          bytes,
        );
        text = result.fullText.toLowerCase();
        fullText = result.fullText;
      } else {
        final inputImage = google_ml_text.InputImage.fromFile(imageFile);
        final recognizedText = await _googleTextRecognizer!.processImage(
          inputImage,
        );
        text = recognizedText.text.toLowerCase();
        fullText = recognizedText.text;
      }

      print(
        '[Vision] Back ID Text found: ${fullText.substring(0, fullText.length.clamp(0, 100))}...',
      );

      // Check 1: Must have at least 15 characters
      if (text.length < 15) {
        return ValidationResult(
          false,
          'Not enough text detected. Please scan the back of your ID clearly.',
        );
      }

      // Check 2: Look for MRZ (Machine Readable Zone) pattern - common on ID backs
      final hasMrzPattern = RegExp(r'[A-Z<]{8,}').hasMatch(fullText);

      // Check 3: Must have numbers (serial numbers, barcodes, dates are on all ID backs)
      final hasNumbers = RegExp(r'\d{3,}').hasMatch(fullText);

      // Check 4: Look for any ID-related keywords (even on backs)
      final backKeywords = [
        'address',
        'signature',
        'valid',
        'issued',
        'expires',
        'expiry',
        'mrz',
        'code',
        'no',
        'num',
        'serial',
      ];
      int keywordMatches = 0;
      for (final keyword in backKeywords) {
        if (text.contains(keyword)) keywordMatches++;
      }

      print(
        '[Vision] Back - MRZ: $hasMrzPattern, Numbers: $hasNumbers, Keywords: $keywordMatches',
      );

      // Must have at least numbers OR MRZ pattern OR keyword match
      if (!hasNumbers && !hasMrzPattern && keywordMatches == 0) {
        return ValidationResult(
          false,
          'This doesn\'t look like an ID card back. Please scan a valid ID.',
        );
      }

      return ValidationResult(true, 'Back of ID validated successfully!');
    } catch (e) {
      print('Error validating ID back: $e');
      return ValidationResult(false, 'Error scanning ID. Please try again.');
    }
  }

  /// Validates if the image contains a real, live face
  Future<ValidationResult> validateFace(File imageFile) async {
    try {
      int faceCount = 0;
      double leftEyeOpenProb = 1.0;
      double rightEyeOpenProb = 1.0;
      double headAngleY = 0;
      double headAngleZ = 0;
      double faceArea = 20000;

      if (Platform.isIOS) {
        final Uint8List bytes = await imageFile.readAsBytes();
        final ui.Size size = await _getImageSize(bytes);

        final List<Rect>? faces = await _appleFaceDetector!.processImage(
          bytes,
          size,
        );
        faceCount = faces?.length ?? 0;
        if (faces != null && faces.isNotEmpty) {
          final face = faces.first;
          // Apple Vision Rect doesn't have open probability or angles directly in the basic Rect result
          leftEyeOpenProb = 1.0;
          rightEyeOpenProb = 1.0;
          faceArea = face.width * face.height;
        }
      } else {
        final inputImage = google_ml.InputImage.fromFile(imageFile);
        final faces = await _googleFaceDetector!.processImage(inputImage);
        faceCount = faces.length;
        if (faces.isNotEmpty) {
          final face = faces.first;
          leftEyeOpenProb = face.leftEyeOpenProbability ?? 0.5;
          rightEyeOpenProb = face.rightEyeOpenProbability ?? 0.5;
          headAngleY = face.headEulerAngleY ?? 0;
          headAngleZ = face.headEulerAngleZ ?? 0;
          final boundingBox = face.boundingBox;
          faceArea = (boundingBox.width * boundingBox.height).toDouble();
        }
      }

      print('[Vision] Faces detected: $faceCount');

      // Check 1: Must have exactly one face
      if (faceCount == 0) {
        return ValidationResult(
          false,
          'No face detected. Please look directly at the camera.',
        );
      }

      if (faceCount > 1) {
        return ValidationResult(
          false,
          'Multiple faces detected. Please ensure only your face is visible.',
        );
      }

      // Check 2: Eyes must be open (liveness indicator)
      print(
        '[Vision] Eye open probability - Left: $leftEyeOpenProb, Right: $rightEyeOpenProb',
      );

      if (leftEyeOpenProb < 0.5 || rightEyeOpenProb < 0.5) {
        return ValidationResult(
          false,
          'Please keep your eyes open and look at the camera.',
        );
      }

      // Check 3: Face should be relatively frontal (head pose)
      print('[Vision] Head angles - Y: $headAngleY, Z: $headAngleZ');

      if (headAngleY.abs() > 30) {
        return ValidationResult(
          false,
          'Please face the camera directly (don\'t turn your head).',
        );
      }

      if (headAngleZ.abs() > 20) {
        return ValidationResult(
          false,
          'Please keep your head straight (don\'t tilt).',
        );
      }

      // Check 4: Face should take up reasonable portion of image (bounding box check)
      print('[Vision] Face bounding box area: $faceArea');

      // Face should be at least 10000 pixels (roughly 100x100)
      if (faceArea < 10000) {
        return ValidationResult(
          false,
          'Face too small. Please move closer to the camera.',
        );
      }

      return ValidationResult(true, 'Face validated successfully!');
    } catch (e) {
      print('Error validating face: $e');
      return ValidationResult(false, 'Error detecting face. Please try again.');
    }
  }

  // Legacy methods for backward compatibility
  Future<bool> hasFace(File imageFile) async {
    final result = await validateFace(imageFile);
    return result.isValid;
  }

  Future<bool> hasText(File imageFile) async {
    final result = await validateIdCard(imageFile);
    return result.isValid;
  }

  void dispose() {
    if (Platform.isAndroid) {
      _googleFaceDetector?.close();
      _googleTextRecognizer?.close();
    }
  }
}
