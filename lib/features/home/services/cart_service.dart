import 'dart:convert';
import 'package:http/http.dart' as http;
import '../views/model/cart_model.dart';

class CartService {
  static const String baseUrl = 'https://dummyjson.com';

  Future<CartResponse> getCarts({int limit = 30, int skip = 0}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/carts?limit=$limit&skip=$skip'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return CartResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load carts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching carts: $e');
    }
  }

  Future<Cart> getCartById(int cartId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/carts/$cartId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Cart.fromJson(jsonData);
      } else {
        throw Exception('Failed to load cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching cart: $e');
    }
  }

  Future<Cart> addProductToCart(int userId, List<Map<String, dynamic>> products) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/carts/add'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': userId,
          'products': products,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Cart.fromJson(jsonData);
      } else {
        throw Exception('Failed to add product to cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding product to cart: $e');
    }
  }

  Future<Cart> updateCartProduct(int cartId, int productId, int quantity) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/carts/$cartId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'merge': true,
          'products': [
            {
              'id': productId,
              'quantity': quantity,
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Cart.fromJson(jsonData);
      } else {
        throw Exception('Failed to update cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating cart: $e');
    }
  }

  Future<bool> deleteCart(int cartId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/carts/$cartId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting cart: $e');
    }
  }
} 