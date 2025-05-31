import 'package:flutter/cupertino.dart';
import 'package:safer_vpn/src/core/index.dart';

class LoadingSplashPage extends StatefulWidget {
  const LoadingSplashPage({super.key});

  @override
  State<LoadingSplashPage> createState() => _LoadingSplashPageState();
}

class _LoadingSplashPageState extends State<LoadingSplashPage> {
  double containerWidth = 200;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          containerWidth = 300;
          ServersNotifier.getStateVPN(context);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: AnimatedContainer(
            alignment: Alignment.center,
            duration: const Duration(milliseconds: 500),
            width: containerWidth,
            child: Image.asset('assets/icons/icon.png', height: 100),
          ),
        ),
      ),
    );
  }
}
