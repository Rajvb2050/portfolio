import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:smart_parents/components/send_notification.dart';

final _fireStore = FirebaseFirestore.instance;
String? loggedName;
String? id;
List<Map<String?, String>> messages = [];

class ChatStudent extends StatefulWidget {
  const ChatStudent({super.key});
  @override
  ChatStudentState createState() => ChatStudentState();
}

class ChatStudentState extends State<ChatStudent> with NotificationMixin {
  final messageTextController = TextEditingController();
  late String messageText = '';
  @override
  void initState() {
    super.initState();
    getUserName();
  }

  final _prefs = SharedPreferences.getInstance();
  void getUserName() async {
    final SharedPreferences prefs = await _prefs;
    id = prefs.getString('id');
    DocumentSnapshot userSnapshot =
        await _fireStore.collection('Admin/$admin/students').doc(id).get();
    loggedName = userSnapshot.get('name');
  }

  void _handleSubmitted(String text) {
    print('Submitted: $text');
    if (messageText != '') {
      Map<String?, String> messageMap = {
        id: messageText,
      };
      messages.add(messageMap);
      messageTextController.clear();
      _fireStore
          .collection('Admin/$admin/messages')
          .doc(branch)
          .get()
          .then((value) async => {
                if (value.exists)
                  {
                    _fireStore
                        .collection('Admin/$admin/messages')
                        .doc(branch)
                        .update({batch.toString(): messages})
                  }
                else
                  {
                    _fireStore
                        .collection('Admin/$admin/messages')
                        .doc(branch)
                        .set({batch.toString(): messages})
                  },
                sendNotificationToAllUsers(
                    "Message from student",
                    '',
                    text,
                    await FirebaseFirestore.instance
                        .collection('Admin/$admin/faculty')
                        .where('branch', isEqualTo: branch)
                        .get()),
              });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(background),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('️Chat with Faculty'),
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomStreamBuilder(),
              Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageTextController,
                        onChanged: (value) {
                          messageText = value;
                        },
                        onSubmitted: _handleSubmitted,
                        decoration: kMessageTextFieldDecoration,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    RawKeyboardListener(
                      focusNode: FocusNode(),
                      onKey: (RawKeyEvent event) {
                        if (event is RawKeyUpEvent &&
                            event.logicalKey == LogicalKeyboardKey.enter) {
                          _handleSubmitted(messageTextController.text);
                        }
                      },
                      child: TextButton(
                        onPressed: () {
                          _handleSubmitted(messageTextController.text);
                        },
                        child: const Text(
                          'Send',
                          style: kSendButtonTextStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomStreamBuilder extends StatelessWidget {
  final ScrollController _scrollController;
  CustomStreamBuilder({Key? key})
      : _scrollController = ScrollController(),
        super(key: key);
  void scroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _fireStore
          .collection('Admin/$admin/messages')
          .doc(branch)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
        } else if (snapshot.hasData) {
          messages = [];
          Map<String, dynamic>? data = snapshot.data?.data();
          List<MessageBubble> messageBubbles = [];
          if (data != null) {
            print(batch);
            if (data[batch] != null) {
              List<dynamic> test = data[batch] as List<dynamic>;
              for (var elem in test) {
                Map<String?, dynamic> tmp = elem as Map<String?, dynamic>;
                tmp.forEach((key, value) {
                  final messageText = value;
                  final messageSender = key;
                  if (messageText != null && messageSender != null) {
                    messages.add({key: value});
                    final messageBubble = MessageBubble(
                        messageText: messageText,
                        messageSender: messageSender,
                        isMineMessage: id == key ? true : false);
                    messageBubbles.add(messageBubble);
                  }
                });
              }
              scroll();
              return Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 20.0,
                  ),
                  children: messageBubbles,
                ),
              );
            } else {
              print('data[batch] == false');
            }
          } else {
            print('data==null');
          }
        } else {
          return const Center(
              child: CircularProgressIndicator(backgroundColor: kPrimaryColor));
        }
        return Container();
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble(
      {super.key,
      required this.messageText,
      required this.messageSender,
      required this.isMineMessage});
  final String messageText;
  final String messageSender;
  final bool isMineMessage;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(
          10.0,
        ),
        child: Column(
          crossAxisAlignment: isMineMessage == true
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              messageSender,
              style: const TextStyle(
                fontSize: 13.0,
                color: Colors.black,
              ),
            ),
            const SizedBox(
              height: 4.0,
            ),
            Container(
              constraints: const BoxConstraints(
                maxWidth: 250,
              ),
              child: Material(
                borderRadius: BorderRadius.circular(15.0),
                elevation: 5.0,
                color:
                    isMineMessage == true ? kPrimaryColor : kPrimaryLightColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 10,
                  ),
                  child: Text(
                    messageText,
                    style: TextStyle(
                      fontSize: 14.0,
                      color:
                          isMineMessage == true ? Colors.white : Colors.black87,
                    ),
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
