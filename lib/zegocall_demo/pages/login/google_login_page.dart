// Dart imports:
import 'dart:async';
import 'dart:developer';

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
import '../../constants/page_constant.dart';
import '../../core/login_manager.dart';
import '../../styles.dart';
import '../../widgets/toast_manager.dart';
import 'google_login_protocol_item.dart';

class GoogleLoginPage extends StatefulWidget {
  // ignore: public_member_api_docs
  const GoogleLoginPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => GoogleLoginPageState();
}

class GoogleLoginPageState extends State<GoogleLoginPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String error = '';
  String verificationId = '';

  bool isLoading = false;
  bool isPolicyCheck = false;

  StreamSubscription<User?>? authStateChangesSubscription;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance?.addPostFrameCallback((_) {
      checkPermission();

      authStateChangesSubscription =
          FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user != null) {
          Navigator.pushReplacementNamed(context, PageRouteNames.welcome);
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    authStateChangesSubscription?.cancel();
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
                          GoogleLoginProtocolItem(updatePolicyCheckState),
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
        child: Container(
          width: 602.w,
          height: 100.h,
          decoration: const BoxDecoration(
            color: Color(0xffF3F4F7),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: TextButton(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Image(
                  image: const AssetImage(StyleIconUrls.authIconGoogle),
                  height: 45.h),
              Text(AppLocalizations.of(context)!.loginPageGoogleLogin)
            ]),
            onPressed: isLoading ? null : onLogInGooglePressed,
          ),
        ),
      ),
    );
  }

  void updatePolicyCheckState(bool value) {
    setState(() {
      isPolicyCheck = value;
    });
  }

  void onLogInGooglePressed() {
    log('onLogInGooglePressed');
    if (isPolicyCheck) {
      logInWithGoogle();
    } else {
      ToastManager.shared
          .showToast(AppLocalizations.of(context)!.toastLoginServicePrivacy);
    }
  }

  void checkPermission() async {
    await Permission.camera.request();
    await Permission.microphone.request();
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
        await LoginManager.shared.login(googleAuth.idToken ?? "");
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = '${e.message}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
      ToastManager.shared.hide();
    }
  }
}
