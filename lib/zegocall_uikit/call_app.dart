// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:wakelock/wakelock.dart';

// Project imports:
import 'core/manager/zego_call_manager.dart';
import 'pages/mini_overlay/zego_mini_overlay_page.dart';
import 'utils/zego_navigation_service.dart';

class CallAppConfig {
  CallAppConfig(
      {required this.designSize,
      required this.appTitle,
      required this.supportedLocales,
      required this.routes,
      required this.initialRoute,
      this.providers = const []});

  Size designSize;
  String appTitle;
  List<Locale> supportedLocales;

  Map<String, WidgetBuilder> routes;
  String initialRoute;

  List<SingleChildWidget> providers = [];
}

class CallApp extends StatefulWidget {
  const CallApp({required this.config, Key? key}) : super(key: key);

  final CallAppConfig config;

  @override
  CallAppState createState() => CallAppState();
}

class CallAppState extends State<CallApp> with WidgetsBindingObserver {
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

    var mediaQuery = MediaQuery(
        data: MediaQueryData.fromWindow(WidgetsBinding.instance!.window),
        child: ScreenUtilInit(
          designSize: widget.config.designSize,
          minTextAdapt: true,
          builder: () => materialApp(),
        ));
    return widget.config.providers.isEmpty
        ? mediaQuery
        : MultiProvider(
            providers: widget.config.providers,
            child: mediaQuery,
          );
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

      ZegoCallManager.interface.uninit();
    }
  }

  MaterialApp materialApp() {
    return MaterialApp(
      title: widget.config.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: widget.config.supportedLocales,
      routes: widget.config.routes,
      initialRoute: widget.config.initialRoute,
      navigatorKey: locator<ZegoNavigationService>().navigatorKey,
      builder: EasyLoading.init(builder: (context, child) {
        return Stack(
          children: [child!, const ZegoMiniOverlayPage()],
        );
      }),
    );
  }

  Future<void> supportAndroidRunBackground() async {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) async {
      var androidConfig = FlutterBackgroundAndroidConfig(
        notificationTitle: packageInfo.appName,
        notificationText: "keep alive",
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
