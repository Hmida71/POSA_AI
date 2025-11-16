import 'dart:io';

import 'package:flutter/material.dart';
import '../global.dart';
import '../utils/constants.dart';

class ProductProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;
  int _page = 0;
  final int _loadSize = 6;

  ProductProvider();

  List<Map<String, dynamic>> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    if (_isLoading || !_hasMore) return;

    try {
      _setLoading(true);
      _setError(null);

      final from = _page * _loadSize;
      final to = from + _loadSize - 1;

      final response = await supabase
          .from('product')
          .select()
          .order('id', ascending: true)
          .range(from, to);

      debugPrint("Fetched ${response.length} items");

      if (response.isEmpty) {
        _hasMore = false;
      } else {
        _products.addAll(response);
        _page++;

        if (response.length < _loadSize) {
          _hasMore = false;
        }
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load products: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshList() async {
    _products = [];
    _page = 0;
    _hasMore = true;
    await fetchProducts();
  }

  Future<void> deleteProduct(int productId) async {
    try {
      List<Map<String, dynamic>> response =
          await supabase.from('product').delete().eq('id', productId).select();
      debugPrint("Deleted : $response");
    } catch (e) {
      _setError('Failed to delete product: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      _setLoading(true);
      _setError(null);

      final List<Map<String, dynamic>> response =
          await supabase.from('product').insert(productData).select();

      if (response.isNotEmpty) {
        _products.insert(0, response.first);
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to add product: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<String> uploadProductImage(File imageFile, String fileName) async {
    final response = await supabase.storage
        .from(AppConstants.productImagesBucket)
        .upload(fileName, imageFile);

    return supabase.storage
        .from(AppConstants.productImagesBucket)
        .getPublicUrl(response);
  }
}
