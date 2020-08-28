import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'login_screen.dart';
import 'registration_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static String id= 'welcome_screen';
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  AnimationController logoController;
  AnimationController bodyController;
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
    bodyController = AnimationController(
      vsync: this, // the SingleTickerProviderStateMixin
      duration: Duration(
        seconds: 2,
      ),
    );

    animation=ColorTween(begin: Colors.lightBlueAccent,end: Colors.white).animate(bodyController);
    loginAnimation=ColorTween(begin: Colors.white,end: Colors.lightBlueAccent).animate(bodyController);
    registerAnimation=ColorTween(begin: Colors.white,end: Colors.blueAccent).animate(bodyController);
    logoController.forward();
    logoController.addListener(() {
      setState(() {});
    });
    bodyController.forward();
    bodyController.addListener(() {
      setState(() {});
    });

  }
  void dispose() {
    logoController.dispose();
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
                    child: Image.asset('images/hummingbird_PNG66.png'),
                    height: logoController.value*70,
                  ),
                ),
                Text(
                  'SPD ',
                  style: TextStyle(
                      fontSize: 45.0,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Lobster'
                  ),
                ),
                Expanded(
                  child: ScaleAnimatedTextKit(
                    text: ['Chat','Talk','Wave'],
                    textStyle: TextStyle(
                      fontSize: 35.0,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Lobster'
                    ),
                    textAlign: TextAlign.start,
                    alignment: AlignmentDirectional.topStart
                ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
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
