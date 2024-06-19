import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:speechy_app/speech_to_text.dart';

class splashScreen extends StatelessWidget {
  const splashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: LottieBuilder.asset("assets/Lottie/speech.json"),
            ),
          ),
        ],
      ),
      nextScreen: const SpeechText(),
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: Colors.white,
      splashIconSize: 300,
    );
  }
}