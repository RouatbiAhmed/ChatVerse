import 'package:chat_app/home_screen.dart';
import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:chat_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

late Size mq;


  void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(MyApp());
}
  
//__________________________
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
//   runApp(const MyApp());
// }
//_______________first____________
// void main() {
//  WidgetsFlutterBinding.ensureInitialized();
//   initializeFirebase(); 
//   runApp( const MyApp());
// }

// initializeFirebase() async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  
// }


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        //title: 'We Chat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 1,
          iconTheme: IconThemeData(color: Color.fromARGB(255, 150, 46, 46)),
          titleTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 19),
          backgroundColor: Colors.white,
        )),
        
        home:SplashScreen()
        //  LoginScreen()

       //  HomeScreen(title: 'We chat',)

        );
  }
}



