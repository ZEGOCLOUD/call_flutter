// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// Project imports:
import '../zegocall_uikit/call_app.dart';
import 'constants/page_constant.dart';
import 'core/user_list_manager.dart';

class CallDemoApp extends CallApp {
  CallDemoApp({Key? key})
      : super(
          config: CallAppConfig(
              designSize: const Size(750, 1334),
              appTitle: "ZegoCall",
              supportedLocales: const [
                Locale('en', ''), // English, no country code
                Locale('zh', ''),
              ],
              routes: materialRoutes,
              initialRoute: FirebaseAuth.instance.currentUser != null
                  ? PageRouteNames.welcome
                  : PageRouteNames.login,
              providers: [
                ChangeNotifierProvider(
                    create: (context) => UserListManager.shared)
              ]),
          key: key,
        );
}
