import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart' as http_parser;

Future<String?> uploadImageToCloudinary(Uint8List imageBytes) async {
  final cloudName = 'dn9cspqmi';
  final uploadPreset = 'ml_default';

  final uri = Uri.parse(
    'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
  );

  // Create multipart request
  final request =
      http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            imageBytes,
            filename: 'upload.jpg', // Filename is required
            contentType: http_parser.MediaType(
              'image',
              'jpeg',
            ), // Import http_parser for this line
          ),
        );

  final response = await request.send();

  if (response.statusCode == 200) {
    final resStr = await response.stream.bytesToString();
    final resJson = json.decode(resStr);
    return resJson['secure_url'] as String?;
  } else {
    print('Cloudinary upload failed with status: ${response.statusCode}');
    return null;
  }
}
