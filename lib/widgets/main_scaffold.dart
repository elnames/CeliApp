import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../widgets/favorites_tooltip.dart';
import '../constants/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainScaffold extends StatefulWidget {
  final Widget body;
  final bool showAppBar;
  final String? title;
  final List<Widget>? actions;
  final bool showFloatingButton;
  final int currentIndex;
  final Function() onAuthenticationRequired;

  MainScaffold({
    required this.body,
    this.showAppBar = true,
    this.title,
    this.actions,
    this.showFloatingButton = false,
    required this.currentIndex,
    required this.onAuthenticationRequired,
  });

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final LayerLink _favoritesLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        backgroundColor: isDark ? AppColors.darkBg200 : AppColors.lightBg200,
        elevation: 0,
        leading: Navigator.canPop(context) ? IconButton(
          icon: Icon(
            Icons.arrow_back, 
            color: isDark ? AppColors.darkText100 : AppColors.lightText100
          ),
          onPressed: () => Navigator.pop(context),
        ) : null,
        title: widget.title != null ? Text(
          widget.title!,
          style: TextStyle(
            color: isDark ? AppColors.darkText100 : AppColors.lightText100,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ) : null,
        actions: widget.actions,
      ) : null,
      body: widget.body,
      floatingActionButton: widget.showFloatingButton ? Container(
        height: 65,
        width: 65,
        child: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Función de escaneo próximamente',
                  style: TextStyle(
                    color: isDark ? AppColors.darkText100 : AppColors.lightText100,
                  ),
                ),
                backgroundColor: isDark ? AppColors.darkBg200 : AppColors.lightBg200,
              ),
            );
          },
          child: Icon(Icons.qr_code_scanner, color: Colors.white, size: 30),
        ),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: widget.currentIndex.clamp(0, 4),
            backgroundColor: isDark ? AppColors.darkBg200 : Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: isDark ? AppColors.darkText200 : Colors.grey,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            showUnselectedLabels: true,
            elevation: 8,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined),
                label: 'Buscar',
              ),
              BottomNavigationBarItem(
                icon: SizedBox(height: 32),
                label: 'Escanear',
              ),
              BottomNavigationBarItem(
                icon: CompositedTransformTarget(
                  link: _favoritesLink,
                  child: Icon(Icons.favorite_border_outlined),
                ),
                activeIcon: CompositedTransformTarget(
                  link: _favoritesLink,
                  child: Icon(Icons.favorite),
                ),
                label: 'Favoritos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Perfil',
              ),
            ],
            onTap: (index) {
              switch (index) {
                case 0:
                  if (widget.currentIndex != 0) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                  break;
                case 1:
                  if (widget.currentIndex != 1) {
                    Navigator.pushReplacementNamed(context, '/search');
                  }
                  break;
                case 2:
                  // La funcionalidad del escáner se maneja en el botón flotante
                  break;
                case 3:
                  _toggleFavoritesTooltip();
                  break;
                case 4:
                  _handleProfileTap(context);
                  break;
              }
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 25,
            child: GestureDetector(
              onTap: () {
                // Funcionalidad del escáner
              },
              child: Center(
                child: Container(
                  height: 65,
                  width: 65,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFavoritesTooltip() {
    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(
        builder: (context) => GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            _overlayEntry?.remove();
            _overlayEntry = null;
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(color: Colors.transparent),
              ),
              FavoritesTooltip(
                layerLink: _favoritesLink,
                onDismiss: () {
                  _overlayEntry?.remove();
                  _overlayEntry = null;
                },
              ),
            ],
          ),
        ),
      );
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  void _handleProfileTap(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      widget.onAuthenticationRequired();
    } else {
      Navigator.pushNamed(context, '/profile');
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }
}
