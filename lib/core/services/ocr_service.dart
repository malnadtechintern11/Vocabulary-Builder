import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

/// Result data structure holding extracted text details from on-device OCR
class OcrResult {
  final String rawText;
  final List<String> lines;
  final List<String> words;
  final String imagePath;

  const OcrResult({
    required this.rawText,
    required this.lines,
    required this.words,
    required this.imagePath,
  });

  bool get isEmpty => rawText.trim().isEmpty;
  bool get isNotEmpty => rawText.trim().isNotEmpty;
}

/// Service providing 100% offline on-device text recognition using Google ML Kit
class OcrService {
  static OcrService? _instance;
  final ImagePicker _imagePicker;
  final ImageCropper _imageCropper;
  TextRecognizer? _textRecognizer;

  OcrService._({ImagePicker? imagePicker, ImageCropper? imageCropper})
      : _imagePicker = imagePicker ?? ImagePicker(),
        _imageCropper = imageCropper ?? ImageCropper();

  factory OcrService({ImagePicker? imagePicker, ImageCropper? imageCropper}) {
    if (imagePicker != null || imageCropper != null) {
      return OcrService._(imagePicker: imagePicker, imageCropper: imageCropper);
    }
    return _instance ??= OcrService._();
  }

  TextRecognizer get _recognizer {
    return _textRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
  }

  /// Pick an image from camera or gallery
  Future<XFile?> pickImage({required ImageSource source}) async {
    try {
      final xFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );
      return xFile;
    } catch (_) {
      return null;
    }
  }

  /// Crop an existing image file using ImageCropper
  Future<String?> cropImage(String imagePath) async {
    try {
      final croppedFile = await _imageCropper.cropImage(
        sourcePath: imagePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Text Area',
            toolbarColor: const Color(0xFF4F46E5),
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: const Color(0xFF4F46E5),
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            title: 'Crop Text Area',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
        ],
      );
      return croppedFile?.path;
    } catch (_) {
      return null;
    }
  }

  /// Perform on-device offline OCR on the given image file path
  Future<OcrResult> recognizeText(String imagePath) async {
    final file = File(imagePath);
    if (!file.existsSync()) {
      return OcrResult(
        rawText: '',
        lines: const [],
        words: const [],
        imagePath: imagePath,
      );
    }

    final inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText = await _recognizer.processImage(inputImage);

    final rawText = recognizedText.text;
    final List<String> lines = [];
    final Set<String> uniqueWords = <String>{};

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final trimmedLine = line.text.trim();
        if (trimmedLine.isNotEmpty) {
          lines.add(trimmedLine);
        }
        for (final element in line.elements) {
          final word = element.text.trim().replaceAll(RegExp(r'[^\w\s\-]'), '');
          if (word.isNotEmpty && word.length > 1) {
            uniqueWords.add(word);
          }
        }
      }
    }

    return OcrResult(
      rawText: rawText,
      lines: lines,
      words: uniqueWords.toList(),
      imagePath: imagePath,
    );
  }

  /// Closes the ML Kit recognizer to free on-device memory
  Future<void> dispose() async {
    await _textRecognizer?.close();
    _textRecognizer = null;
  }
}
