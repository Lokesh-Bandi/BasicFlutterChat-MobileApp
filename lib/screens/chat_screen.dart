import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
var _fireStore= FirebaseFirestore.instance;
User user;
var now;
var currentTime;
class ChatScreen extends StatefulWidget {
  static String id= 'chat_screen';
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  File _image;
  String _uploadedFileURL;
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
  Future uploadFile() async {
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('chats/${Path.basename(_image.path)}}');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadedFileURL = fileURL;
        print(_uploadedFileURL);
        var now=new DateTime.now();
        _fireStore.collection('messages').add({
          'Sender': user.email,
          'Text': _uploadedFileURL,
          'Time': now
        });
      });
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () async{
                _auth.signOut();
                SharedPreferences prefs= await SharedPreferences.getInstance();
                prefs.remove('alreadyVisited');
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
                    flex: 1,
                    child:FlatButton(
                      onPressed: () async{
                        setState(() async{
                          _image= await getImage();
                          uploadFile();
                        });
                      },
                      child: Icon(
                        Icons.image,
                        color: Colors.lime[300],
                        size: 30,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
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
          var message_id=message.id;
          var text= message.data()['Text'];
          var messageSender=message.data()['Sender'];
          var timeNow=message.data()['Time'];
          if(messageSender==user.email) {
            messageBubble = MessageBubble(text: text, sender: messageSender, isMe: true, time: timeNow,id: message_id);
          }
          else {
            messageBubble=MessageBubble(text: text,sender: messageSender,isMe: false,time: timeNow,id: message_id);
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
   String id;
  MessageBubble({this.text,this.sender,this.isMe,this.time,this.id});
  String getTime(){
    currentTime=new DateFormat.jm().format(time.toDate());
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
          FlatButton(
            onLongPress: (){
              showDialog(
                  context: context,
                barrierDismissible: true,
                builder: (context){
                return AlertDialog(
                  title:Text("Do you want to delete?"),
                  content: Image.network(
                    'https://tenor.com/view/crying-emoji-gif-10800494.gif',
                      height:60,
                      width: 60
                  ),
                  elevation: 30.0,
                  backgroundColor: Colors.white,
                  actions: [
                    FlatButton(
                      child:Text(
                          'No',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.teal
                        ),
                      ),
                      onPressed:() {Navigator.pop(context);},
                    ),
                    FlatButton(
                      child:Text(
                          'Yes',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.red
                        ),
                      ),
                      onPressed:() {
                        _fireStore.collection('messages').doc(this.id.toString()??'Default Value').delete();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              }
              );

              print("Pressed");
              print(this.id);
            },
            padding: EdgeInsets.all(0),
            child: Material(
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
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10,vertical: 3),
            child: Text(
              getTime(),
              style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: Colors.black54,
                  fontWeight: FontWeight.w900
              ),
            ),
          )
        ],
      ),
    );
  }
}


Future getImage() async{
  PickedFile selectedImage= await ImagePicker().getImage(source:ImageSource.gallery );
  final File file= File(selectedImage.path);
    return file;
}
