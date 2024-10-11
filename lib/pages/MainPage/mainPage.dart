import 'package:chat_app/Utilities/colors.dart';
import 'package:chat_app/pages/Auth/login_page.dart';
import 'package:chat_app/pages/ChatSc/chat_sc.dart';
import 'package:chat_app/pages/GetUsers/NEwChat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Mainpage extends StatefulWidget {
  Mainpage({
    super.key,
    required this.userId,
    required this.email,
  });

  final String userId;
  final String email;

  @override
  _MainpageState createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  final _firestore = FirebaseFirestore.instance;
  List<Map<String, String>> users = [];

  @override
  void initState() {
    super.initState();
    _fetchChatIds();
  }

  Future<void> _fetchChatIds() async {
    try {
      final QuerySnapshot querySnapshot =
          await _firestore.collection('users').get();

      final usersList = querySnapshot.docs.map((doc) {
        return {
          'name': doc['name'] as String,
          'id': doc.id,
        };
      }).toList();

      final currentUserIndex =
          usersList.indexWhere((user) => user['id'] == widget.userId);

      if (currentUserIndex != -1) {
        final currentUser = usersList.removeAt(currentUserIndex);
        usersList.insert(0, currentUser);
      }

      print("Rearranged Users list $usersList");

      setState(() {
        users = usersList;
      });
    } catch (e) {
      print('Error fetching chat IDs: $e');
    }
  }

  String _getInitial(String name) {
    if (name.isEmpty) return '';
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/fs.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: const Color.fromARGB(80, 0, 0, 0),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: whiteColor,
                        )),
                    const Center(
                        child: Text(
                      "Chats",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    )),
                    CircleAvatar(
                      backgroundColor: const Color.fromARGB(82, 190, 218, 255),
                      child: IconButton(
                          onPressed: () {
                            Get.defaultDialog(
                              title: "Logout",
                              content: Column(
                                children: [
                                  Text(
                                    widget.email,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                          onPressed: () {
                                            Get.back();
                                          },
                                          child: const Text("Cancel")),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      TextButton(
                                          onPressed: () {
                                            Get.offAll(LoginPage());
                                          },
                                          child: Text(
                                            "Logout",
                                            style: TextStyle(color: red),
                                          )),
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: Colors.red,
                          )),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final isCurrentUser = user['id'] == widget.userId;

                      return Dismissible(
                        key: Key(user['id']!),
                        background: Container(
                          color: Colors.red,
                          child: const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 16.0),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                          ),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          child: const Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: EdgeInsets.only(right: 16.0),
                              child: Icon(Icons.delete,
                                  color: Color.fromARGB(255, 240, 240, 240)),
                            ),
                          ),
                        ),
                        onDismissed: (direction) {
                          // Handle the deletion
                          _deleteUser(user['id']!);
                        },
                        child: Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ? buttonColor.withOpacity(0.5)
                                : const Color.fromARGB(82, 190, 240, 255),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                          ),
                          child: ListTile(
                            onTap: () {
                              Get.to(ChatPage(
                                title: user['name']!,
                                chatPartnerId: user['id']!,
                                userId: widget.userId,
                              ));
                            },
                            leading: SizedBox(
                              child: CircleAvatar(
                                backgroundColor:
                                    const Color.fromARGB(255, 109, 163, 104),
                                child: Text(
                                  _getInitial(user['name']!),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            title: Text(
                              isCurrentUser ? 'Me' : user['name']!,
                              style: TextStyle(color: whiteColor),
                            ),
                            // subtitle: Text(user['id']!),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();

      setState(() {
        users.removeWhere((user) => user['id'] == userId);
      });
    } catch (e) {
      print('Error deleting user: $e');
    }
  }
}
