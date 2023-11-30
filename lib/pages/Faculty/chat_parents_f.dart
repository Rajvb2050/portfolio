import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:smart_parents/components/send_notification.dart';
import 'package:smart_parents/widgest/dropdown_widget.dart';

final _fireStore = FirebaseFirestore.instance;
String? loggedName;
String? id;
List<Map<String?, String>> messages = [];

class ChatParent extends StatefulWidget {
  const ChatParent({super.key});
  @override
  ChatParentState createState() => ChatParentState();
}

class ChatParentState extends State<ChatParent> with NotificationMixin {
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
        await _fireStore.collection('Admin/$admin/faculty').doc(id).get();
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
          .collection('Admin/$admin/messages_parent')
          .doc(branch)
          .get()
          .then((value) async => {
                if (value.exists)
                  {
                    _fireStore
                        .collection('Admin/$admin/messages_parent')
                        .doc(branch)
                        .update({batchyeardropdownValue: messages})
                  }
                else
                  {
                    _fireStore
                        .collection('Admin/$admin/messages_parent')
                        .doc(branch)
                        .set({batchyeardropdownValue: messages})
                  },
                sendNotificationToAllUsers(
                    "Message from faculty",
                    '',
                    text,
                    await FirebaseFirestore.instance
                        .collection('Admin/$admin/parents')
                        .where('branch', isEqualTo: branch)
                        .where('batch', isEqualTo: batchyeardropdownValue)
                        .get()),
              });
    }
  }

  void _showNumberPicker(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Select a Batch'),
          content: Dropdown(
            dropdownValue: batchyeardropdownValue,
            string: batchList,
            hint: "Batch(Starting Year)",
          ),
          actions: [
            TextButton(
                onPressed: () {
                  setState(() {
                    Navigator.of(context).pop();
                  });
                },
                child: const Text('Ok'))
          ],
        );
      },
    );
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
          title: const Text('️Chat with Parents'),
          actions: [
            GestureDetector(
              child: TextButton.icon(
                label: Text(
                  'Batch',
                  style: GoogleFonts.rubik(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                icon: Container(
                  width: 60,
                  height: 25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white,
                  ),
                  child: Text(
                    batchyeardropdownValue,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rubik(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                onPressed: () {
                  _showNumberPicker(context);
                },
              ),
            ),
          ],
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
          .collection('Admin/$admin/messages_parent')
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
            print(batchyeardropdownValue);
            if (data[batchyeardropdownValue] != null) {
              List<dynamic> test =
                  data[batchyeardropdownValue] as List<dynamic>;
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
              print('data[batchyeardropdownValue] == false');
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
