import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Result returned after a media upload to Cloudinary.
class CloudinaryUploadResult {
  const CloudinaryUploadResult({
    required this.secureUrl,
    required this.publicId,
    this.format = 'jpg',
    this.bytes = 0,
    this.width,
    this.height,
  });

  final String secureUrl;
  final String publicId;
  final String format;
  final int bytes;
  final int? width;
  final int? height;

  factory CloudinaryUploadResult.fromJson(Map<String, dynamic> json) {
    return CloudinaryUploadResult(
      secureUrl: json['secure_url'] as String? ?? '',
      publicId: json['public_id'] as String? ?? '',
      format: json['format'] as String? ?? 'jpg',
      bytes: (json['bytes'] as num?)?.toInt() ?? 0,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
    );
  }
}

/// Service to handle media uploads (avatars, receipts, outwork proofs) to Cloudinary.
class CloudinaryService {
  CloudinaryService({
    String? cloudName,
    String? uploadPreset,
  })  : cloudName = cloudName ?? _defaultCloudName,
        uploadPreset = uploadPreset ?? _defaultUploadPreset;

  // Cloudinary credentials (replace with your Cloudinary dashboard credentials)
  static const String _defaultCloudName = 'vertexhand';
  static const String _defaultUploadPreset = 'hrm_unsigned';

  final String cloudName;
  final String uploadPreset;
  final ImagePicker _picker = ImagePicker();

  /// Checks if Cloudinary credentials are set.
  bool get isConfigured =>
      cloudName.isNotEmpty &&
      uploadPreset.isNotEmpty &&
      cloudName != 'YOUR_CLOUD_NAME';

  /// Upload an [XFile] to Cloudinary (e.g. from camera or photo library).
  Future<CloudinaryUploadResult> uploadXFile(
    XFile file, {
    String folder = 'vertexhand_hrm',
    Map<String, String>? extraTags,
  }) async {
    final bytes = await file.readAsBytes();
    final filename = file.name.isNotEmpty ? file.name : 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return uploadBytes(
      bytes,
      filename: filename,
      folder: folder,
      extraTags: extraTags,
    );
  }

  /// Upload raw image bytes to Cloudinary via unsigned upload preset.
  Future<CloudinaryUploadResult> uploadBytes(
    Uint8List bytes, {
    String filename = 'upload.jpg',
    String folder = 'vertexhand_hrm',
    Map<String, String>? extraTags,
  }) async {
    if (!isConfigured) {
      debugPrint('ℹ️ [CloudinaryService] Unconfigured: using simulated CDN response for demo.');
      final simId = 'sim_${DateTime.now().millisecondsSinceEpoch}';
      return CloudinaryUploadResult(
        secureUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=500&q=80',
        publicId: simId,
        bytes: bytes.length,
        format: 'jpg',
      );
    }

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = folder;

    if (extraTags != null && extraTags.isNotEmpty) {
      request.fields['tags'] = extraTags.values.join(',');
    }

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: filename,
    ));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return CloudinaryUploadResult.fromJson(data);
      } else {
        debugPrint('⚠️ [CloudinaryService] Upload error (${response.statusCode}): ${response.body}');
        throw Exception('Cloudinary upload failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('⚠️ [CloudinaryService] Exception during upload: $e');
      rethrow;
    }
  }

  /// Convenience method: prompts user to pick an image from [source] (camera or gallery)
  /// and immediately uploads it to Cloudinary. Returns null if canceled.
  Future<CloudinaryUploadResult?> pickAndUploadImage({
    ImageSource source = ImageSource.gallery,
    String folder = 'vertexhand_hrm',
    double? maxWidth = 1600,
    double? maxHeight = 1600,
    int? imageQuality = 85,
  }) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (picked == null) return null;
      return await uploadXFile(picked, folder: folder);
    } catch (e) {
      debugPrint('⚠️ [CloudinaryService] pickAndUploadImage error: $e');
      rethrow;
    }
  }
}

