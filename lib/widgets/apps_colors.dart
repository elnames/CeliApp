import 'package:flutter/material.dart';

class AppColors {
  static const bool isDarkMode =
      true; // Cambia esto a false para usar el tema claro

  // Colores para el tema oscuro
  static const Color darkPrimary100 = Color(0xFF1F3A5F);
  static const Color darkPrimary200 = Color(0xFF4D648D);
  static const Color darkPrimary300 = Color(0xFFACC2EF);
  static const Color darkAccent100 = Color(0xFF3D5A80);
  static const Color darkAccent200 = Color(0xFFCEE8FF);
  static const Color darkText100 = Color(0xFFFFFFFF);
  static const Color darkText200 = Color(0xFFE0E0E0);
  static const Color darkBg100 = Color(0xFF0F1C2E);
  static const Color darkBg200 = Color(0xFF1F2B3E);
  static const Color darkBg300 = Color(0xFF374357);

  // Colores para el tema claro (invertidos del tema oscuro)
  static const Color lightPrimary100 = Color(0xFFE0C5A0);
  static const Color lightPrimary200 = Color(0xFFB29B72);
  static const Color lightPrimary300 = Color(0xFF533D10);
  static const Color lightAccent100 = Color(0xFFC2A57F);
  static const Color lightAccent200 = Color(0xFF311700);
  static const Color lightText100 = Color(0xFF000000);
  static const Color lightText200 = Color(0xFF1F1F1F);
  static const Color lightBg100 = Color(0xFFF0E3D1);
  static const Color lightBg200 = Color(0xFFE0D4C1);
  static const Color lightBg300 = Color(0xFFC8BCA8);

  // Getters para obtener los colores según el modo
  static Color get primary100 => isDarkMode ? darkPrimary100 : lightPrimary100;
  static Color get primary200 => isDarkMode ? darkPrimary200 : lightPrimary200;
  static Color get primary300 => isDarkMode ? darkPrimary300 : lightPrimary300;
  static Color get accent100 => isDarkMode ? darkAccent100 : lightAccent100;
  static Color get accent200 => isDarkMode ? darkAccent200 : lightAccent200;
  static Color get text100 => isDarkMode ? darkText100 : lightText100;
  static Color get text200 => isDarkMode ? darkText200 : lightText200;
  static Color get bg100 => isDarkMode ? darkBg100 : lightBg100;
  static Color get bg200 => isDarkMode ? darkBg200 : lightBg200;
  static Color get bg300 => isDarkMode ? darkBg300 : lightBg300;
}
