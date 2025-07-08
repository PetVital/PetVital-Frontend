import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class CloudinaryService {
  static const String _cloudName = 'dgz0buqcx'; // Reemplaza con tu cloud name
  static const String _uploadPreset = 'flutter_upload'; // Reemplaza con tu preset name
  static const String _baseUrl = 'https://api.cloudinary.com/v1_1';
  static const String _apiKey = '622189469624135'; // Agrega tu API key
  static const String _apiSecret = 'AzOytw1sJm9YNV1vdZsyuNrReOQ'; // Agrega tu API secret

  final Dio _dio = Dio();

  Future<String?> uploadImage(File imageFile, String fileName) async {
    try {

      int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        'api_key': _apiKey,
        'timestamp': timestamp,
        'public_id': fileName, // ID público para identificar la imagen
        'folder': 'pet_images', // Carpeta donde se guardará
        'overwrite': true, // Permite sobrescribir archivos existentes
        'invalidate': true, // Invalida la cache para mostrar la nueva imagen inmediatamente
        'signature': _generateSignature(fileName, timestamp), // Firma para autenticación
      });

      // Realizar el upload
      Response response = await _dio.post(
        '$_baseUrl/$_cloudName/image/upload',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Retornar la URL segura de la imagen
        print('Imagen subida exitosamente: ${response.data['secure_url']}');
        return response.data['secure_url'];
      } else {
        print('Error en upload: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al subir imagen a Cloudinary: $e');
      return null;
    }
  }

  // Método para generar la firma de autenticación
  String _generateSignature(String publicId, int timestamp) {
    // Nota: Para generar la firma necesitas usar crypto
    // Agrega esta dependencia: crypto: ^3.0.3

    String toSign = 'folder=pet_images&invalidate=true&overwrite=true&public_id=$publicId&timestamp=$timestamp$_apiSecret';
    var bytes = utf8.encode(toSign);
    var digest = sha1.convert(bytes);
    return digest.toString();
  }

  Future<bool> deleteImage(String publicId) async {
    try {
      // Para eliminar imágenes necesitas usar el API con autenticación
      // Por simplicidad, las imágenes se pueden eliminar desde el dashboard
      // O implementar un endpoint en tu backend para eliminar
      return true;
    } catch (e) {
      print('Error al eliminar imagen: $e');
      return false;
    }
  }

  // Método para obtener URL optimizada con transformaciones
  String getOptimizedImageUrl(String publicId, {
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
  }) {
    String transformations = '';

    if (width != null || height != null) {
      transformations += 'w_${width ?? 'auto'},h_${height ?? 'auto'},c_fill/';
    }

    transformations += 'q_$quality,f_$format/';

    return 'https://res.cloudinary.com/$_cloudName/image/upload/$transformations$publicId';
  }

  // Método para obtener URL con timestamp para evitar cache
  String getImageUrlWithTimestamp(String publicId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'https://res.cloudinary.com/$_cloudName/image/upload/v$timestamp/$publicId';
  }
}