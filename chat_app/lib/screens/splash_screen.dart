import 'dart:developer';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/home_screen.dart';
import 'package:chat_app/wigets/chat_user_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../main.dart';
import 'auth/login_screen.dart';


//splash screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {

      //exit full-screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          statusBarColor: Colors.white));

       //all ready loged in 
      if (APIs.auth.currentUser != null) {
        log('\nUser: ${APIs.auth.currentUser}');
        // Go to home screen
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (_) => const HomeScreen(title: 'ChatVerse')));
      } else {
        //Go to loginscreen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //initializing media query (for getting device screen size)
     mq = MediaQuery.of(context).size;

    return Scaffold(
      //body
      body: Stack(children: [
        //app logo
        Positioned(
            top: mq.height * .18,
            right: mq.width * .10,
            width: mq.width * .8,
            child: Image.asset("images/Chating-logo-by-meisuseno-580x446-removebg-preview.png")),

        //google login button
        Positioned(
            bottom: mq.height * .15,
            width: mq.width,
            child: const Text('Unlock the Power of Connection',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87, letterSpacing: .5))),
      ]),
    );
  }
}
