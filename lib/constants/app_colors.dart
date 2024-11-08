import 'package:flutter/material.dart';

class AppColors {
  // Colores base
  static const cream = Color(0xFFFAF6F0);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF2C3333);
  
  // Paleta principal
  static const primary = Color.fromARGB(255, 167, 160, 137);
  static const secondary = Color(0xFF7B8FA3);
  static const accent = Color(0xFFEEE3D0);
  
  // Categorías
  static const categoryBg = Color(0xFF94A7BC);
  static const categoryText = Color(0xFFFFFFFF);
  static const categorySelected = Color(0xFFB4C4D9);
  
  // Tema claro
  static const lightPrimary = primary;
  static const lightAccent = secondary;
  static const lightBg100 = cream;
  static const lightBg200 = white;
  static const lightText100 = Color(0xFF3F4E5C);
  static const lightText200 = Color(0xFF7B8FA3);

  // Tema oscuro
  static const darkPrimary = Color(0xFF94A7BC);
  static const darkAccent = Color(0xFFB4C4D9);
  static const darkBg100 = Color(0xFF2C3440);
  static const darkBg200 = Color(0xFF3F4E5C);
  static const darkText100 = Color(0xFFF5F5F5);
  static const darkText200 = Color(0xFFE8EDF2);

  // Estados
  static const success = Color(0xFF81C784);
  static const error = Color(0xFFE57373);
  static const warning = Color(0xFFFFB74D);
  static const info = Color(0xFF64B5F6);
} 