import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_call_flutter/zegocall_demo/constants/zego_page_constant.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:zego_call_flutter/utils/styles.dart';
import 'auth_protocol_item.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class AuthGate extends StatefulWidget {
  // ignore: public_member_api_docs
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String error = '';
  String verificationId = '';

  bool isLoading = false;
  bool isPolicyCheck = false;

  void setIsLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((event) {
      if (event != null) {
        Navigator.pushReplacementNamed(context, PageRouteNames.welcome);
      }
    });
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
                      const Text(
                        "ZEGO Call",
                        style: TextStyle(fontSize: 24, color: Colors.black),
                      ),
                      Expanded(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Visibility(
                            visible: isLoading,
                            child: Container(
                                width: 192,
                                height: 177,
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: const [
                                    SizedBox(
                                      width: 84,
                                      height: 84,
                                      child: CircularProgressIndicator(
                                        value: null,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      "Loging in ...",
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                )),
                          ),
                        ],
                      )),
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
                                    const Text('Log in with Google')
                                  ]),
                              onPressed: isLoading
                                  ? null //  disable button is loading
                                  : onLogInGooglePressed,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 48.h),
                      AuthProtocolItem(updatePolicyCheckState),
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
    if (isPolicyCheck) {
      checkPermission();
      _signInWithGoogle();
    } else {
      Fluttertoast.showToast(
          msg:
              'Please tick to agree to the "Terms of Service" and "Privacy Policy"',
          backgroundColor: Colors.grey);
    }
  }

  void checkPermission() async {
    await Permission.camera.request();
    await Permission.microphone.request();
  }

  Future<void> _signInWithGoogle() async {
    setIsLoading();
    try {
      // Trigger the authentication flow
      final googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final googleAuth = await googleUser?.authentication;

      if (googleAuth != null) {
        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Once signed in, return the UserCredential
        await _auth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = '${e.message}';
      });
    } finally {
      setIsLoading();
    }
  }
}
