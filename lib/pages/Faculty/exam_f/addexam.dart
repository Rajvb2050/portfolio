import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:smart_parents/components/imageshow.dart';
import 'package:smart_parents/pages/Faculty/exam_f/addexamtime.dart';
import 'package:smart_parents/widgest/animation.dart';

class AddExam extends StatefulWidget {
  const AddExam({Key? key, required this.docid, required this.name})
      : super(key: key);
  final String docid;
  final String name;
  @override
  State<AddExam> createState() => _AddExamState();
}

class _AddExamState extends State<AddExam> {
  final nameController = TextEditingController();
  deleteUser(id) {
    CollectionReference exam = FirebaseFirestore.instance
        .collection('Admin/$admin/exams/${widget.docid}/exam');
    return exam
        .doc(id)
        .delete()
        .then((value) => print('User Deleted'))
        .catchError((error) => print('Failed to Delete user: $error'));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Admin/$admin/exams/${widget.docid}/exam')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Something went Wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final List storedocs = [];
          snapshot.data!.docs.map((DocumentSnapshot document) {
            Map a = document.data() as Map<String, dynamic>;
            storedocs.add(a);
            a['id'] = document.id;
          }).toList();
          return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: "Back",
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title:
                    Text(widget.name, style: const TextStyle(fontSize: 30.0)),
              ),
              body: Column(
                children: [
                  _buildPhotoWidget(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: storedocs.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 5,
                          shadowColor: Colors.grey[200],
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Subject: ${storedocs[index]['subject']}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0),
                                    ),
                                    Text(
                                      'Date: ${storedocs[index]['date']}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0),
                                    ),
                                    Text(
                                      'Time: ${storedocs[index]['starttime']} to ${storedocs[index]['endtime']}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text("Delete"),
                                    IconButton(
                                      highlightColor: red,
                                      onPressed: () async {
                                        showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  const Text("Confirm Delete"),
                                              content: const Text(
                                                  "Are you sure you want to delete this item?"),
                                              actions: [
                                                TextButton(
                                                  child: const Text("CANCEL"),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text("DELETE"),
                                                  onPressed: () {
                                                    try {
                                                      deleteUser(
                                                          storedocs[index]
                                                              ['id']);
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                            content: Text(
                                                                'Notice deleted.')),
                                                      );
                                                    } catch (e) {
                                                      print(e);
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                            content: Text(
                                                                'Failed to delete Notice: $e')),
                                                      );
                                                    }
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
              floatingActionButton: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: 'button1',
                    onPressed: () {
                      _selectProfileImage();
                    },
                    child: const Icon(Icons.add_a_photo_outlined),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  FloatingActionButton(
                    heroTag: 'button2',
                    onPressed: () => {
                      Navigator.push(
                          context,
                          FloatingAnimation(AddExamTimeTable(
                            docid: widget.docid,
                            name: widget.name,
                          ))),
                    },
                    child: const Icon(Icons.add),
                  ),
                ],
              ));
        });
  }

  @override
  void initState() {
    super.initState();
    _loadPhotoUrl();
  }

  String? docId;
  String? _imageUrl;
  void _loadPhotoUrl() async {
    final doc = await FirebaseFirestore.instance
        .collection('Admin/$admin/exams')
        .doc(widget.docid)
        .get();
    setState(() {
      try {
        _imageUrl = doc.data()!['photoUrl'];
      } catch (e) {
        print('no data');
      }
    });
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
    setState(() {
      _uploading = true;
    });
    if (_imageFile == null) {
      return;
    }
    if (_imageFile == null) {
      return;
    }
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('$admin/exams/${widget.docid}.jpg');
    final UploadTask uploadTask = storageRef.putData(_imageFile!);
    final TaskSnapshot downloadUrl = await uploadTask.whenComplete(() => null);
    final url = (await downloadUrl.ref.getDownloadURL());
    await FirebaseFirestore.instance
        .collection('Admin/$admin/exams')
        .doc(widget.docid)
        .update({'photoUrl': url});
    setState(() {
      _imageUrl = url;
      _uploading = false;
    });
    print('Image uploaded to Firebase Storage: $url');
  }

  bool _uploading = false;
  Widget _buildPhotoWidget() {
    if (_uploading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_imageUrl != null) {
      return Container(
        margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => FullScreenImageScreen(
                  imageUrl: _imageUrl!,
                ),
              ),
            );
          },
          child: ImageNetwork(
            image: _imageUrl!,
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width * 0.8,
            fitAndroidIos: BoxFit.contain,
            fitWeb: BoxFitWeb.contain,
            onLoading: const CircularProgressIndicator(
              color: kPrimaryColor,
            ),
            onError: const Icon(
              Icons.error,
              color: red,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => FullScreenImageScreen(
                    imageUrl: _imageUrl!,
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      return const SizedBox(height: 0);
    }
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
          uploadImage();
        });
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
