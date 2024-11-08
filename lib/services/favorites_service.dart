import 'package:http/http.dart' as http;
import 'dart:convert';

class FavoritesService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  static Future<List<Map<String, dynamic>>> getUserFavorites(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/favoritos/$userId'),
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      print('Error al obtener favoritos: $e');
      return [];
    }
  }

  static Future<bool> isFavorite(String userId, String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/favoritos/$userId/$productId'),
      );
      return response.statusCode == 200 && json.decode(response.body) == true;
    } catch (e) {
      print('Error al verificar favorito: $e');
      return false;
    }
  }

  static Future<bool> addToFavorites(String userId, String productId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/favoritos'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_us': userId,
          'id_prod': int.parse(productId),
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error al agregar favorito: $e');
      return false;
    }
  }

  static Future<bool> removeFromFavorites(String userId, String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/favoritos/$userId/$productId'),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error al eliminar favorito: $e');
      return false;
    }
  }
} 