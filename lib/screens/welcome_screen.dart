import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/chat_screen.dart';
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
  String phoneNumber;
  final _codeController = TextEditingController();
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
  Future<bool> loginUser(String phone, BuildContext context) async{
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async{
          Navigator.of(context).pop();

          var result = await _auth.signInWithCredential(credential);

          // ignore: deprecated_member_use
          final user = result.user;

          if(user != null){
            Navigator.pushNamed(context,ChatScreen.id);
          }else{
            print("Error");
          }

          //This callback would gets called when verification is done auto maticlly
        },
        verificationFailed: (FirebaseAuthException exception){
          print(exception);
        },
        codeSent: (String verificationId, [int forceResendingToken]){
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: Text("Give the code?"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: _codeController,
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Confirm"),
                      textColor: Colors.white,
                      color: Colors.blue,
                      onPressed: () async{
                        final code = _codeController.text.trim();
                        // ignore: deprecated_member_use
                        AuthCredential credential = PhoneAuthProvider.getCredential(verificationId: verificationId, smsCode: code);

                        var result = await _auth.signInWithCredential(credential);

                        // ignore: deprecated_member_use
                        final user = result.user;

                        if(user != null){
                          Navigator.pushNamed(context,ChatScreen.id);
                        }else{
                          print("Error");
                        }
                      },
                    )
                  ],
                );
              }
          );
        },
        codeAutoRetrievalTimeout: (id){
          print(id);
        }
    );
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                child: TextField(
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    phoneNumber=value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter the mobile number',
                    hintStyle: TextStyle(
                        color: Colors.grey
                    ),
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Colors.lightBlueAccent, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
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
                    loginUser(phoneNumber, context);
                  },
                  minWidth: 200.0,
                  height: 42.0,
                  child: Text(
                    'SignIn',
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
