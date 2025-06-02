import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';
import '../../../domain/entities/user.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final List<Language> _languages = [
    Language(
      label: 'English',
      languageCode: 'en',
      countryCode: 'US',
      flagAsset: 'assets/icons/flags/us.png',
    ),
    Language(
      label: 'Español',
      languageCode: 'es',
      countryCode: 'ES',
      flagAsset: 'assets/icons/flags/es.png',
    ),
    Language(
      label: 'Français',
      languageCode: 'fr',
      countryCode: 'FR',
      flagAsset: 'assets/icons/flags/fr.png',
    ),
    Language(
      label: 'Deutsch',
      languageCode: 'de',
      countryCode: 'DE',
      flagAsset: 'assets/icons/flags/de.png',
    ),
    Language(
      label: '中文',
      languageCode: 'zh',
      countryCode: 'CN',
      flagAsset: 'assets/icons/flags/cn.png',
    ),
    Language(
      label: 'Bahasa Indonesia',
      languageCode: 'id',
      countryCode: 'ID',
      flagAsset: 'assets/icons/flags/id.png',
    ),
    Language(
      label: 'Tiếng Việt',
      languageCode: 'vi',
      countryCode: 'VN',
      flagAsset: 'assets/icons/flags/vn.png',
    ),
    Language(
      label: 'हिन्दी',
      languageCode: 'hi',
      countryCode: 'IN',
      flagAsset: 'assets/icons/flags/in.png',
    ),
    Language(
      label: 'Português',
      languageCode: 'pt',
      countryCode: 'PT',
      flagAsset: 'assets/icons/flags/pt.png',
    ),
    Language(
      label: 'Русский',
      languageCode: 'ru',
      countryCode: 'RU',
      flagAsset: 'assets/icons/flags/ru.png',
    ),
  ];

  void _showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void _hideLoadingDialog(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("Languages", style: TextStyle()),
        backgroundColor: Colors.transparent,
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is! UserLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentLanguage = state.user.preferences.languageCode;
          final currentCountry = state.user.preferences.countryCode;

          return ListView.builder(
            itemCount: _languages.length,
            itemBuilder: (BuildContext context, int index) {
              final language = _languages[index];
              final isSelected =
                  currentLanguage == language.languageCode &&
                  currentCountry == language.countryCode;

              return _buildLanguageTile(
                language,
                isSelected,
                state.user.preferences,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLanguageTile(
    Language language,
    bool isSelected,
    UserPreferences currentPreferences,
  ) {
    return ListTile(
      onTap: () {
        HapticFeedback.selectionClick();
        _selectLanguage(language, currentPreferences);
      },
      leading: Container(
        width: 40,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.asset(
            language.flagAsset,
            width: 40,
            height: 30,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: Icon(Icons.flag, color: Colors.grey[600], size: 20),
              );
            },
          ),
        ),
      ),
      title: Text(
        language.label,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      trailing: Icon(
        isSelected ? Icons.radio_button_on : Icons.radio_button_off,
        size: 25.0,
        color: isSelected
            ? Colors.blue
            : const Color.fromARGB(255, 158, 158, 158),
      ),
    );
  }

  void _selectLanguage(Language language, UserPreferences currentPreferences) {
    _showLoading(context);

    Future.delayed(const Duration(seconds: 1), () {
      final updatedPreferences = currentPreferences.copyWith(
        languageCode: language.languageCode,
        countryCode: language.countryCode,
      );

      context.read<UserBloc>().add(UpdateUserPreferences(updatedPreferences));

      _hideLoadingDialog(context);
      Navigator.pop(context);
    });
  }
}

class Language {
  final String label;
  final String languageCode;
  final String countryCode;
  final String flagAsset;

  Language({
    required this.label,
    required this.languageCode,
    required this.countryCode,
    required this.flagAsset,
  });
}
