import 'dart:developer';
import 'dart:io';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../main.dart';

//login screen -- implements google sign in or sign up feature for app
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  _handleGoogleBtnClick() {
    Dialogs.showProgressBar(context);

    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        log('\nUser: ${user.user}');
        log('\nUserAdditionalInfo: ${user.additionalUserInfo}');

        if(await APIs.userExists()){
             Navigator.pushReplacement(context,MaterialPageRoute(builder: (_) => const HomeScreen(title: "we chat")));}
    
        else{
        await APIs.createUser().then((value) {
            Navigator.pushReplacement(context,MaterialPageRoute(builder: (_) => const HomeScreen(title: "we chat")));});
      
         
      }
   } });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log("\n_signInWithGoogle:$e");
      Dialogs.showSnackbar(context, "something wont wrong check your internet ");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    //initializing media query (for getting device screen size)
    mq = MediaQuery.of(context).size;

    return Scaffold(
      //app bar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome to ChatVerse'),
      ),

      //body
      body: Stack(children: [
        //app logo
        /*  AnimatedPositioned(
            top: mq.height * .15,
            right: _isAnimate ? mq.width * .25 : -mq.width * .5,
            width: mq.width * .5,
            duration: const Duration(seconds: 1),
            child: Image.asset('images/icon.png')),*/

                 //app logo
        Positioned(
            top: mq.height * .18,
            right: mq.width * .10,
            width: mq.width * .8,
            child: Image.asset("images/Chating-logo-by-meisuseno-580x446-removebg-preview.png")),
          

       


        //google login button
        Positioned(
            bottom: mq.height * .15,
            left: mq.width * .05,
            width: mq.width * .9,
            height: mq.height * .06,
            child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 223, 255, 187),
                    shape: const StadiumBorder(),
                    elevation: 1),
                    onPressed: () { _handleGoogleBtnClick();},
                //google icon
                icon: Image.asset('images/google.png', height: mq.height * .03),
                // Image.asset('images/google.png', height: mq.height * .03),

                //login with google label
                label: RichText(
                  text: const TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        TextSpan(text: 'Login with '),
                        TextSpan(text: 'Google', style: TextStyle(fontWeight: FontWeight.w500)),
                      ]),
                ))),
      ]),
    );
  }
}
