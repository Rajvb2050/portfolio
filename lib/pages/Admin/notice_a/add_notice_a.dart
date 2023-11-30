import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_parents/components/send_notification.dart';
import 'package:smart_parents/widgest/dropdown_widget.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';

class NoticeAdd extends StatefulWidget {
  const NoticeAdd({Key? key}) : super(key: key);
  @override
  State<NoticeAdd> createState() => _NoticeAddState();
}

class _NoticeAddState extends State<NoticeAdd> with NotificationMixin {
  String? branch1;
  final _formKey = GlobalKey<FormState>();
  final subjectController = TextEditingController();
  final noticeController = TextEditingController();
  @override
  void dispose() {
    subjectController.dispose();
    noticeController.dispose();
    super.dispose();
  }

  clearText() async {
    subjectController.clear();
    noticeController.clear();
  }

  var subject = '';
  var notice = '';
  String? docId;
  Future<void> addnotice() async {
    CollectionReference notices =
        FirebaseFirestore.instance.collection('Admin/$admin/Notices');
    docId = DateFormat('dd-MM-yyyy hh:mm:ss').format(DateTime.now());
    print(docId);
    notices
        .doc(docId)
        .set({
          'branch': branch1,
          'batch': batchyeardropdownValue,
          'subject': subject,
          'notice': notice,
          'date': docId,
        })
        .then((value) => print('notice Added'))
        .catchError((error) => print('Failed to Add user: $error'));
    sendNotificationToAllUsers(
        "Notice",
        '',
        subject,
        await FirebaseFirestore.instance
            .collection('Admin/$admin/parents')
            .where('branch', isEqualTo: branch1)
            .where('batch', isEqualTo: batchyeardropdownValue)
            .get());
    sendNotificationToAllUsers(
        "Notice",
        '',
        subject,
        await FirebaseFirestore.instance
            .collection('Admin/$admin/students')
            .where('branch', isEqualTo: branch1)
            .where('batch', isEqualTo: batchyeardropdownValue)
            .get());
    clearText();
  }

  Uint8List? _imageFile;
  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageFile = bytes;
        });
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _selectProfileImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> uploadImage() async {
    setState(() {});
    if (_imageFile == null) {
      return;
    }
    final storageRef =
        FirebaseStorage.instance.ref().child('$admin/Notices/$docId.jpg');
    final UploadTask uploadTask = storageRef.putData(_imageFile!);
    final TaskSnapshot downloadUrl = await uploadTask.whenComplete(() => null);
    final url = (await downloadUrl.ref.getDownloadURL());
    await FirebaseFirestore.instance
        .collection('Admin/$admin/Notices')
        .doc(docId)
        .update({'photoUrl': url});
    print('Image uploaded to Firebase Storage: $url');
  }

  Widget _buildPhotoWidget() {
    if (_imageFile != null) {
      return Stack(
        children: [
          Image.memory(_imageFile!),
          Positioned(
            right: 0,
            top: 0,
            child: FloatingActionButton(
              backgroundColor: Colors.transparent,
              onPressed: () {
                setState(() {
                  _imageFile = null;
                });
              },
              child: Icon(
                Icons.close,
                color: Colors.grey[100],
              ),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox(height: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Notice ", style: TextStyle(fontSize: 30.0)),
      ),
      body: Center(
        child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('Admin/$admin/department')
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              final items =
                  snapshot.data!.docs.map((doc) => doc.get('name')).toList();
              return ListView(children: [
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 30),
                    child: Column(children: [
                      Column(
                        children: [
                          const Text(
                            "Branch",
                            style: TextStyle(fontSize: 20),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(15.0),
                                border: Border.all(
                                    color: Colors.grey,
                                    style: BorderStyle.solid,
                                    width: 0.80),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(
                                      5.0,
                                      5.0,
                                    ),
                                    blurRadius: 5.0,
                                    spreadRadius: 1.0,
                                  ),
                                ]),
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: branch1,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              hint: const Text('Select an item'),
                              icon: const Icon(
                                  Icons.keyboard_arrow_down_outlined),
                              elevation: 16,
                              dropdownColor: Colors.grey[100],
                              style: const TextStyle(color: Colors.black),
                              onChanged: (value) {
                                setState(() {
                                  branch1 = value;
                                });
                              },
                              items: items.map((item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a branch';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Dropdown(
                        dropdownValue: batchyeardropdownValue,
                        string: batchList,
                        hint: "Batch(Starting Year)",
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 15),
                            margin: const EdgeInsets.only(
                              top: 20,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                  style: BorderStyle.solid, color: Colors.grey),
                            ),
                            child: TextFormField(
                              minLines: 1,
                              decoration: const InputDecoration(
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  hintText: "Enter notice topic:",
                                  hintStyle: TextStyle(fontSize: 18)),
                              controller: subjectController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter notice topic:';
                                }
                                return null;
                              },
                            ),
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width,
                              padding:
                                  const EdgeInsets.fromLTRB(15, 10, 15, 10),
                              margin: const EdgeInsets.only(
                                top: 20,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    style: BorderStyle.solid,
                                    color: Colors.grey),
                              ),
                              child: Column(
                                children: [
                                  _buildPhotoWidget(),
                                  TextFormField(
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      hintText: "Enter notice",
                                      hintStyle: const TextStyle(fontSize: 18),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.attach_file),
                                        onPressed: _selectProfileImage,
                                      ),
                                    ),
                                    controller: noticeController,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Enter notice';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.multiline,
                                  ),
                                ],
                              )),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  subject = subjectController.text;
                                  notice = noticeController.text;
                                  addnotice();
                                  uploadImage();
                                  Navigator.pop(context);
                                });
                              }
                            },
                            child: const Text(
                              "Add Notice",
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ),
                ),
              ]);
            }),
      ),
    );
  }
}
