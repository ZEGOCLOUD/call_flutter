// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';

// Project imports:
import './../../constants/page_constant.dart';
import './../../widgets/browser.dart';

class GoogleLoginProtocolItem extends StatefulWidget {
  final ValueChanged<bool> updatePolicyCheckState;

  const GoogleLoginProtocolItem(this.updatePolicyCheckState, {Key? key})
      : super(key: key);

  @override
  GoogleLoginProtocolItemState createState() => GoogleLoginProtocolItemState();
}

class GoogleLoginProtocolItemState extends State<GoogleLoginProtocolItem> {
  bool isPolicyCheck = false;

  @override
  Widget build(BuildContext context) {
    const String termsOfServiceURL = "https://www.zegocloud"
        ".com/policy?index=1";
    const String privacyPolicyURL = "https://www.zegocloud"
        ".com/policy?index=0";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
            // width: 24.w,
            child: Checkbox(
          checkColor: Colors.white,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(6.0))),
          value: isPolicyCheck,
          onChanged: (bool? value) {
            setState(() {
              isPolicyCheck = value!;
            });
            widget.updatePolicyCheckState(isPolicyCheck);
          },
        )),
        Flexible(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyText1,
              children: [
                TextSpan(
                  text: AppLocalizations.of(context)!.loginPageServicePrivacy,
                ),
                TextSpan(
                  text: AppLocalizations.of(context)!.settingPageTermsOfService,
                  style: const TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchURL(context, termsOfServiceURL);
                    },
                ),
                const TextSpan(text: ' & '),
                TextSpan(
                  text: AppLocalizations.of(context)!.settingPagePrivacyPolicy,
                  style: const TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchURL(context, privacyPolicyURL);
                    },
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  void launchURL(BuildContext context, String targetURL) async {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return Browser(url: targetURL, backURL: PageRouteNames.login);
    }));
  }
}
