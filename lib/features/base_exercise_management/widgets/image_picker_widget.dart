import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../app_colors.dart';

class ImagePickerWidget extends StatelessWidget {
  final File? image;
  final VoidCallback onAddImage;
  final VoidCallback onDeleteImage;
  final VoidCallback onChangeImage;

  const ImagePickerWidget({
    this.image,
    required this.onAddImage,
    required this.onDeleteImage,
    required this.onChangeImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (image != null)
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(
                    image!,
                    width: MediaQuery.of(context).size.width - 40,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: PopupMenuButton(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: AppColors.timberwolf)),
                  color: AppColors.white,
                  onSelected: (value) {
                    if (value == 'change') {
                      onChangeImage();
                    } else if (value == 'delete') {
                      onDeleteImage();
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: 'change',
                      child: Text(
                        tr('exercise_detail_page_change'),
                        style: const TextStyle(color: AppColors.taupeGray),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        tr('global_delete'),
                        style: const TextStyle(color: AppColors.taupeGray),
                      ),
                    ),
                  ],
                  icon: const Icon(
                    Icons.more_horiz,
                    color: AppColors.frenchGray,
                  ),
                ),
              )
            ],
          )
      ],
    );
  }
}
