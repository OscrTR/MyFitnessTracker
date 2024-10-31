import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/widgets/dash_border_painter_widget.dart';

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
        image != null
            ? Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: AppColors.lightBlack, width: 1.0),
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
                          child:
                              Text(context.tr('exercise_detail_page_change')),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(context.tr('global_delete')),
                        ),
                      ],
                      icon: const Icon(
                        Icons.more_horiz,
                        color: AppColors.lightBlack,
                      ),
                    ),
                  )
                ],
              )
            : GestureDetector(
                onTap: onAddImage,
                child: CustomPaint(
                  painter: DashedBorderPainter(
                    color: AppColors.lightBlack,
                    strokeWidth: 1.0,
                    dashLength: 5.0,
                    gapLength: 5.0,
                  ),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.width - 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              context.tr('exercise_detail_page_image_hint'),
                              style:
                                  const TextStyle(color: AppColors.lightBlack),
                            ),
                            const Icon(
                              Icons.add,
                              color: AppColors.lightBlack,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
