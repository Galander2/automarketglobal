import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_application_1_car_sales/services/cloudinary_image_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  group('CloudinaryImageService', () {
    test('uploads a validated image with the restricted unsigned preset', () async {
      late http.MultipartRequest captured;
      final client = _StubClient((request) async {
        captured = request as http.MultipartRequest;
        return _jsonResponse(200, {
          'secure_url':
              'https://res.cloudinary.com/thjmaibn/image/upload/v1/'
              'automarket/cars/car.jpg',
        });
      });
      final service = CloudinaryImageService(client: client);
      final image = XFile.fromData(
        Uint8List.fromList([0xff, 0xd8, 0xff, 0xe0, 0x00]),
        name: 'car photo.exe',
      );

      final result = await service.uploadImage(image);

      expect(
        result,
        'https://res.cloudinary.com/thjmaibn/image/upload/v1/'
        'automarket/cars/car.jpg',
      );
      expect(captured.method, 'POST');
      expect(captured.url.host, 'api.cloudinary.com');
      expect(captured.url.path, '/v1_1/thjmaibn/image/upload');
      expect(captured.fields['upload_preset'], 'automarket_cars_upload');
      expect(captured.files, hasLength(1));
      expect(captured.files.single.filename, 'car_photo.jpg');
    });

    test('rejects content that is not a supported image', () async {
      var requested = false;
      final service = CloudinaryImageService(
        client: _StubClient((request) async {
          requested = true;
          return _jsonResponse(200, const {});
        }),
      );

      await expectLater(
        service.uploadImage(
          XFile.fromData(Uint8List.fromList([1, 2, 3, 4]), name: 'fake.jpg'),
        ),
        throwsA(isA<CloudinaryUploadException>()),
      );
      expect(requested, isFalse);
    });

    test('rejects an untrusted URL returned by the upload endpoint', () async {
      final service = CloudinaryImageService(
        client: _StubClient(
          (request) async => _jsonResponse(200, {
            'secure_url': 'https://evil.example/automarket/car.jpg',
          }),
        ),
      );

      await expectLater(
        service.uploadImage(_jpegImage()),
        throwsA(
          isA<CloudinaryUploadException>().having(
            (error) => error.message,
            'message',
            'Сервис фотографий вернул некорректный ответ',
          ),
        ),
      );
    });

    test('does not expose server response details to the user', () async {
      final service = CloudinaryImageService(
        client: _StubClient(
          (request) async => http.StreamedResponse(
            Stream.value(utf8.encode('internal secret diagnostic')),
            500,
          ),
        ),
      );

      await expectLater(
        service.uploadImage(_jpegImage()),
        throwsA(
          isA<CloudinaryUploadException>().having(
            (error) => error.message,
            'message',
            'Не удалось загрузить фотографию. Повторите позже',
          ),
        ),
      );
    });
  });
}

XFile _jpegImage() => XFile.fromData(
  Uint8List.fromList([0xff, 0xd8, 0xff, 0xe0, 0x00]),
  name: 'car.jpg',
);

http.StreamedResponse _jsonResponse(int statusCode, Object body) {
  return http.StreamedResponse(
    Stream.value(utf8.encode(jsonEncode(body))),
    statusCode,
    headers: const {'content-type': 'application/json'},
  );
}

class _StubClient extends http.BaseClient {
  _StubClient(this._handler);

  final Future<http.StreamedResponse> Function(http.BaseRequest request)
  _handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _handler(request);
  }
}
