import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:smart_parents/components/send_notification.dart';
import 'package:smart_parents/widgest/dropdown_widget.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

class DataModel {
  final String name;
  final String mime;
  final int bytes;
  final String url;
  DataModel({
    required this.name,
    required this.mime,
    required this.bytes,
    required this.url,
  });
  String get size {
    final kb = bytes / 1024;
    final mb = kb / 1024;
    return mb > 1
        ? '${mb.toStringAsFixed(2)}MB'
        : '${kb.toStringAsFixed(2)} KB';
  }
}

class ResultAdd extends StatefulWidget {
  const ResultAdd({super.key});
  @override
  State<ResultAdd> createState() => _ResultAddState();
}

class _ResultAddState extends State<ResultAdd> with NotificationMixin {
  DataModel? task;
  File? file;
  final subjectController = TextEditingController();
  @override
  void dispose() {
    subjectController.dispose();
    super.dispose();
  }

  clearText() async {
    subjectController.clear();
  }

  Future selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      final path = result.files.single.path!;
      setState(() => file = File(path));
    }
  }

  CollectionReference results =
      FirebaseFirestore.instance.collection('Admin/$admin/Results');
  String? docId;
  var subject = '';
  Future uploadFile() async {
    if (file == null) return;
    var date = DateFormat('dd-MM-yyyy hh:mm:ss').format(DateTime.now());
    DocumentReference docRef = results.doc();
    docRef.set({
      'branch': branch,
      'batch': batchyeardropdownValue,
      'subject': subject,
      'date': date,
    }).then((_) {
      docId = docRef.id;
      print('Document ID: ${docRef.id}');
    }).catchError((error) {
      print('Failed to Add user: $error');
      return null;
    });
    docId = docRef.id;
    final storageRef =
        FirebaseStorage.instance.ref().child('$admin/Results/$docId.pdf');
    final UploadTask uploadTask = storageRef.putFile(file!);
    final TaskSnapshot downloadUrl = await uploadTask.whenComplete(() => null);
    final url = (await downloadUrl.ref.getDownloadURL());
    await FirebaseFirestore.instance
        .collection('Admin/$admin/Results')
        .doc(docId)
        .update({'pdf': url});
    sendNotificationToAllUsers(
        "Result",
        '',
        subject,
        await FirebaseFirestore.instance
            .collection('Admin/$admin/students')
            .where('branch', isEqualTo: branch)
            .where('batch', isEqualTo: batchyeardropdownValue)
            .get());
    sendNotificationToAllUsers(
        "Result",
        '',
        subject,
        await FirebaseFirestore.instance
            .collection('Admin/$admin/parents')
            .where('branch', isEqualTo: branch)
            .where('batch', isEqualTo: batchyeardropdownValue)
            .get());
    print('Image uploaded to Firebase Storage: $url');
    clearText();
    Navigator.pop(context);
    return const CircularProgressIndicator();
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final fileName = file != null ? path.basename(file!.path) : null;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Result'),
        ),
        body: SingleChildScrollView(
            child: Form(
          key: _formKey,
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              children: [
                Dropdown(
                  dropdownValue: batchyeardropdownValue,
                  string: batchList,
                  hint: "Batch(Starting Year)",
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 15),
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
                        hintText: "Enter result topic:",
                        hintStyle: TextStyle(fontSize: 18)),
                    controller: subjectController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter result topic:';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                DottedBorder(
                  color: kPrimaryColor,
                  dashPattern: const [10, 15],
                  strokeWidth: 5,
                  child: Container(
                    width: double.infinity,
                    color: kPrimaryLightColor,
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              if (fileName == null) ...{
                                const Text(
                                  'Please select file!',
                                  style: TextStyle(color: red),
                                ),
                              } else ...{
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.picture_as_pdf,
                                      color: kPrimaryColor,
                                      size: 20,
                                    ),
                                    Text(fileName,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: kPrimaryColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              },
                              const Icon(
                                Icons.file_upload_outlined,
                                size: 100,
                                color: kPrimaryColor,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              ElevatedButton.icon(
                                  onPressed: selectFile,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30.0, vertical: 15.0),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                  ),
                                  label: const Text(
                                    "Browse File",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  icon: const Icon(Icons.search)),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 55,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (file == null) {
                      } else {
                        setState(() {
                          subject = subjectController.text;
                          uploadFile();
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 20.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                  ),
                  child: const Text(
                    "Upload Result",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        )));
  }
}
