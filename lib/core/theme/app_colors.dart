

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Background & Surface ──
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF12182B);
  static const Color surfaceLight = Color(0xFF1A2138);
  static const Color surfaceBright = Color(0xFF222B45);

  // ── Primary Gradient ──
  static const Color primaryPurple = Color(0xFF6C63FF);
  static const Color primaryCyan = Color(0xFF00D9FF);
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, primaryCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Accent ──
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentOrange = Color(0xFFFF9F43);

  // ── Semantic ──
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF60A5FA);

  // ── Text ──
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color textInverse = Color(0xFF0F172A);

  // ── Glass ──
  static Color glassBackground = Colors.white.withValues(alpha: 0.08);
  static Color glassBorder = Colors.white.withValues(alpha: 0.12);
  static Color glassHighlight = Colors.white.withValues(alpha: 0.18);

  // ── Category Colors ──
  static const Color categoryFood = Color(0xFFFF6B6B);
  static const Color categoryTransport = Color(0xFF60A5FA);
  static const Color categoryStay = Color(0xFFFBBF24);
  static const Color categoryActivity = Color(0xFF4ADE80);
  static const Color categoryShopping = Color(0xFFF472B6);
  static const Color categoryOther = Color(0xFF94A3B8);

  // ── Expense Category Colors ──
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return categoryFood;
      case 'transport':
        return categoryTransport;
      case 'stay':
        return categoryStay;
      case 'activity':
        return categoryActivity;
      case 'shopping':
        return categoryShopping;
      default:
        return categoryOther;
    }
  }

  // ── Itinerary Category Icons ──
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'stay':
        return Icons.hotel_rounded;
      case 'activity':
        return Icons.hiking_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      default:
        return Icons.more_horiz_rounded;
    }
  }
}
