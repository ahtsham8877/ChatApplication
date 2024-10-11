// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class ChatPage extends StatefulWidget {
//   final String userId;
//   final String chatPartnerId;

//   ChatPage({required this.userId, required this.chatPartnerId});

//   @override
//   _ChatPageState createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final _messageController = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   void _sendMessage() async {
//     if (_messageController.text.trim().isNotEmpty) {
//       try {
//         await _firestore.collection('chats').add({
//           'senderId': widget.userId,
//           'receiverId': widget.chatPartnerId,
//           'message': _messageController.text.trim(),
//           'timestamp': FieldValue.serverTimestamp(),
//         });
//         _messageController.clear();
//       } catch (e) {
//         Get.snackbar("Error", "Failed to send message: $e");
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Chat with ${widget.chatPartnerId}")),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _firestore
//                   .collection('chats')
//                   .where('senderId',
//                       whereIn: [widget.userId, widget.chatPartnerId])
//                   .where('receiverId',
//                       whereIn: [widget.userId, widget.chatPartnerId])
//                   .orderBy('timestamp', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }

//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return const Center(child: Text('No messages yet.'));
//                 }

//                 final messages = snapshot.data!.docs;
//                 return ListView.builder(
//                   reverse: true,
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final message = messages[index];
//                     final timestamp = message['timestamp']?.toDate();
//                     final formattedTimestamp = timestamp != null
//                         ? '${timestamp.toLocal()}'
//                         : 'No timestamp';
//                     return ListTile(
//                       title: Text(message['message']),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Sent by: ${message['senderId']} at $formattedTimestamp',
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                           Text(
//                             'Sent to: ${message['receiverId']} at $formattedTimestamp',
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: const InputDecoration(
//                       hintText: 'Enter your message',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
