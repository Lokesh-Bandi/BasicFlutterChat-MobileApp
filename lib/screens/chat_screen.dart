import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
final _fireStore= FirebaseFirestore.instance;
class ChatScreen extends StatefulWidget {
  static String id= 'chat_screen';
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth =FirebaseAuth.instance;
  String messageText;
  User user;
  final messageTextController =TextEditingController();
  void initState() {
    super.initState();
    getCurrentUser();
  }
  void getCurrentUser() {
    try {
      user =  _auth.currentUser;
      if (user != null) {
        print(user.email);
      }
    }
    catch(e){
      print(e);
    }
  }
  void getMessageStream() async{
    await  for (var snapshot in _fireStore.collection('messages').snapshots()){
      // ignore: deprecated_member_use
      for(var message in snapshot.documents){
        print(message.data());
      }
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text(' Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText=value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      _fireStore.collection('messages').add({
                        'Sender': user.email,
                        'Text': messageText
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore.collection('messages').snapshots(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        // ignore: deprecated_member_use
        final messages =snapshot.data.documents;
        List<MessageBubble> messageBubbles=[];
        for(var message in messages){
          var text= message.data()['Text'];
          var messageSender=message.data()['Sender'];
          var messageBubble=MessageBubble(text: text,sender: messageSender);
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            children: messageBubbles,
          ),
        );
      },
    );
  }
}


class MessageBubble extends StatelessWidget {
  String text;
  String sender;
  MessageBubble({this.text,this.sender});
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text('$sender',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),),
          Material(
            borderRadius: BorderRadius.circular(30.0),
            color: Colors.lightGreenAccent,
            child: Padding(
              padding:  EdgeInsets.symmetric(vertical: 12 , horizontal: 20),
              child: Text(
                  '$text',
                style: TextStyle(
                  fontSize: 14
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
