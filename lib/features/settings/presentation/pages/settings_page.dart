import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../app_colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _appVersion = '';
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

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
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
            _buildVersionSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('settings_page_language'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 20),
        CustomDropdown<String>(
          items: _languages,
          initialItem: _languages[0], //TODO: set correct language here
          decoration: CustomDropdownDecoration(
            listItemStyle: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: AppColors.lightBlack),
            headerStyle: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: AppColors.lightBlack),
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
      ],
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

  Widget _buildVersionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('settings_page_version'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Text(
          'Version : $_appVersion',
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: AppColors.lightBlack),
        ),
      ],
    );
  }
}
