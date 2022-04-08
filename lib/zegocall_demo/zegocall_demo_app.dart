// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

// Project imports:
import 'package:zego_call_flutter/zegocall/notification/zego_notification_manager.dart';
import '../zegocall_uikit/core/zego_call_manager.dart';
import './../zegocall/core/manager/zego_service_manager.dart';
import './../zegocall_uikit/pages/mini_overlay/mini_overlay_page.dart';
import './constants/zego_page_constant.dart';
import './core/zego_user_list_manager.dart';

class ZegoApp extends StatefulWidget {
  const ZegoApp({Key? key}) : super(key: key);

  @override
  _ZegoAppState createState() => _ZegoAppState();
}

class _ZegoAppState extends State<ZegoApp> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    Wakelock.enable(); //  always bright
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
      SystemUiOverlay.top
    ]); //  hide status bar and bottom navigation bar

    if (Platform.isAndroid) {
      supportAndroidRunBackground();
    }

    return MultiProvider(
        providers: providers(),
        child: GestureDetector(
          onTap: () {
            //  for hide keyboard when click on empty place of all pages
            hideKeyboard(context);
          },
          child: MediaQuery(
              data: MediaQueryData.fromWindow(WidgetsBinding.instance!.window),
              child: ScreenUtilInit(
                designSize: const Size(750, 1334),
                minTextAdapt: true,
                builder: () => materialApp(),
              )),
        ));
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (AppLifecycleState.detached == state) {
      WidgetsBinding.instance?.removeObserver(this);

      ZegoCallManager.shared.uninit();
    }
  }

  MaterialApp materialApp() {
    return MaterialApp(
      title: "ZegoCall",
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
        Locale('zh', ''),
      ],
      initialRoute: FirebaseAuth.instance.currentUser != null
          ? PageRouteNames.welcome
          : PageRouteNames.login,
      routes: materialRoutes,
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            const MiniOverlayPage(),
          ],
        );
      },
    );
  }

  providers() {
    return [
      ChangeNotifierProvider(create: (context) => ZegoUserListManager.shared),
      ChangeNotifierProvider(
          create: (context) => ZegoServiceManager.shared.roomService),
      ChangeNotifierProvider(
          create: (context) => ZegoServiceManager.shared.userService),
      ChangeNotifierProvider(
          create: (context) => ZegoServiceManager.shared.callService),
      ChangeNotifierProvider(
          create: (context) => ZegoServiceManager.shared.streamService),
      ChangeNotifierProvider(
          create: (context) => ZegoServiceManager.shared.deviceService),
    ];
  }

  void hideKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  Future<void> supportAndroidRunBackground() async {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) async {
      var androidConfig = FlutterBackgroundAndroidConfig(
        notificationTitle: packageInfo.appName,
        notificationText: "Background notification for keeping " +
            packageInfo.appName +
            " running in the background",
        notificationImportance: AndroidNotificationImportance.Default,
        // notificationIcon: , // Default is ic_launcher from folder mipmap
      );

      await FlutterBackground.initialize(androidConfig: androidConfig)
          .then((value) {
        FlutterBackground.enableBackgroundExecution();
      });
    });
  }
}
