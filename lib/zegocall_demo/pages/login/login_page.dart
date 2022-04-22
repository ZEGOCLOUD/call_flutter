// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import '../../../logger.dart';
import '../../../zegocall_uikit/core/manager/zego_call_manager.dart';
import '../../constants/page_constant.dart';
import '../../core/login_manager.dart';
import '../../styles.dart';
import '../../widgets/toast_manager.dart';
import 'login_protocol_item.dart';

class LoginPage extends StatefulWidget {
  // ignore: public_member_api_docs
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String verificationId = '';

  bool isLoading = false;
  bool isPolicyCheck = false;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance?.addPostFrameCallback((_) {
      checkPermission();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: GestureDetector(
          onTap: FocusScope.of(context).unfocus,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SafeArea(
                  child: Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 159.h / 2),
                          header(),
                          const Expanded(child: SizedBox()),
                          body(),
                          SizedBox(height: 48.h),
                          LoginProtocolItem(updatePolicyCheckState),
                          SizedBox(height: 76.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  Widget header() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image(image: const AssetImage(StyleIconUrls.authLogo), height: 61.h),
        SizedBox(height: 58.h / 2),
        Text(
          AppLocalizations.of(context)!.appName,
          style: const TextStyle(fontSize: 24, color: Colors.black),
        )
      ],
    );
  }

  Widget body() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Column(children: loginWidgets()),
      ),
    );
  }

  List<Widget> loginWidgets() {
    List<Widget> widgets = [];

    var buttonDecoration = const BoxDecoration(
      color: Color(0xffF3F4F7),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    );
    var googleLoginWidget = Container(
        width: 602.w,
        height: 80.h,
        decoration: buttonDecoration,
        child: TextButton(
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Image(
                image: const AssetImage(StyleIconUrls.authIconGoogle),
                height: 45.h),
            Text(AppLocalizations.of(context)!.loginPageGoogleLogin)
          ]),
          onPressed: isLoading ? null : onLogInGooglePressed,
        ));

    widgets.add(googleLoginWidget);

    return widgets;
  }

  void updatePolicyCheckState(bool value) {
    setState(() {
      isPolicyCheck = value;
    });
  }

  void checkPermission() async {
    await Permission.camera.request();
    await Permission.microphone.request();
  }

  void onLogInGooglePressed() {
    logInfo('login google');

    if (isPolicyCheck) {
      logInWithGoogle();
    } else {
      ToastManager.shared
          .showToast(AppLocalizations.of(context)!.toastLoginServicePrivacy);
    }
  }

  Future<void> logInWithGoogle() async {
    setState(() {
      isLoading = true;
    });
    ToastManager.shared
        .showLoading(message: AppLocalizations.of(context)!.loginPageLogin);

    try {
      // Trigger the authentication flow
      final googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final googleAuth = await googleUser?.authentication;

      if (googleAuth != null) {
        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken ?? "",
        );
        await LoginManager.shared.login(credential);
      }
    } on FirebaseAuthException catch (e) {
      logInfo('login failed, code:${e.code}, message:${e.message}');
      ToastManager.shared.showToast(
          AppLocalizations.of(context)!.toastLoginFail(int.parse(e.code)));
    } finally {
      setState(() {
        isLoading = false;
      });
      ToastManager.shared.hide();

      var user = FirebaseAuth.instance.currentUser!;
      ZegoCallManager.interface.setLocalUser(user.uid, user.displayName ?? "");

      Navigator.pushReplacementNamed(context, PageRouteNames.welcome);
    }
  }
}
