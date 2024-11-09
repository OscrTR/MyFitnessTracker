import 'package:flutter/material.dart';

import 'assets/app_colors.dart';

final ThemeData appTheme = ThemeData(
  fontFamily: 'Inter',
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.white,
    primary: AppColors.black,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.black,
    secondary: AppColors.lightGrey,
    onSecondary: AppColors.black,
    secondaryContainer: AppColors.lightGrey,
    onSecondaryContainer: AppColors.black,
    tertiary: AppColors.lightGrey,
    onTertiary: AppColors.black,
    tertiaryContainer: AppColors.lightGrey,
    onTertiaryContainer: AppColors.black,
    surface: AppColors.lightGrey,
    onSurface: AppColors.black,
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
      style: FilledButton.styleFrom(backgroundColor: AppColors.black)),
  textTheme: const TextTheme(
    // H1
    displayLarge: TextStyle(
        fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.black),
    // H2
    titleLarge: TextStyle(
        fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.black),
    // H3
    titleMedium: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.black),
    // Regular text
    bodyMedium: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.black),
    // Small text
    bodySmall: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.black),
    // Extra small text
    labelMedium: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.black),
  ),
);
