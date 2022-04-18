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
import '../../../utils/zego_loading_manager.dart';
import './../../../utils/styles.dart';
import './../../constants/zego_page_constant.dart';
import './../../core/zego_login_manager.dart';
import 'google_login_protocol_item.dart';

class GoogleLoginPage extends StatefulWidget {
  // ignore: public_member_api_docs
  const GoogleLoginPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GoogleLoginPageState();
}

class _GoogleLoginPageState extends State<GoogleLoginPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String error = '';
  String verificationId = '';

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
    return GestureDetector(
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
                      const SizedBox(
                        height: 159 / 2,
                      ),
                      Image(
                          image: const AssetImage(StyleIconUrls.authLogo),
                          height: 61.h),
                      const SizedBox(
                        height: 58 / 2,
                      ),
                      Text(
                        AppLocalizations.of(context)!.appName,
                        style:
                            const TextStyle(fontSize: 24, color: Colors.black),
                      ),
                      const Expanded(child: SizedBox()),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            width: 602 / 2,
                            height: 50,
                            decoration: const BoxDecoration(
                              color: Color(0xffF3F4F7),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: TextButton(
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image(
                                        image: const AssetImage(
                                            StyleIconUrls.authIconGoogle),
                                        height: 45.h),
                                    Text(AppLocalizations.of(context)!
                                        .loginPageGoogleLogin)
                                  ]),
                              onPressed: onLogInGooglePressed,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 48.h),
                      GoogleLoginProtocolItem(updatePolicyCheckState),
                      SizedBox(
                        height: 76.h,
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
      ZegoToastManager.shared
          .showToast(AppLocalizations.of(context)!.toastLoginServicePrivacy);
    }
  }

  void checkPermission() async {
    await Permission.camera.request();
    await Permission.microphone.request();
  }

  Future<void> logInWithGoogle() async {
    ZegoToastManager.shared
        .showLoading(message: AppLocalizations.of(context)!.loginPageLogin);

    try {
      // Trigger the authentication flow
      final googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final googleAuth = await googleUser?.authentication;

      if (googleAuth != null) {
        await ZegoLoginManager.shared.login(googleAuth.idToken ?? "");
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = '${e.message}';
      });
    } finally {
      ZegoToastManager.shared.hide();
    }
  }
}
