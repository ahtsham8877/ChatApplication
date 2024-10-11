import 'package:chat_app/Utilities/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String title;
  final String chatPartnerId;

  const ChatPage({
    super.key,
    required this.userId,
    required this.title,
    required this.chatPartnerId,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  late String currentUserId;
  late String chatId;

  @override
  void initState() {
    super.initState();
    currentUserId = widget.userId;
    chatId = _getChatId(widget.userId, widget.chatPartnerId);
    print("Chat ID: $chatId");

    // Scroll to the bottom when the page is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _getChatId(String user1, String user2) {
    List<String> users = [user1, user2]..sort();
    String chatId = '${users[0]}_${users[1]}';
    print("Generated Chat ID: $chatId"); // Debug print
    return chatId;
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await _firestore
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .add({
            'text': _messageController.text,
            'senderId': currentUserId,
            'receiverId': widget.chatPartnerId,
            'timestamp': Timestamp.now(),
          });
          print('Message sent to chat ID: $chatId');
          _messageController.clear();
          // Scroll to bottom after sending message
          Future.delayed(Duration(milliseconds: 100), () {
            _scrollToBottom();
          });
        } else {
          print('User is not authenticated');
        }
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    final DateFormat formatter = DateFormat('h:mm a');
    return formatter.format(dateTime);
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
          Column(
            children: [
              const SizedBox(
                height: 23,
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
                  Text(
                    widget.title,
                    style: TextStyle(
                        color: whiteColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                ],
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('chats')
                      .doc(chatId)
                      .collection('messages')
                      .orderBy('timestamp')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print('Error: ${snapshot.error}');
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var messages = snapshot.data!.docs;
                    print('Messages received: ${messages.length}');
                    if (messages.isEmpty) {
                      return const Center(child: Text('No messages found'));
                    }
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        var message = messages[index];
                        Timestamp timestamp = message['timestamp'];
                        String formattedTime = _formatTimestamp(timestamp);
                        bool isCurrentUserMessage =
                            message['senderId'] == currentUserId;

                        return Align(
                          alignment: isCurrentUserMessage
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: GestureDetector(
                            onLongPress: () => _showDeleteDialog(message.id),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isCurrentUserMessage
                                    ? Colors.blueAccent
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: isCurrentUserMessage
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message['text'],
                                    style: TextStyle(
                                      color: isCurrentUserMessage
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formattedTime,
                                    style: TextStyle(
                                      color: isCurrentUserMessage
                                          ? Colors.white70
                                          : Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(
                            color: Colors.white, // Input text color
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Enter your message...',
                            hintStyle: TextStyle(
                              color: Colors.white, // Hint text color
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blueAccent,
                                width: 1.0,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blueAccent,
                                width: 1.0,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blueAccent,
                                width: 1.0,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Center(
                        child: IconButton(
                          icon: const Icon(
                            Icons.send_rounded,
                          ),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String messageId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await _firestore
                    .collection('chats')
                    .doc(chatId)
                    .collection('messages')
                    .doc(messageId)
                    .delete();
                print('Message deleted');
              } catch (e) {
                print('Error deleting message: $e');
              }
            },
            child: const Text('Delete'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
