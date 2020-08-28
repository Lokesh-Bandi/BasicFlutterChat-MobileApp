import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'registration_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static String id= 'welcome_screen';
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  AnimationController logoController;
  AnimationController titleController;
  Animation animation;
  Animation loginAnimation;
  Animation registerAnimation;

  void initState() {
    super.initState();
    logoController = AnimationController(
      vsync: this, // the SingleTickerProviderStateMixin
      duration: Duration(
        seconds: 2,
      ),
    );
    titleController = AnimationController(
      vsync: this, // the SingleTickerProviderStateMixin
      duration: Duration(
        seconds: 2,
      ),
      upperBound: 45.0
    );
    animation=ColorTween(begin: Colors.lightBlueAccent,end: Colors.white).animate(logoController);
    loginAnimation=ColorTween(begin: Colors.white,end: Colors.lightBlueAccent).animate(logoController);
    registerAnimation=ColorTween(begin: Colors.white,end: Colors.blueAccent).animate(logoController);
    logoController.forward();
    logoController.addListener(() {
      setState(() {});
    });
    titleController.forward();
    titleController.addListener(() {
      setState(() {});
      print(animation.value);
    });
  }
  void dispose() {
    logoController.dispose();
    titleController.dispose();
    super.dispose();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: logoController.value*100,
                  ),
                ),
                Text(
                  'SPD Chat',
                  style: TextStyle(
                    fontSize: titleController.value,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: titleController.value,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Material(
                elevation: 5.0,
                color: loginAnimation.value,
                borderRadius: BorderRadius.circular(30.0),
                child: MaterialButton(
                  onPressed: () {
                    Navigator.pushNamed(context, LoginScreen.id);
                  },
                  minWidth: 200.0,
                  height: 42.0,
                  child: Text(
                    'Log In',
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Material(
                color: registerAnimation.value,
                borderRadius: BorderRadius.circular(30.0),
                elevation: 5.0,
                child: MaterialButton(
                  onPressed: () {
                    Navigator.pushNamed(context, RegistrationScreen.id);
                  },
                  minWidth: 200.0,
                  height: 42.0,
                  child: Text(
                    'Register',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
