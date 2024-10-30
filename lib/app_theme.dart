import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/core/app_colors.dart';

final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: Colors.white,
  fontFamily: 'Inter',
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.white,
    primary: AppColors.black,
    onPrimary: AppColors.white,
    secondary: AppColors.lightGrey,
  ),
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
    displayLarge: TextStyle(
        fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.black),
    titleMedium: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.black),
    titleLarge: TextStyle(
        fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.black),
    bodyMedium: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.black),
  ),
);
