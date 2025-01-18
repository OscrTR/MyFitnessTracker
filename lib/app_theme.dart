import 'package:flutter/material.dart';

import 'app_colors.dart';

final ThemeData appTheme = ThemeData(
  fontFamily: 'Inter',
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.white,
    primary: AppColors.licorice,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.licorice,
    secondary: AppColors.lightGrey,
    onSecondary: AppColors.licorice,
    secondaryContainer: AppColors.lightGrey,
    onSecondaryContainer: AppColors.licorice,
    tertiary: AppColors.lightGrey,
    onTertiary: AppColors.licorice,
    tertiaryContainer: AppColors.lightGrey,
    onTertiaryContainer: AppColors.licorice,
    surface: AppColors.lightGrey,
    onSurface: AppColors.licorice,
  ),
  unselectedWidgetColor: AppColors.lightBlack,
  scaffoldBackgroundColor: Colors.white,
  popupMenuTheme: const PopupMenuThemeData(color: AppColors.lightGrey),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: AppColors.lightBlack, width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(backgroundColor: AppColors.licorice)),
  textTheme: const TextTheme(
    // H1
    displayLarge: TextStyle(
        fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.licorice),
    // H2
    titleLarge: TextStyle(
        fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.licorice),
    // H3
    titleMedium: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.licorice),
    // Regular text
    bodyMedium: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.licorice),
    // Small text
    bodySmall: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.licorice),
    // Extra small text
    labelMedium: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.licorice),
  ),
  checkboxTheme: const CheckboxThemeData(
      side: BorderSide(color: AppColors.lightBlack, width: 2)),
);
