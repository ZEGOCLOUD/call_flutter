import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:zego_call_flutter/constants/zego_page_constant.dart';

import '../../service/zego_user_service.dart';

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
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.headline4,
                          children: const [
                            TextSpan(
                              text: "ZE",
                            ),
                            TextSpan(
                              text: "GO",
                              style: const TextStyle(color: Colors.blue),
                            ),
                            TextSpan(text: "CLOUD")
                          ],
                        ),
                      ),
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
                          child: isLoading
                              ? Container(
                                  color: Colors.grey[200],
                                  height: 50,
                                  width: double.infinity,
                                )
                              : Container(
                                  width: 602 / 2,
                                  height: 50,
                                  decoration: const BoxDecoration(
                                    color: Color(0xffF3F4F7),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                  ),
                                  child: TextButton(
                                    child: const Text('Sign in with Google'),
                                    onPressed: isPolicyCheck
                                        ? _signInWithGoogle
                                        : () {
                                            Fluttertoast.showToast(
                                                msg:
                                                    'Please tick to agree to the "Terms of Service" and "Privacy Policy"',
                                                backgroundColor: Colors.grey);
                                          },
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Checkbox(
                            checkColor: Colors.white,
                            value: isPolicyCheck,
                            onChanged: (bool? value) {
                              setState(() {
                                isPolicyCheck = value!;
                              });
                            },
                          ),
                          Flexible(
                            child: RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyText1,
                                children: [
                                  const TextSpan(
                                    text:
                                        "I have read and agree to ZEGO Call's ",
                                  ),
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: const TextStyle(color: Colors.blue),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // TODO open link
                                      },
                                  ),
                                  const TextSpan(text: ' & '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: const TextStyle(color: Colors.blue),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // TODO open link
                                      },
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
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