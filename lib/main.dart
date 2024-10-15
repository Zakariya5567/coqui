import 'dart:convert';
import 'dart:io';

import 'package:coqui/utils/colors.dart';
import 'package:coqui/view/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dropbox_client/dropbox_client.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helper/scroll_behaviour.dart';

GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
void main() {
  return runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        navigatorKey: navKey,
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: MyBehavior(),
            child: MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child!,
            ),
          );
        },
        onGenerateRoute: (settings) {
          debugPrint('setting===========${settings.name}');
          print("Name ${settings.name}");
          List<String> parts = settings.name!.split('/');
          // Get the last part of the split string
          print("Parts $parts");
          String routeName = parts[1];
          print("Routes is : $routeName");
          String uuid = parts.last;
          return MaterialPageRoute(
            builder: (context) {
              return MainScreen();
            },
          );
        },
        debugShowCheckedModeBanner: false,
        title: 'Coqui',
        theme: ThemeData(
          useMaterial3: false,
          primarySwatch: const MaterialColor(0x219942, AppColor.primaryColor),
          pageTransitionsTheme: const PageTransitionsTheme(builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          }),
        ),
        //home:  PDFListScreen());
         home: const MainScreen());
  }
}
