import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../app_colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _appVersion = '';
  bool isReminderNotificationActive = false;
  final reminderNotification = ValueNotifier<bool>(false);

  final List<String> _languages = ['English', 'Français'];
  String? selectedItem;

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
    reminderNotification.addListener(() {
      setState(() {
        if (reminderNotification.value) {
          isReminderNotificationActive = true;
        } else {
          isReminderNotificationActive = false;
        }
      });
    });
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
        child: Column(
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
            _buildNotificationSection(),
            const SizedBox(height: 30),
            _buildVersionSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
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
                  controller: reminderNotification,
                  width: 48,
                  height: 24,
                  inactiveColor: AppColors.timberwolf,
                  activeColor: AppColors.folly,
                ),
              ],
            ),
            const SizedBox(height: 20),
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
                color: AppColors.lightBlack,
              ),
              expandedSuffixIcon: const Icon(
                Icons.keyboard_arrow_up_rounded,
                size: 20,
                color: AppColors.lightBlack,
              ),
              closedBorder: Border.all(color: AppColors.lightBlack),
              expandedBorder: Border.all(color: AppColors.lightBlack),
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
