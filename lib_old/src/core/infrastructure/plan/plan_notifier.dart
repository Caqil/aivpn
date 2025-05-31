// import 'package:dio/dio.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:safer_vpn/src/constants/index.dart';
// import 'package:safer_vpn/src/core/index.dart';
// import 'package:provider/provider.dart';

// class PlanNotifier with ChangeNotifier {
//   Stream<List<Plan>> getAllPlan() async* {
//     final response = await dio.post("/plans",
//         options: Options(headers: {
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $userToken'
//         }));
//     final List body = response.data['data'];
//     notifyListeners();
//     yield body.map((e) => Plan.fromJson(e)).toList();
//   }

//   static PlanNotifier read(BuildContext context) => context.read();
//   static PlanNotifier watch(BuildContext context) => context.watch();
// }
