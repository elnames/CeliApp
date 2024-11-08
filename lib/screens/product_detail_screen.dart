import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../widgets/main_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/favorites_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final dynamic product;

  ProductDetailScreen({required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  List<dynamic> _relatedProducts = [];
  bool _isLoading = false;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  bool _isFavorite = false;
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return MainScaffold(
      currentIndex: -1,
      showAppBar: false,
      onAuthenticationRequired: () {},
      body: Scaffold(
        backgroundColor: isDark ? AppColors.darkBg100 : AppColors.lightBg100,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkBg200 : AppColors.lightBg200,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? AppColors.darkText100 : AppColors.lightText100,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Detalles del Producto',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.black,
              ),
              onPressed: _toggleFavorite,
            ),
            IconButton(
              icon: Icon(Icons.share_outlined, color: Colors.black),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: AppStyles.cardDecoration(context),
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() => _currentImageIndex = index);
                            },
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: EdgeInsets.all(20),
                                child: Image.network(
                                  'https://storage.googleapis.com/celiapp-bucket/${widget.product['id_producto']}.jpg',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.image_not_supported, size: 100);
                                  },
                                ),
                              );
                            },
                          ),
                          Positioned(
                            bottom: 20,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) {
                                return Container(
                                  width: 8,
                                  height: 8,
                                  margin: EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentImageIndex == index
                                        ? Colors.blue
                                        : Colors.grey.withOpacity(0.5),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: Offset(0, -20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: widget.product['prod_celiaco'] == true
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.product['prod_celiaco'] == true
                                    ? 'Apto Celíaco'
                                    : 'No Apto Celíaco',
                                style: TextStyle(
                                  color: widget.product['prod_celiaco'] == true
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              widget.product['nombre'],
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.product['categoria'] ?? '',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Row(
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      index < 4 ? Icons.star : Icons.star_border,
                                      color: Colors.amber,
                                      size: 20,
                                    );
                                  }),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '4.5',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Productos Similares',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Text('Ver Todos'),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            _buildRelatedProductsSection(),
                          ],
                        ),
                      ),
                      SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelatedProductsSection() {
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _relatedProducts.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(
                    product: _relatedProducts[index],
                  ),
                ),
              );
            },
            child: Container(
              width: 100,
              margin: EdgeInsets.only(right: 15),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Image.network(
                              'https://storage.googleapis.com/celiapp-bucket/${_relatedProducts[index]['id_producto']}.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 5,
                            top: 5,
                            child: Icon(Icons.favorite_border, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _fetchRelatedProducts(),
        if (user != null) _checkFavoriteStatus(),
      ]);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchRelatedProducts() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/productos'));

      if (response.statusCode == 200) {
        List<dynamic> allProducts = json.decode(response.body);
        setState(() {
          _relatedProducts = allProducts
              .where((product) =>
                  product['categoria'] == widget.product['categoria'] &&
                  product['id_producto'] != widget.product['id_producto'])
              .toList();
        });
      } else {
        throw Exception('Error al cargar productos relacionados: ${response.reasonPhrase}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar productos relacionados: $e')),
      );
    }
  }

  Future<void> _checkFavoriteStatus() async {
    if (user != null) {
      final isFav = await FavoritesService.isFavorite(
        user!.uid,
        widget.product['id_producto'].toString(),
      );
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debes iniciar sesión para guardar favoritos')),
      );
      return;
    }

    try {
      setState(() {
        // Optimistic update
        _isFavorite = !_isFavorite;
      });

      bool success;
      if (_isFavorite) {
        success = await FavoritesService.addToFavorites(
          user!.uid,
          widget.product['id_producto'].toString(),
        );
      } else {
        success = await FavoritesService.removeFromFavorites(
          user!.uid,
          widget.product['id_producto'].toString(),
        );
      }

      if (!success) {
        // Revert if failed
        setState(() {
          _isFavorite = !_isFavorite;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar favoritos')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isFavorite 
                ? 'Agregado a favoritos' 
                : 'Eliminado de favoritos'),
          ),
        );
      }
    } catch (e) {
      // Revert on error
      setState(() {
        _isFavorite = !_isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar favoritos: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }
}
