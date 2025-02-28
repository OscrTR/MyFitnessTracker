import 'dart:io';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app_colors.dart';
import '../../../core/messages/models/log.dart';
import '../bloc/settings_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _appVersion = '';

  final List<String> _languages = ['English', 'Français'];

  Future<void> _loadAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    setState(() {
      _appVersion = '$version (Build $buildNumber)';
    });
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    GoRouter.of(context).go('/home');
    return true;
  }

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child:
            BlocBuilder<SettingsBloc, SettingsState>(builder: (context, state) {
          if (state is SettingsLoaded) {
            final isReminderActive = state.isReminderActive;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 48,
                  child: Text(
                    context.tr('settings_page_title'),
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
                const SizedBox(height: 20),
                _buildLanguageSection(),
                const SizedBox(height: 30),
                _buildNotificationSection(isReminderActive),
                const SizedBox(height: 30),
                _buildLogsSection(state),
                const SizedBox(height: 30),
                _buildVersionSection(context),
              ],
            );
          } else {
            return const SizedBox();
          }
        }),
      ),
    );
  }

  Widget _buildNotificationSection(bool isReminderActive) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(color: AppColors.taupeGray),
            borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.licorice,
                ),
                const SizedBox(width: 10),
                Text(
                  context.tr('settings_page_notifications'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              tr('settings_page_reminder'),
              style: const TextStyle(
                color: AppColors.licorice,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 130,
                  child: Text(
                    tr('settings_page_reminder_description'),
                    style: const TextStyle(
                      color: AppColors.taupeGray,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                AdvancedSwitch(
                  initialValue: isReminderActive,
                  width: 48,
                  height: 24,
                  inactiveColor: AppColors.timberwolf,
                  activeColor: AppColors.folly,
                  onChanged: (value) {
                    context
                        .read<SettingsBloc>()
                        .add(UpdateSettings(isReminderActive: value));
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ));
  }

  Widget _buildLogsSection(SettingsLoaded state) {
    final logs = state.logs;

    Future<void> shareLogsAsFile(List<Log> logs) async {
      final logMessages = logs
          .map((log) =>
              '${DateFormat('yyyy-MM-dd HH:mm:ss').format(log.date)} [${log.level.toMap()}] ${log.function != null ? '(${log.function})' : ''} - ${log.message}')
          .join('\n');

      // Obtenir le répertoire temporaire
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/mft_logs.txt';

      // Écrire les logs dans un fichier
      final file = File(filePath);
      await file.writeAsString(logMessages);

      // Partager le fichier
      await Share.shareXFiles([XFile(filePath)],
          text: 'My Fitness Tracker Logs');

      await file.delete();
    }

    return Container(
        decoration: BoxDecoration(
            border: Border.all(color: AppColors.taupeGray),
            borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  LucideIcons.scrollText,
                  color: AppColors.licorice,
                ),
                const SizedBox(width: 10),
                Text(
                  'Logs',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 130,
                  child: Text(
                    tr('settings_page_logs'),
                    style: const TextStyle(
                      color: AppColors.taupeGray,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          insetPadding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: AppColors.white,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Logs'),
                              GestureDetector(
                                onTap: () => Navigator.pop(context, 'Close'),
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  alignment: Alignment.centerRight,
                                  child: const ClipRect(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      widthFactor: 0.85,
                                      child: Icon(
                                        Icons.close,
                                        color: AppColors.licorice,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          content: logs.isNotEmpty
                              ? SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: logs.length < 7
                                      ? logs.length * 64
                                      : MediaQuery.of(context).size.height *
                                          2 /
                                          3,
                                  child: ListView.builder(
                                    itemCount: logs.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        contentPadding:
                                            EdgeInsets.symmetric(horizontal: 0),
                                        title: Text(
                                            '${DateFormat('yyyy-MM-dd HH:mm:ss').format(logs[index].date)} [${logs[index].level.toMap()}] ${logs[index].function != null ? '(${logs[index].function})' : ''} - ${logs[index].message}'),
                                      );
                                    },
                                  ),
                                )
                              : Text(tr('settings_page_no_logs')),
                          actions: [
                            if (logs.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  shareLogsAsFile(logs);
                                  Navigator.pop(context, 'Share');
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: AppColors.licorice),
                                  child: Center(
                                    child: Text(
                                      tr('settings_page_share'),
                                      style: const TextStyle(
                                          color: AppColors.white),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),
                  child: Text(
                    tr('settings_page_see'),
                    style: const TextStyle(
                      color: AppColors.licorice,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ));
  }

  Widget _buildLanguageSection() {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.taupeGray),
          borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.translate,
                color: AppColors.licorice,
              ),
              const SizedBox(width: 10),
              Text(
                context.tr('settings_page_language'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            tr('settings_page_language_description'),
            style: const TextStyle(
              color: AppColors.taupeGray,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          CustomDropdown<String>(
            excludeSelected: false,
            items: _languages,
            initialItem: _getLocaleName(context.locale),
            decoration: CustomDropdownDecoration(
              listItemStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: AppColors.taupeGray, fontSize: 14),
              headerStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: AppColors.taupeGray, fontSize: 14),
              closedSuffixIcon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: AppColors.frenchGray,
              ),
              expandedSuffixIcon: const Icon(
                Icons.keyboard_arrow_up_rounded,
                size: 20,
                color: AppColors.frenchGray,
              ),
              closedBorder: Border.all(color: AppColors.frenchGray),
              expandedBorder: Border.all(color: AppColors.frenchGray),
            ),
            onChanged: (value) {
              _setLocale(context, value!);
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _setLocale(BuildContext context, String name) {
    const List<Map<String, String>> languagesCodes = [
      {
        'name': 'English',
        'languageCode': 'en',
        'countryCode': 'US',
      },
      {
        'name': 'Français',
        'languageCode': 'fr',
        'countryCode': 'FR',
      }
    ];

    // Find the matching language map based on the `name`
    final language = languagesCodes.firstWhere(
      (lang) => lang['name'] == name,
      orElse: () => {
        'languageCode': 'en',
        'countryCode': 'US'
      }, // Default to English if not found
    );

    // Set the locale using the found language codes
    context
        .setLocale(Locale(language['languageCode']!, language['countryCode']!));
  }

  String _getLocaleName(Locale locale) {
    const List<Map<String, String>> languagesCodes = [
      {
        'name': 'English',
        'languageCode': 'en',
        'countryCode': 'US',
      },
      {
        'name': 'Français',
        'languageCode': 'fr',
        'countryCode': 'FR',
      }
    ];

    // Find the matching language map based on the `name`
    final language = languagesCodes.firstWhere(
      (lang) => lang['languageCode'] == locale.languageCode,
      orElse: () => {
        'languageCode': 'en',
        'countryCode': 'US'
      }, // Default to English if not found
    );

    // Set the locale using the found language codes
    return language['name']!;
  }

  Widget _buildVersionSection(BuildContext context) {
    return Center(
      child: Text(
        'Version : $_appVersion',
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: AppColors.taupeGray,
              fontSize: 14,
            ),
      ),
    );
  }
}
