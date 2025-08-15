import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../views/model/cart_model.dart';

class CartController extends ChangeNotifier {
  final CartService _cartService = CartService();
  
  List<Cart> _carts = [];
  Cart? _selectedCart;
  bool _isLoading = false;
  String? _errorMessage;
  int _totalCarts = 0;
  int _skip = 0;
  int _limit = 30;

  // Getters
  List<Cart> get carts => _carts;
  Cart? get selectedCart => _selectedCart;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalCarts => _totalCarts;
  int get skip => _skip;
  int get limit => _limit;

  // Calculate total value of all carts
  double get totalValue {
    return _carts.fold(0.0, (sum, cart) => sum + cart.total);
  }

  // Calculate total discounted value of all carts
  double get totalDiscountedValue {
    return _carts.fold(0.0, (sum, cart) => sum + cart.discountedTotal);
  }

  // Calculate total savings
  double get totalSavings {
    return totalValue - totalDiscountedValue;
  }

  // Load carts from API
  Future<void> loadCarts({bool refresh = false}) async {
    if (refresh) {
      _skip = 0;
      _carts.clear();
    }

    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      final response = await _cartService.getCarts(limit: _limit, skip: _skip);
      
      if (refresh) {
        _carts = response.carts;
      } else {
        _carts.addAll(response.carts);
      }
      
      _totalCarts = response.total;
      _skip += response.carts.length;
      
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Load more carts (pagination)
  Future<void> loadMoreCarts() async {
    if (_skip < _totalCarts && !_isLoading) {
      await loadCarts();
    }
  }

  // Load specific cart by ID
  Future<void> loadCartById(int cartId) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedCart = await _cartService.getCartById(cartId);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Add product to cart
  Future<void> addProductToCart(int userId, List<Map<String, dynamic>> products) async {
    _setLoading(true);
    _clearError();

    try {
      final newCart = await _cartService.addProductToCart(userId, products);
      _carts.insert(0, newCart);
      _totalCarts++;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Update product quantity in cart
  Future<void> updateCartProduct(int cartId, int productId, int quantity) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedCart = await _cartService.updateCartProduct(cartId, productId, quantity);
      
      // Update in carts list
      final index = _carts.indexWhere((cart) => cart.id == cartId);
      if (index != -1) {
        _carts[index] = updatedCart;
      }
      
      // Update selected cart if it's the same
      if (_selectedCart?.id == cartId) {
        _selectedCart = updatedCart;
      }
      
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Delete cart
  Future<void> deleteCart(int cartId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _cartService.deleteCart(cartId);
      if (success) {
        _carts.removeWhere((cart) => cart.id == cartId);
        _totalCarts--;
        
        // Clear selected cart if it's the deleted one
        if (_selectedCart?.id == cartId) {
          _selectedCart = null;
        }
      }
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Select a cart
  void selectCart(Cart cart) {
    _selectedCart = cart;
    notifyListeners();
  }

  // Clear selected cart
  void clearSelectedCart() {
    _selectedCart = null;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refresh() async {
    await loadCarts(refresh: true);
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get cart statistics
  Map<String, dynamic> getCartStatistics() {
    if (_carts.isEmpty) {
      return {
        'totalCarts': 0,
        'totalProducts': 0,
        'totalQuantity': 0,
        'totalValue': 0.0,
        'totalDiscountedValue': 0.0,
        'totalSavings': 0.0,
      };
    }

    int totalProducts = _carts.fold(0, (sum, cart) => sum + cart.totalProducts);
    int totalQuantity = _carts.fold(0, (sum, cart) => sum + cart.totalQuantity);

    return {
      'totalCarts': _carts.length,
      'totalProducts': totalProducts,
      'totalQuantity': totalQuantity,
      'totalValue': totalValue,
      'totalDiscountedValue': totalDiscountedValue,
      'totalSavings': totalSavings,
    };
  }
} 