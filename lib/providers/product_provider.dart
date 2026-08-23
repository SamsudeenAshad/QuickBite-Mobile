import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../utils/app_constants.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider(this._productRepository);

  final ProductRepository _productRepository;

  List<Product> _products = <Product>[];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = AppConstants.allCategory;
  String _searchQuery = '';

  List<Product> get products => List<Product>.unmodifiable(_products);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<Product> get filteredProducts {
    final String normalisedQuery = _searchQuery.trim().toLowerCase();
    return _products
        .where((Product product) {
          final bool matchesCategory =
              _selectedCategory == AppConstants.allCategory ||
              product.category == _selectedCategory;
          final bool matchesSearch =
              normalisedQuery.isEmpty ||
              product.name.toLowerCase().contains(normalisedQuery) ||
              product.description.toLowerCase().contains(normalisedQuery);
          return matchesCategory && matchesSearch;
        })
        .toList(growable: false);
  }

  List<Product> get popularProducts {
    final List<Product> sortedProducts = List<Product>.of(_products)
      ..sort((Product a, Product b) => b.rating.compareTo(a.rating));
    return sortedProducts.take(5).toList(growable: false);
  }

  Product? productById(int id) {
    for (final Product product in _products) {
      if (product.id == id) {
        return product;
      }
    }
    return null;
  }

  Future<void> loadProducts({bool force = false}) async {
    if (_isLoading || (!force && _products.isNotEmpty)) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _productRepository.getProducts();
    } catch (error) {
      _errorMessage = 'Could not load the menu. Please try again.';
      debugPrint('ProductProvider.loadProducts: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    if (_selectedCategory == category) {
      return;
    }
    _selectedCategory = category;
    notifyListeners();
  }

  void search(String query) {
    if (_searchQuery == query) {
      return;
    }
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategory = AppConstants.allCategory;
    _searchQuery = '';
    notifyListeners();
  }
}
