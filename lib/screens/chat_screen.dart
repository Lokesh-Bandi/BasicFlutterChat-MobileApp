import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'login_screen.dart';
var _fireStore= FirebaseFirestore.instance;
User user;
var now;
var currentTime;
class ChatScreen extends StatefulWidget {
  static String id= 'chat_screen';
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth =FirebaseAuth.instance;
  String messageText;
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
                Navigator.pushNamed(context,LoginScreen.id);
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
                    flex: 5,
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText=value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  Expanded(
                    flex:1,
                    child: FlatButton(
                      onPressed: () {
                        if(messageText!=null) {
                          now = new DateTime.now();
                          _fireStore.collection('messages').add({
                            'Sender': user.email,
                            'Text': messageText,
                            'Time': now
                          });
                        }
                        messageTextController.clear();
                        messageText=null;
                      },
                      child: Icon(
                          Icons.send,
                          size: 40,
                        color: Colors.lightBlueAccent,
                      )
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
      stream: _fireStore.collection('messages').orderBy('Time').snapshots(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        // ignore: deprecated_member_use
        final messages =snapshot.data.documents.reversed;
        List<MessageBubble> messageBubbles=[];
        var messageBubble;
        for(var message in messages){
          var text= message.data()['Text'];
          var messageSender=message.data()['Sender'];
          var timeNow=message.data()['Time'];
          if(messageSender==user.email)
            messageBubble=MessageBubble(text: text,sender: messageSender,isMe: true,time: timeNow);
          else {
            messageBubble=MessageBubble(text: text,sender: messageSender,isMe: false,time: timeNow);
          }
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
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
  bool isMe;
  Timestamp time;
  MessageBubble({this.text,this.sender,this.isMe,this.time});
  String getTime(){
    currentTime=new DateFormat('h:m').format(time.toDate());
    return currentTime;
  }
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.all(.0),
      child: Column(
        crossAxisAlignment: (isMe)?CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: <Widget>[
          /*Text('$sender',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
          ),*/
          Material(
            elevation: 6.0,
            borderRadius: (isMe)?(BorderRadius.only(
                topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(40)
            )):(BorderRadius.only(
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(30)
            )),
            color: (isMe)?Colors.cyan:Colors.grey[300],
            child: Padding(
              padding:  EdgeInsets.symmetric(vertical: 10 , horizontal: 20),
              child: Text(
                '$text',
                style: TextStyle(
                    color: (isMe)?Colors.white:Colors.black87,
                    fontSize: 17
                ),
              ),
            ),
          ),
          Text(
            getTime(),
            style: TextStyle(
                fontSize: 10,
                letterSpacing: 2,
                color: Colors.black54,
                fontWeight: FontWeight.w900
            ),
          )
        ],
      ),
    );
  }
}
