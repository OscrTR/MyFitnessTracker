import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app_colors.dart'; // Assurez-vous d'importer les icônes Lucide si nécessaire

class SaveButton extends StatefulWidget {
  final VoidCallback onTapCallback;
  const SaveButton({super.key, required this.onTapCallback});

  @override
  SaveButtonState createState() => SaveButtonState();
}

class SaveButtonState extends State<SaveButton> {
  bool _isPressed = false;

  void _onTap() {
    setState(() {
      FocusScope.of(context).unfocus();
      _isPressed = true;
    });

    widget.onTapCallback();

    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _isPressed = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _isPressed ? AppColors.licorice : AppColors.platinum,
        ),
        child: Center(
          child: Icon(
            LucideIcons.save,
            size: 20,
            color: _isPressed ? AppColors.white : AppColors.frenchGray,
          ),
        ),
      ),
    );
  }
}
