// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

// Project imports:
import '../zegocall_uikit/core/manager/zego_call_manager.dart';
import '../zegocall_uikit/core/page/zego_page_route.dart';
import '../zegocall_uikit/pages/mini_overlay/zego_mini_overlay_page.dart';
import 'constants/page_constant.dart';
import 'core/user_list_manager.dart';
import '../zegocall_uikit/utils/zego_navigation_service.dart';

class CallApp extends StatefulWidget {
  const CallApp({Key? key}) : super(key: key);

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

    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => UserListManager.shared)
        ],
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

    ZegoPageRoute.shared.callingBackRouteName = PageRouteNames.onlineList;

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
      navigatorKey: locator<ZegoNavigationService>().navigatorKey,
      initialRoute: FirebaseAuth.instance.currentUser != null
          ? PageRouteNames.welcome
          : PageRouteNames.login,
      routes: materialRoutes,
      builder: EasyLoading.init(builder: (context, child) {
        return Stack(
          children: [child!, const ZegoMiniOverlayPage()],
        );
      }),
    );
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
