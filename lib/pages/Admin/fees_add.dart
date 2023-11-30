import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:smart_parents/components/send_notification.dart';
import 'package:smart_parents/pages/Admin/fees.dart';

class FeesAdd extends StatefulWidget {
  const FeesAdd({Key? key}) : super(key: key);
  @override
  FeesAddState createState() => FeesAddState();
}

class FeesAddState extends State<FeesAdd> with NotificationMixin {
  final _formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final semController = TextEditingController();
  @override
  void initState() {
    datafetch();
    super.initState();
  }

  @override
  void dispose() {
    amountController.dispose();
    semController.dispose();
    super.dispose();
  }

  datafetch() {
    setState(() {
      studentStream = FirebaseFirestore.instance
          .collection('Admin/$admin/students')
          .where('batch', isEqualTo: batchyeardropdownValue)
          .snapshots();
    });
  }

  Future<void> addUser() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Payment"),
          content: const Text("Are you sure you want to pay?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Payment"),
              onPressed: () async {
                try {
                  CollectionReference students = FirebaseFirestore.instance
                      .collection('Admin/$admin/fees');
                  students
                      .add({
                        'number': selectedItem,
                        'amount': amount,
                        'sem': sem,
                        'name': namestudent,
                        'date': DateFormat('dd-MM-yyyy hh:mm:ss')
                            .format(DateTime.now()),
                      })
                      .then((value) => print('fee Added'))
                      .catchError(
                          (error) => print('Failed to Add user: $error'));
                  sendNotificationToAllUsers(
                      "Fees",
                      '',
                      '$amount is paid',
                      await FirebaseFirestore.instance
                          .collection('Admin/$admin/students')
                          .where('number', isEqualTo: selectedItem)
                          .get());
                  sendNotificationToAllUsers(
                      "Fees",
                      '',
                      '$amount is paid',
                      await FirebaseFirestore.instance
                          .collection('Admin/$admin/parents')
                          .where('child', isEqualTo: selectedItem)
                          .get());
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const Fees()),
                  );
                } catch (e) {
                  print(e);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete Notice: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  late Stream<QuerySnapshot> studentStream;
  String sem = '';
  String amount = '';
  String? namestudent;
  String? selectedItem;
  final TextEditingController _searchController = TextEditingController();
  bool isDropdownOpen = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: const BackButton(),
          title: const Text('Add Fees', style: TextStyle(fontSize: 30.0))),
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: studentStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            final items =
                snapshot.data!.docs.map((doc) => doc.get('number')).toList();
            final names =
                snapshot.data!.docs.map((doc) => doc.get('name')).toList();
            return Form(
              key: _formKey,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                child: ListView(
                  children: [
                    const Text(
                      "Batch(Starting Year)",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: batchyeardropdownValue,
                        icon: const Icon(Icons.keyboard_arrow_down_outlined),
                        elevation: 16,
                        dropdownColor: Colors.grey[100],
                        style: const TextStyle(color: Colors.black),
                        underline: Container(height: 0, color: Colors.black),
                        onChanged: (String? newval) {
                          setState(() {
                            batchyeardropdownValue = newval!;
                            datafetch();
                          });
                        },
                        items: batchList
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _searchController,
                                  decoration: const InputDecoration(
                                    hintText: 'Search for an Enrollment',
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    datafetch();
                                    isDropdownOpen = !isDropdownOpen;
                                  });
                                },
                                icon: Icon(
                                  isDropdownOpen
                                      ? Icons.arrow_drop_up
                                      : Icons.arrow_drop_down,
                                  size: 32.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        if (isDropdownOpen)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Column(
                              children: [
                                for (String item in items)
                                  if (_searchController.text.isEmpty ||
                                      item.toLowerCase().contains(
                                          _searchController.text.toLowerCase()))
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          int name = items.indexOf(item);
                                          namestudent = names[name];
                                          selectedItem = item;
                                          isDropdownOpen = false;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Text(item),
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        if (selectedItem != null) ...{
                          Container(
                            padding: const EdgeInsets.only(left: 0.0, top: 8.0),
                            child: Text(
                              '$selectedItem',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                  fontSize: 20.0),
                            ),
                          ),
                        } else ...{
                          Container(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: const Text(
                              'Please select enrollment!',
                              style: TextStyle(
                                  fontSize: 15, color: Color(0xEAB00000)),
                            ),
                          ),
                        }
                      ],
                    ),
                    if (namestudent != null)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          '$namestudent',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                              fontSize: 20.0),
                        ),
                      ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      child: TextFormField(
                        maxLength: 1,
                        autofocus: false,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Semester: ',
                          labelStyle: TextStyle(fontSize: 20.0),
                          errorStyle:
                              TextStyle(fontSize: 15, color: Color(0xEAB00000)),
                        ),
                        controller: semController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Semester';
                          } else if (value.length != 1) {
                            return 'Please Enter Valid Semester';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      child: TextFormField(
                        autofocus: false,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Amount: ',
                          labelStyle: TextStyle(fontSize: 20.0),
                          border: OutlineInputBorder(),
                          errorStyle:
                              TextStyle(fontSize: 15, color: Color(0xEAB00000)),
                        ),
                        controller: amountController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Amount';
                          }
                          return null;
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (selectedItem != null) {
                            setState(() {
                              sem = semController.text;
                              amount = amountController.text;
                              addUser();
                            });
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        minimumSize: const Size(150, 50),
                      ),
                      child: const Text(
                        'Fees payment',
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
