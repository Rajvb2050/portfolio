import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:smart_parents/components/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactF extends StatefulWidget {
  const ContactF({Key? key}) : super(key: key);
  @override
  ContactFState createState() => ContactFState();
}

class ContactFState extends State<ContactF> {
  Future<void> _makePhoneCall(String phoneNumber) async {
    if (phoneNumber != '') {
      final url = Uri.parse('tel:$phoneNumber');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  Future<void> _makeWhatsapp(String phoneNumber) async {
    if (phoneNumber != '') {
      final url = Uri.parse('https://wa.me/$phoneNumber');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  Future<void> _makeEmail(String emailAddress) async {
    if (emailAddress != '') {
      final url = Uri.parse(
          'mailto:$emailAddress?subject=Contact between Faculty and Parents');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  Widget _buildPhotoWidget(String imageUrl) {
    if (imageUrl != '') {
      return ImageNetwork(
        image: imageUrl,
        height: 100,
        width: 100,
        fitAndroidIos: BoxFit.contain,
        fitWeb: BoxFitWeb.contain,
        onLoading: const CircularProgressIndicator(
          color: kPrimaryColor,
        ),
        onError: const Icon(
          Icons.error,
          color: red,
        ),
      );
    } else {
      return Stack(
        children: [
          Image.asset('assets/images/man.png',
              fit: BoxFit.contain, height: 100, width: 100),
        ],
      );
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
          title: const Text('Contact Faculty'),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Admin/$admin/faculty')
              .where('branch', isEqualTo: branch)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
            return ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              itemCount: storedocs.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  color: Colors.white,
                  borderOnForeground: true,
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        _buildPhotoWidget(storedocs[index]['photoUrl'] ?? ''),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('${storedocs[index]['name']}',
                                    style:
                                        const TextStyle(color: Colors.green)),
                                Text(
                                  'Mobile No. : ${storedocs[index]['mono']}',
                                  style: const TextStyle(
                                      color: Colors.orangeAccent),
                                ),
                                Text(
                                  'Email : ${storedocs[index]['email']}',
                                  style: const TextStyle(
                                      color: Colors.orangeAccent),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  child: Image.asset(
                                    'assets/images/whatsapp 24px.png',
                                  ),
                                  onPressed: () => _makeWhatsapp(
                                      storedocs[index]['mono'] ?? ''),
                                ),
                                const SizedBox(width: 5),
                                TextButton(
                                  child: const Icon(
                                    Icons.call,
                                    size: 24,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _makePhoneCall(
                                      storedocs[index]['mono'] ?? ''),
                                ),
                                const SizedBox(width: 5),
                                TextButton(
                                  child: const Icon(
                                    Icons.mail,
                                    size: 24,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _makeEmail(
                                      storedocs[index]['email'] ?? ''),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
            );
          },
        ),
      ),
    );
  }
}
