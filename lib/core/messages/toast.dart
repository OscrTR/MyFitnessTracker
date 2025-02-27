import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app_colors.dart';
import '../../features/settings/bloc/settings_bloc.dart';
import '../../injection_container.dart';
import '../enums/enums.dart';
import 'models/log.dart';

void showToastMessage({
  required String message,
  bool isSuccess = true,
  bool isLog = false,
  LogLevel? logLevel,
  String? logFunction,
}) async {
  BotToast.showCustomText(
    align: const Alignment(0, 0.75),
    toastBuilder: (cancelFunc) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: isSuccess ? AppColors.licorice : AppColors.folly,
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 15, top: 10, bottom: 10, right: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSuccess ? LucideIcons.check : LucideIcons.x,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                message,
                style: TextStyle(color: AppColors.white),
              ),
            ],
          ),
        ),
      );
    },
  );
  if (isLog) {
    sl<SettingsBloc>().add(CreateLog(
      log: Log(
        date: DateTime.now(),
        message: message,
        level: logLevel ?? LogLevel.unknown,
        function: logFunction,
      ),
    ));
  }
}
