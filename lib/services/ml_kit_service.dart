import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Result class for detailed validation feedback
class ValidationResult {
  final bool isValid;
  final String message;
  ValidationResult(this.isValid, this.message);
}

class MlKitService {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  final TextRecognizer _textRecognizer = TextRecognizer();

  // Common ID card keywords (multi-language support)
  static const List<String> _idKeywords = [
    // English
    'id', 'identity', 'identification', 'passport', 'license', 'licence',
    'name', 'surname', 'first name', 'last name', 'birth', 'dob', 'date of birth',
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
  static final RegExp _idNumberPattern = RegExp(
    r'\b[A-Z0-9]{6,20}\b',
  );

  /// Validates if the image is likely an ID card (FRONT - strict)
  Future<ValidationResult> validateIdCard(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      final text = recognizedText.text.toLowerCase();

      print('[ML Kit] ID Text found: ${recognizedText.text.substring(0, recognizedText.text.length.clamp(0, 100))}...');

      // Check 1: Must have sufficient text
      if (text.length < 20) {
        return ValidationResult(false, 'Not enough text found. Please scan a valid ID.');
      }

      // Check 2: Look for ID-specific keywords
      int keywordMatches = 0;
      for (final keyword in _idKeywords) {
        if (text.contains(keyword)) {
          keywordMatches++;
        }
      }
      print('[ML Kit] ID Keywords matched: $keywordMatches');

      if (keywordMatches < 2) {
        return ValidationResult(false, 'This doesn\'t look like an ID card. Please scan a valid government ID.');
      }

      // Check 3: Look for date patterns (birth date, expiry, etc.)
      final hasDate = _datePattern.hasMatch(recognizedText.text);
      print('[ML Kit] Has date pattern: $hasDate');

      // Check 4: Look for ID number patterns
      final hasIdNumber = _idNumberPattern.hasMatch(recognizedText.text);
      print('[ML Kit] Has ID number pattern: $hasIdNumber');

      // Must have at least a date OR ID number
      if (!hasDate && !hasIdNumber) {
        return ValidationResult(false, 'No ID number or date found. Please ensure the full ID is visible.');
      }

      return ValidationResult(true, 'ID card validated successfully!');
    } catch (e) {
      print('Error validating ID: $e');
      return ValidationResult(false, 'Error scanning ID. Please try again.');
    }
  }

  /// Validates the BACK of an ID card (less strict - backs often have less text)
  Future<ValidationResult> validateIdCardBack(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      final text = recognizedText.text.toLowerCase();

      print('[ML Kit] Back ID Text found: ${recognizedText.text.substring(0, recognizedText.text.length.clamp(0, 100))}...');

      // Back of ID is often simpler - just need SOME text or barcode pattern
      // Much looser check: at least 10 characters of any text
      if (text.length < 10) {
        return ValidationResult(false, 'No text detected on back. Please scan the back of your ID.');
      }

      // Optional: Look for MRZ (Machine Readable Zone) pattern on backs of IDs
      final hasMrzPattern = RegExp(r'[A-Z<]{10,}').hasMatch(recognizedText.text);
      final hasNumbers = RegExp(r'\d{4,}').hasMatch(recognizedText.text);
      
      print('[ML Kit] Back has MRZ pattern: $hasMrzPattern, has numbers: $hasNumbers');

      // Pass if we have any text (already checked above)
      return ValidationResult(true, 'Back of ID validated successfully!');
    } catch (e) {
      print('Error validating ID back: $e');
      return ValidationResult(false, 'Error scanning ID. Please try again.');
    }
  }

  /// Validates if the image contains a real, live face
  Future<ValidationResult> validateFace(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final faces = await _faceDetector.processImage(inputImage);

      print('[ML Kit] Faces detected: ${faces.length}');

      // Check 1: Must have exactly one face
      if (faces.isEmpty) {
        return ValidationResult(false, 'No face detected. Please look directly at the camera.');
      }

      if (faces.length > 1) {
        return ValidationResult(false, 'Multiple faces detected. Please ensure only your face is visible.');
      }

      final face = faces.first;

      // Check 2: Eyes must be open (liveness indicator)
      final leftEyeOpen = face.leftEyeOpenProbability ?? 0;
      final rightEyeOpen = face.rightEyeOpenProbability ?? 0;
      print('[ML Kit] Eye open probability - Left: $leftEyeOpen, Right: $rightEyeOpen');

      if (leftEyeOpen < 0.5 || rightEyeOpen < 0.5) {
        return ValidationResult(false, 'Please keep your eyes open and look at the camera.');
      }

      // Check 3: Face should be relatively frontal (head pose)
      final headEulerAngleY = face.headEulerAngleY ?? 0; // Left/right rotation
      final headEulerAngleZ = face.headEulerAngleZ ?? 0; // Tilt
      print('[ML Kit] Head angles - Y: $headEulerAngleY, Z: $headEulerAngleZ');

      if (headEulerAngleY.abs() > 30) {
        return ValidationResult(false, 'Please face the camera directly (don\'t turn your head).');
      }

      if (headEulerAngleZ.abs() > 20) {
        return ValidationResult(false, 'Please keep your head straight (don\'t tilt).');
      }

      // Check 4: Face should take up reasonable portion of image (bounding box check)
      final boundingBox = face.boundingBox;
      final faceArea = boundingBox.width * boundingBox.height;
      print('[ML Kit] Face bounding box area: $faceArea');

      // Face should be at least 10000 pixels (roughly 100x100)
      if (faceArea < 10000) {
        return ValidationResult(false, 'Face too small. Please move closer to the camera.');
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
    _faceDetector.close();
    _textRecognizer.close();
  }
}
