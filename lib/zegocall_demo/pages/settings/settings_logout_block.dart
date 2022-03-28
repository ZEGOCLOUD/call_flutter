import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:zego_call_flutter/utils/styles.dart';
import 'package:zego_call_flutter/zegocall_demo/constants/zego_page_constant.dart';

class SettingsLogoutBlock extends StatelessWidget {
  const SettingsLogoutBlock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
          height: 98.h,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: StyleColors.settingsCellBackgroundColor,
          ),
          child: Center(
              child: Text(AppLocalizations.of(context)!.settingPageLogout,
                  textAlign: TextAlign.center,
                  style: StyleConstant.settingLogout))),
      onTap: () {
        signOut(context);
      },
    );
  }

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    Navigator.pushReplacementNamed(context, PageRouteNames.auth);
  }
}
