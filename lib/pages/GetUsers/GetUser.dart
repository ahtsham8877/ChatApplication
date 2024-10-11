import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatsListPage extends StatelessWidget {
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats List')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _userService.getAllChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No chats found.'));
          }

          final chats = snapshot.data!;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final chatId = chat['id']; // Replace with actual field names
              final chatTitle =
                  chat['title']; // Replace with actual field names

              return ListTile(
                title: Text(chatTitle),
                onTap: () {
                  // Handle tap, e.g., navigate to a chat detail page
                },
              );
            },
          );
        },
      ),
    );
  }
}

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getAllChats() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('chats').get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching chats: $e');
      return [];
    }
  }
}
