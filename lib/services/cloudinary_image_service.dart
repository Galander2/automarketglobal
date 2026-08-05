import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryUploadException implements Exception {
  const CloudinaryUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Uploads listing photos through a restricted unsigned Cloudinary preset.
///
/// No Cloudinary secret is stored in the application. The unsigned preset must
/// remain limited to images, the `automarket/cars` folder and sensible file
/// size/dimension limits in the Cloudinary console.
class CloudinaryImageService {
  CloudinaryImageService({http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  static const _cloudName = 'thjmaibn';
  static const _uploadPreset = 'automarket_cars_upload';
  static const maxFileBytes = 10 * 1024 * 1024;
  static const _timeout = Duration(seconds: 45);

  final http.Client _client;
  final bool _ownsClient;

  Future<String> uploadImage(XFile image) async {
    final declaredLength = await image.length();
    if (declaredLength <= 0) {
      throw const CloudinaryUploadException('Фотография пустая или повреждена');
    }
    if (declaredLength > maxFileBytes) {
      throw const CloudinaryUploadException(
        'Каждая фотография должна быть меньше 10 МБ',
      );
    }

    final bytes = await image.readAsBytes();
    if (bytes.isEmpty) {
      throw const CloudinaryUploadException('Фотография пустая или повреждена');
    }
    if (bytes.length > maxFileBytes) {
      throw const CloudinaryUploadException(
        'Каждая фотография должна быть меньше 10 МБ',
      );
    }
    final imageType = _detectImageType(bytes);
    if (imageType == null) {
      throw const CloudinaryUploadException(
        'Поддерживаются только фотографии JPEG, PNG и WebP',
      );
    }

    final safeName = _safeFileName(image.name, imageType.extension);
    final request = http.MultipartRequest(
      'POST',
      Uri.https('api.cloudinary.com', '/v1_1/$_cloudName/image/upload'),
    )
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: safeName),
      );

    try {
      final streamed = await _client.send(request).timeout(_timeout);
      final body = await streamed.stream.bytesToString().timeout(_timeout);
      if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
        throw CloudinaryUploadException(_safeServerError(body));
      }

      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Unexpected response');
      }
      final secureUrl = decoded['secure_url'];
      if (secureUrl is! String || !_isTrustedCloudinaryUrl(secureUrl)) {
        throw const FormatException('Invalid secure URL');
      }
      return secureUrl;
    } on CloudinaryUploadException {
      rethrow;
    } on TimeoutException {
      throw const CloudinaryUploadException(
        'Загрузка заняла слишком много времени. Проверьте интернет и повторите',
      );
    } on http.ClientException {
      throw const CloudinaryUploadException(
        'Не удалось подключиться к сервису фотографий',
      );
    } on FormatException {
      throw const CloudinaryUploadException(
        'Сервис фотографий вернул некорректный ответ',
      );
    }
  }

  void close() {
    if (_ownsClient) _client.close();
  }

  static _DetectedImage? _detectImageType(Uint8List bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xff &&
        bytes[1] == 0xd8 &&
        bytes[2] == 0xff) {
      return const _DetectedImage('jpg');
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4e &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0d &&
        bytes[5] == 0x0a &&
        bytes[6] == 0x1a &&
        bytes[7] == 0x0a) {
      return const _DetectedImage('png');
    }
    if (bytes.length >= 12 &&
        ascii.decode(bytes.sublist(0, 4), allowInvalid: true) == 'RIFF' &&
        ascii.decode(bytes.sublist(8, 12), allowInvalid: true) == 'WEBP') {
      return const _DetectedImage('webp');
    }
    return null;
  }

  static String _safeFileName(String original, String extension) {
    final base = original
        .replaceAll(RegExp(r'\.[^.]*$'), '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    final safeBase = base.isEmpty ? 'car_photo' : base;
    final trimmedBase = safeBase.length > 60
        ? safeBase.substring(0, 60)
        : safeBase;
    return '$trimmedBase.$extension';
  }

  static bool _isTrustedCloudinaryUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.scheme == 'https' &&
        uri.host == 'res.cloudinary.com' &&
        uri.pathSegments.length >= 4 &&
        uri.pathSegments.first == _cloudName &&
        uri.pathSegments[1] == 'image' &&
        uri.pathSegments[2] == 'upload';
  }

  static String _safeServerError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final error = decoded['error'];
        final message = error is Map<String, dynamic> ? error['message'] : null;
        if (message is String && message.toLowerCase().contains('file size')) {
          return 'Фотография превышает допустимый размер';
        }
      }
    } on FormatException {
      // Never expose an untrusted server response to the user.
    }
    return 'Не удалось загрузить фотографию. Повторите позже';
  }
}

class _DetectedImage {
  const _DetectedImage(this.extension);

  final String extension;
}
