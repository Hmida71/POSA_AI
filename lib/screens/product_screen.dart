import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:posa_ai_app/widgets/lazy_loading_image.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _prixController = TextEditingController();
  final _imageController = TextEditingController();
  final _categoryIdController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProductProvider>().fetchProducts();
    });

    // Set up scroll listener
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    // Check if we're at bottom of list and can't scroll further
    if (!_scrollController.hasClients) return;

    // _scrollController.position.pixels == _scrollController.position.maxScrollExtent //!`For 100% (only load when reaching the very bottom)`
    // _scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.7 //!`Load more when user scrolls to 70% of the list`
    // _scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.5 //!`For 50% of the list`
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.7) {
      // Use debounce to delay the call
      if (_debounce?.isActive ?? false) _debounce!.cancel();

      _debounce = Timer(const Duration(milliseconds: 300), () {
        if (!context.read<ProductProvider>().isLoading &&
            context.read<ProductProvider>().hasMore) {
          context.read<ProductProvider>().fetchProducts();
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _nameController.dispose();
    _prixController.dispose();
    _imageController.dispose();
    _categoryIdController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Product'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _prixController,
                decoration: const InputDecoration(labelText: 'Prix'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter a prix';
                  if (double.tryParse(value!) == null) return 'Invalid prix';
                  return null;
                },
              ),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              TextFormField(
                controller: _categoryIdController,
                decoration: const InputDecoration(labelText: 'Category ID'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a category ID';
                  }
                  if (int.tryParse(value!) == null) {
                    return 'Invalid category ID';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                try {
                  await context.read<ProductProvider>().addProduct({
                    'name': _nameController.text,
                    'prix': double.parse(_prixController.text),
                    'image': _imageController.text,
                    'category_id': int.parse(_categoryIdController.text),
                    'user_id': context.read<AuthProvider>().currentUser?.id,
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    _nameController.clear();
                    _prixController.clear();
                    _imageController.clear();
                    _categoryIdController.clear();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      elevation: 2,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              height: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      if (product['image'] != null &&
                          product['image'].toString().isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LazyLoadingImage(imageUrl: product['image']),
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Prix: \$${product['prix']}',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Category ID: ${product['category_id']}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(product),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Map<String, dynamic> product) async {
    final provider = context.read<ProductProvider>();
    final index = provider.products.indexOf(product);

    try {
      bool confirm = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Product'),
              content:
                  const Text('Are you sure you want to delete this product?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('DELETE'),
                ),
              ],
            ),
          ) ??
          false;

      if (!confirm) return;

      await provider.deleteProduct(product['id']);
      setState(() {
        provider.products.removeAt(index);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product deleted successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete product: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PRODUCT LIST'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ProductProvider>().refreshList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        child: const Icon(Icons.add),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: provider.refreshList,
                  child: provider.products.isEmpty && !provider.isLoading
                      ? const Center(child: Text('No products found'))
                      : ListView.builder(
                          controller: _scrollController,
                          // Add cacheExtent to keep more items in memory for smoother scrolling
                          cacheExtent: 200,
                          itemCount: provider.products.length +
                              (provider.isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < provider.products.length) {
                              final product = provider.products[index];
                              return _buildProductItem(product);
                            } else {
                              return Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(),
                              );
                            }
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
