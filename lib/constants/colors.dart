import 'package:flutter/material.dart';

class AppColors {
  // ==================== 라이트 모드 — 메인 12색 ====================
  static const Color primary        = Color(0xFF3B82F6); // Vivid Blue
  static const Color primaryDark    = Color(0xFF1D4ED8); // Deep Blue
  static const Color secondary      = Color(0xFF10B981); // Soft Emerald
  static const Color accent         = Color(0xFFF59E0B); // Warm Amber
  static const Color error          = Color(0xFFEF4444); // Coral Red

  static const Color background     = Color(0xFFF8FAFC); // Off White
  static const Color surface        = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceAlt     = Color(0xFFF1F5F9); // Light Gray

  static const Color textPrimary    = Color(0xFF1E293B); // Charcoal
  static const Color textSecondary  = Color(0xFF64748B); // Cool Gray
  static const Color textDisabled   = Color(0xFFCBD5E1); // Pale Gray
  static const Color border         = Color(0xFFE2E8F0); // Soft Border

  // ==================== 다크 모드 — 메인 12색 ====================
  static const Color darkPrimary        = Color(0xFF60A5FA); // Light Blue
  static const Color darkPrimaryDark    = Color(0xFF3B82F6); // Normal Blue
  static const Color darkSecondary      = Color(0xFF34D399); // Light Emerald
  static const Color darkAccent         = Color(0xFFFBBF24); // Light Amber
  static const Color darkError          = Color(0xFFF87171); // Light Red

  static const Color darkBackground     = Color(0xFF0F172A); // Deep Navy
  static const Color darkSurface        = Color(0xFF1E293B); // Dark Slate
  static const Color darkSurfaceAlt     = Color(0xFF334155); // Slate Gray

  static const Color darkTextPrimary    = Color(0xFFF1F5F9); // Off White
  static const Color darkTextSecondary  = Color(0xFF94A3B8); // Cool Gray
  static const Color darkTextDisabled   = Color(0xFF475569); // Dark Gray
  static const Color darkBorder         = Color(0xFF334155); // Dark Border

  // ==================== 카테고리별 8색 ====================
  static const Color catGreetings  = Color(0xFF6366F1); // 인사/소개  — Indigo
  static const Color catShopping   = Color(0xFFEC4899); // 쇼핑       — Pink
  static const Color catRestaurant = Color(0xFFF97316); // 식당       — Orange
  static const Color catTravel     = Color(0xFF06B6D4); // 여행       — Cyan
  static const Color catWorkplace  = Color(0xFF8B5CF6); // 직장       — Purple
  static const Color catEmergency  = Color(0xFFEF4444); // 긴급상황   — Red
  static const Color catDaily      = Color(0xFF10B981); // 일상대화   — Emerald
  static const Color catEmotion    = Color(0xFFF59E0B); // 감정표현   — Amber

  static const Map<String, Color> categoryColors = {
    'greetings' : catGreetings,
    'shopping'  : catShopping,
    'restaurant': catRestaurant,
    'travel'    : catTravel,
    'workplace' : catWorkplace,
    'emergency' : catEmergency,
    'daily'     : catDaily,
    'emotion'   : catEmotion,
  };

  // ==================== 컨텍스트 기반 색상 헬퍼 ====================
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color bg(BuildContext context) =>
      _isDark(context) ? darkBackground : background;

  static Color surfaceColor(BuildContext context) =>
      _isDark(context) ? darkSurface : surface;

  static Color surfaceAltColor(BuildContext context) =>
      _isDark(context) ? darkSurfaceAlt : surfaceAlt;

  static Color textPrimaryColor(BuildContext context) =>
      _isDark(context) ? darkTextPrimary : textPrimary;

  static Color textSecondaryColor(BuildContext context) =>
      _isDark(context) ? darkTextSecondary : textSecondary;

  static Color textDisabledColor(BuildContext context) =>
      _isDark(context) ? darkTextDisabled : textDisabled;

  static Color borderColor(BuildContext context) =>
      _isDark(context) ? darkBorder : border;

  static Color primaryColor(BuildContext context) =>
      _isDark(context) ? darkPrimary : primary;

  static Color secondaryColor(BuildContext context) =>
      _isDark(context) ? darkSecondary : secondary;

  static Color accentColor(BuildContext context) =>
      _isDark(context) ? darkAccent : accent;

  static Color errorColor(BuildContext context) =>
      _isDark(context) ? darkError : error;
}
