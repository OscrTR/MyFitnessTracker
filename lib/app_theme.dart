import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/core/app_colors.dart';

final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: Colors.white,
  fontFamily: 'Inter',
  popupMenuTheme: const PopupMenuThemeData(color: AppColors.lightGrey),
  textTheme: const TextTheme(
    titleMedium: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.black),
    titleLarge: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.black),
  ),
);
