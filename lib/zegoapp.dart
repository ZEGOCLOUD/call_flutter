import 'dart:math';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:wakelock/wakelock.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';

import 'package:zego_call_flutter/page/auth/auth_gate.dart';
import 'package:zego_call_flutter/page/calling/calling_page.dart';
import 'package:zego_call_flutter/page/settings/settings_page.dart';
import 'package:zego_call_flutter/page/mini_overlay/mini_overlay_page.dart';
import 'package:zego_call_flutter/page/users/online_list_page.dart';
import 'package:zego_call_flutter/page/welcome/welcome_page.dart';
import 'package:zego_call_flutter/service/zego_call_service.dart';
import 'package:zego_call_flutter/service/zego_room_manager.dart';
import 'package:zego_call_flutter/service/zego_user_service.dart';
import 'package:zego_call_flutter/service/zego_loading_service.dart';
import 'package:zego_call_flutter/common/style/styles.dart';
import 'package:zego_call_flutter/constants/zego_page_constant.dart';
import 'package:zego_call_flutter/page/room/room_main_page.dart';

class ZegoApp extends StatefulWidget {
  const ZegoApp({Key? key}) : super(key: key);

  @override
  _ZegoAppState createState() => _ZegoAppState();
}

class _ZegoAppState extends State<ZegoApp> {
  Size overlaySize = const Size(0, 0);
  Offset overlayTopLeftPos = const Offset(0, 0);
  bool overlayVisibility = true;

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
                builder: () => MaterialApp(
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
                      : PageRouteNames.auth,
                  routes: {
                    PageRouteNames.auth: (context) => const AuthGate(),
                    PageRouteNames.welcome: (context) => const WelcomePage(),
                    PageRouteNames.settings: (context) => const SettingsPage(),
                    PageRouteNames.calling: (context) => const CallingPage(),
                    PageRouteNames.onlineList: (context) =>
                        const OnlineListPage(),
                    PageRouteNames.roomMain: (context) => roomMainLoadingPage(),
                  },
                  builder: (context, child) {
                    return Stack(
                      children: [
                        child!,
                        overlayPage(),
                      ],
                    );
                  },
                ),
              )),
        ));
  }

  providers() {
    return [
      ChangeNotifierProvider(
          create: (context) => ZegoRoomManager.shared.roomService),
      ChangeNotifierProvider(
          create: (context) => ZegoRoomManager.shared.userService),
      ChangeNotifierProvider(
          create: (context) => ZegoRoomManager.shared.loadingService),
      ChangeNotifierProvider(
          create: (context) => ZegoRoomManager.shared.callService),
      ChangeNotifierProxyProvider<ZegoUserService, ZegoCallService>(
        create: (context) => context.read<ZegoCallService>(),
        update: (_, userService, callService) {
          if (callService == null) throw ArgumentError.notNull('call');
          callService.updateUserDic(userService.userDic);
          return callService;
        },
      ),
    ];
  }

  Widget overlayPage() {
    return Visibility(
        visible: overlayVisibility,
        child: Positioned(
          left: overlayTopLeftPos.dx,
          top: overlayTopLeftPos.dy,
          child: GestureDetector(
            onPanUpdate: (d) => setState(
                () => overlayTopLeftPos += Offset(d.delta.dx, d.delta.dy)),
            child: SizedBox(
              width: overlaySize.width,
              height: overlaySize.height,
              child: MiniOverlayPage(
                onPosUpdateRequest:
                    (bool visibility, Point<double> topLeft, Size size) {
                  setState(() {
                    overlayTopLeftPos = Offset(topLeft.x, topLeft.y);
                    overlaySize = size;
                  });
                },
              ),
            ),
          ),
        ));
  }

  roomMainLoadingPage() {
    return Consumer<ZegoLoadingService>(
      builder: (context, loadingService, child) => LoaderOverlay(
        child: RoomMainPage(),
        useDefaultLoading: false,
        overlayColor: Colors.grey,
        overlayOpacity: 0.8,
        overlayWidget: SizedBox(
          width: 750.w,
          height: 1334.h,
          child: Center(
            child: Column(
              children: [
                const Expanded(child: Text('')),
                const CupertinoActivityIndicator(
                  radius: 14,
                ),
                SizedBox(height: 5.h),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                    color: Colors.grey,
                  ),
                  child: Text(loadingService.loadingText(),
                      style: StyleConstant.loadingText),
                ),
                const Expanded(child: Text(''))
              ],
            ),
          ),
        ),
      ),
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

      // TODO(oliveryang@zego.im) it crash if not get the permission
      await FlutterBackground.initialize(androidConfig: androidConfig)
          .then((value) {
        FlutterBackground.enableBackgroundExecution();
      });
    });
  }
}
