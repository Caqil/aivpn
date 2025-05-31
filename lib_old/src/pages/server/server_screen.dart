import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';
import 'package:safer_vpn/src/constants/CustomPageRoute.dart';
import 'package:safer_vpn/src/core/admob/admob_service.dart';
import 'package:safer_vpn/src/core/index.dart';
import 'package:safer_vpn/src/core/infrastructure/server/ovpn.dart';
import 'package:safer_vpn/src/features/index.dart';
import 'package:safer_vpn/src/pages/subscription_page/subscription.dart';

class ServerScreen extends StatefulWidget {
  const ServerScreen({super.key});
  @override
  State<ServerScreen> createState() => _ServerScreenState();
}

class _ServerScreenState extends State<ServerScreen> {
  List<Servers> _allFreeList = [];
  List<Servers> _allProList = [];
  List<Servers> _filteredFreeList = [];
  List<Servers> _filteredProList = [];
  final TextEditingController _textController = TextEditingController();
  @override
  void initState() {
    super.initState();
    AdMobService.createBannerAd();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServersNotifier>(context, listen: false)
          .getFreeServer()
          .then((value) {
        setState(() {
          _allFreeList = value;
          _allFreeList.sort((a, b) => a.country!.compareTo(b.country!));
          _filteredFreeList = _allFreeList;
        });
      });
      Provider.of<ServersNotifier>(context, listen: false)
          .getProServer()
          .then((value) {
        setState(() {
          _allProList = value;
          _allProList.sort((a, b) => a.country!.compareTo(b.country!));
          _filteredProList = _allProList;
        });
      });
    });
  }

  void _filterServerListBySearchText(String searchText) {
    setState(() {
      _filteredFreeList = _allFreeList
          .where((logObj) =>
              logObj.country!.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
      _filteredProList = _allProList
          .where((logObj) =>
              logObj.country!.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }

  Future<void> _refresh() async {
    AuthNotifier userNotifier = Provider.of(context, listen: false);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      userNotifier.getProfiles(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    AuthNotifier userNotifier = Provider.of(context, listen: false);
    ServersNotifier serversNotifier = Provider.of(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          title: Platform.isMacOS
              ? const Text('360 AI VPN')
              : const Text('Server Lists'),
        ),
        body: RefreshIndicator(
            onRefresh: () {
              Platform.isMacOS ? _refresh() : null;
              return Future.delayed(Duration.zero);
            },
            child: SafeArea(
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: CupertinoSearchTextField(
                      style: const TextStyle(color: Colors.white),
                      controller: _textController,
                      onChanged: (value) =>
                          _filterServerListBySearchText(value),
                    ),
                  ),
                  CupertinoListSection.insetGrouped(
                      footer: Center(child: AdMobService.showBannerAd()),
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.zero)),
                      margin: const EdgeInsets.all(0),
                      header: Text(
                        'free_location'.tr(),
                        style:
                            const TextStyle(color: CupertinoColors.systemRed),
                      ),
                      children: List.generate(
                        _filteredFreeList.length,
                        (index) => CupertinoListTile(
                          trailing: _filteredFreeList[index].id ==
                                  userNotifier.user.servers!.id
                              ? const Icon(
                                  CupertinoIcons.largecircle_fill_circle)
                              : const SizedBox.shrink(),
                          leading: Image.asset(
                              'assets/icons/flags/${_filteredFreeList[index].country!}.png'
                                  .toLowerCase()),
                          title: Text(
                            _filteredFreeList[index].country!,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(_filteredFreeList[index].state!),
                          onTap: () async {
                            await CustomProgressDialog.future(
                              context,
                              future: serversNotifier.updateServer(
                                  context, _filteredFreeList[index].id!),
                              dismissable: false,
                              onProgressFinish: (data) {
                                OVPN
                                    .startVpn(
                                  _filteredFreeList[index].ovpnConfig!,
                                  _filteredFreeList[index].country!,
                                )
                                    .then((value) {
                                  Platform.isMacOS
                                      ? _refresh()
                                      : Navigator.pop(context, true);
                                });
                                setState(() {
                                  userNotifier.getProfiles(context);
                                });
                              },
                              loadingWidget: Center(
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Center(
                                    child: CupertinoActivityIndicator(),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )),
                  CupertinoListSection.insetGrouped(
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.zero)),
                      margin: const EdgeInsets.all(0),
                      header: Text(
                        'premium_location'.tr(),
                        style:
                            const TextStyle(color: CupertinoColors.activeGreen),
                      ),
                      children: List.generate(
                        _filteredProList.length,
                        (index) => CupertinoListTile(
                          trailing: Row(
                            children: [
                              !userNotifier.user.subscription!.expiryAt!
                                      .isBefore(DateTime.now())
                                  ? const SizedBox.shrink()
                                  : const Icon(
                                      CupertinoIcons.suit_diamond,
                                      color: CupertinoColors.systemYellow,
                                    ),
                              _filteredProList[index].id ==
                                      userNotifier.user.servers!.id
                                  ? const Icon(
                                      CupertinoIcons.largecircle_fill_circle)
                                  : const SizedBox.shrink(),
                            ],
                          ),
                          leading: Image.asset(
                              'assets/icons/flags/${_filteredProList[index].country!}.png'
                                  .toLowerCase()),
                          title: Text(
                            _filteredProList[index].country!,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(_filteredProList[index].state!),
                          onTap: () async {
                            if (userNotifier.user.subscription!.expiryAt!
                                .isBefore(DateTime.now())) {
                              Navigator.of(context).push(
                                CustomPageRoute(const SubscriptionScreen()),
                              );
                            } else {
                              await CustomProgressDialog.future(
                                context,
                                future: serversNotifier.updateServer(
                                    context, _filteredProList[index].id!),
                                dismissable: false,
                                onProgressFinish: (data) {
                                  OVPN
                                      .startVpn(
                                    _filteredProList[index].ovpnConfig!,
                                    _filteredProList[index].country!,
                                  )
                                      .then((value) {
                                    Platform.isMacOS
                                        ? _refresh()
                                        : Navigator.pop(context, true);
                                  });

                                  setState(() {
                                    userNotifier.getProfiles(context);
                                  });
                                },
                                loadingWidget: Center(
                                  child: Container(
                                    height: 100,
                                    width: 100,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Center(
                                      child: CupertinoActivityIndicator(),
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ))
                ],
              )),
            )));
  }
}
