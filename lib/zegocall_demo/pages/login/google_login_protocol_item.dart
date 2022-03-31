// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Project imports:
import './../../../utils/widgets/browser.dart';
import './../../constants/zego_page_constant.dart';

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
                const TextSpan(
                  text: "I have read and agree to ZEGO Call's ",
                ),
                TextSpan(
                  text: 'Terms of Service',
                  style: const TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchURL(context, termsOfServiceURL);
                    },
                ),
                const TextSpan(text: ' & '),
                TextSpan(
                  text: 'Privacy Policy',
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
