import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/favorites_service.dart';
import '../constants/app_colors.dart';

class FavoritesTooltip extends StatefulWidget {
  final LayerLink layerLink;
  final VoidCallback onDismiss;

  const FavoritesTooltip({
    Key? key,
    required this.layerLink,
    required this.onDismiss,
  }) : super(key: key);

  @override
  _FavoritesTooltipState createState() => _FavoritesTooltipState();
}

class _FavoritesTooltipState extends State<FavoritesTooltip> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    
    return CompositedTransformFollower(
      link: widget.layerLink,
      targetAnchor: Alignment.topCenter,
      followerAnchor: Alignment.bottomCenter,
      offset: Offset(-55, -14),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: size.width * 0.85,
          constraints: BoxConstraints(
            maxHeight: size.height * 0.4,
            minHeight: 150,
          ),
          margin: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBg200 : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                spreadRadius: 0,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(isDark),
                Expanded(
                  child: _buildFavoritesList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Mis Favoritos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText100 : Colors.black87,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.close_rounded),
            color: isDark ? AppColors.darkText200 : Colors.black54,
            onPressed: widget.onDismiss,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: FavoritesService.getUserFavorites(user?.uid ?? ''),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border_rounded,
                  size: 48,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 12),
                Text(
                  'No tienes favoritos aún',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final product = snapshot.data![index];
            return _buildFavoriteItem(product);
          },
        );
      },
    );
  }

  Widget _buildFavoriteItem(Map<String, dynamic> product) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          widget.onDismiss();
          Navigator.pushNamed(context, '/product_detail', arguments: product);
        },
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://storage.googleapis.com/celiapp-bucket/${product['id_producto']}.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['nombre'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      product['categoria'] ?? 'Sin categoría',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}