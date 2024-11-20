import 'dart:async';
import 'onboardingscreen.dart';
import 'package:flutter/material.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import 'colors.dart';
import 'package:ess_app/state/wrapper.dart';
import 'dashboard.dart';


class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {

    super.initState();
    Timer(const Duration(seconds: 3),
            ()=>Navigator.pushReplacement(context,
            MaterialPageRoute(builder:
                (context) =>
            const Authwrapper()
            )
        )
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: primaryColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
               WidgetAnimator(
                 atRestEffect: WidgetRestingEffects.rotate(),
                 child: Container(
                   width: 100,
                   height: 100,
                   decoration: BoxDecoration(
                     color: Colors.white,
                    /* shape: BoxShape.circle,*/
                   ),
                 ),
               )
              ],
            ),

          ],
        ),

      ),
    );
  }
}
