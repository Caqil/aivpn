import 'package:flutter/services.dart';
import 'package:safer_vpn/src/core/infrastructure/language/lang_notifier.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LanguagesPage extends StatefulWidget {
  const LanguagesPage({super.key});

  @override
  State<LanguagesPage> createState() => _LanguagesPageState();
}

class _LanguagesPageState extends State<LanguagesPage> {
  @override
  void initState() {
    LangController.initializeLanguages(context);
    super.initState();
  }

  showLoading(BuildContext context,
      {bool? isDismissible, bool? useLogo = false}) {
    showDialog(
        context: context,
        barrierDismissible: isDismissible ?? false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        });
  }

  void hideLoadingDialog(BuildContext context, {dynamic result}) {
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          "languages".tr(),
          style: const TextStyle(),
        ),
      ),
      body: Consumer<LangController>(
          builder: (context, value, child) => ListView.builder(
                itemCount: value.languages!.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListActionTile(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      showLoading(context);
                      Future.delayed(const Duration(seconds: 2), () async {
                        LangController.instance(context).setLanguage(
                            context,
                            Locale(value.languages![index].languageCode!,
                                value.languages![index].countryCode));
                        hideLoadingDialog(context);
                        Navigator.pop(context);
                      });
                    },
                    title: value.languages![index].label.toString(),
                    subtitle: context.locale ==
                            Locale(value.languages![index].languageCode!,
                                value.languages![index].countryCode)
                        ? const Icon(
                            Icons.radio_button_on,
                            size: 25.0,
                            color: Colors.blue,
                          )
                        : const Icon(
                            Icons.radio_button_off,
                            size: 25.0,
                            color: Color.fromARGB(255, 158, 158, 158),
                          ),
                    imageUrl:
                        "assets/icons/flags/${value.languages![index].countryCode!.toLowerCase()}.png",
                  );
                },
              )),
    );
  }
}

class ListActionTile extends StatelessWidget {
  final titleLengthLimit = 30;
  final String? imageUrl;
  final String title;
  final Color? titleColor;

  final Widget? subtitle;

  final bool isActive;
  final void Function() onTap;

  const ListActionTile({
    super.key,
    required this.title,
    this.titleColor,
    this.subtitle,
    this.imageUrl,
    this.isActive = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isActive ? onTap : null,
      child: Row(
        children: [
          Image.asset(
            '$imageUrl',
            height: 30,
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (subtitle != null) subtitle!
        ],
      ),
    );
  }
}
