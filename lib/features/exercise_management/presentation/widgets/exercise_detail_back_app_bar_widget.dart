import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';

class BackAppBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const BackAppBar({required this.title, required this.onBack, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onBack,
              child: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.black,
              ),
            ),
          ),
          Center(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}
