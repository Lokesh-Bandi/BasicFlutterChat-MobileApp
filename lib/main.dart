import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
bool alreadyVisited;
Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs= await SharedPreferences.getInstance();
  alreadyVisited=prefs.getBool('alreadyVisited');
  runApp(FlashChat());
}
class FlashChat extends StatefulWidget {
  @override
  _FlashChatState createState() => _FlashChatState();
}

class _FlashChatState extends State<FlashChat> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: (alreadyVisited==null)?(LoginScreen()):(ChatScreen()),
      //initialRoute: WelcomeScreen.id,
        routes:{
          WelcomeScreen.id:   (context) => WelcomeScreen(),
          LoginScreen.id: (context)=>LoginScreen(),
          RegistrationScreen.id: (context)=>RegistrationScreen(),
          ChatScreen.id: (context)=>ChatScreen()
        }
    );
  }
}


