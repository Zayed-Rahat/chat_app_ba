import 'package:flutter/material.dart';
import '../api/apis.dart';
import '../helpers/my_date_util.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../screens/chat_screen.dart';
import 'dialogs/profile_dialogs.dart';
import 'profile_image.dart';
import '../helpers/dialogs.dart';

// card to represent a single user in home screen
class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  final VoidCallback? onLongPress;

  const ChatUserCard({super.key, required this.user, this.onLongPress});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  // last message info (if null --> no message)
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      elevation: 0.5,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        onTap: () {
          // navigate to chat screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)),
          );
        },
        onLongPress: () {
          _showUserOptions(context, widget.user);
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            if (list.isNotEmpty) _message = list[0];

            return ListTile(
              // user profile picture
              leading: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => ProfileDialog(user: widget.user),
                  );
                },
                child: ProfileImage(
                  size: mq.height * .06,
                  url: widget.user.image,
                ),
              ),

              // user name
              title: Text(widget.user.name),

              // last message or about
              subtitle: Text(
                _message != null
                    ? _message!.type == Type.image
                          ? '📷 image'
                          : _message!.msg
                    : widget.user.about,
                maxLines: 1,
              ),

              // last message time or unread indicator
              trailing: SizedBox(
                width: 40,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_message != null) ...[
                      if (_message!.read.isEmpty &&
                          _message!.fromId != APIs.user.uid)
                        const SizedBox(
                          width: 15,
                          height: 15,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 0, 230, 119),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                          ),
                        )
                      else
                        Text(
                          MyDateUtil.getLastMessageTime(
                            context: context,
                            time: _message!.sent,
                          ),
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                    ],
                    // IconButton(
                    //   padding: EdgeInsets.zero,
                    //   constraints: const BoxConstraints(),
                    //   icon: const Icon(Icons.more_vert, size: 15),
                    //   onPressed: () => _showUserOptions(context, widget.user),
                    // ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showUserOptions(BuildContext context, ChatUser user) {
    // Store the outer context
    final outerContext = context;

    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) {
        // renamed from _ to bottomSheetContext
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete All Chats'),
                  onTap: () async {
                    // Close bottom sheet using its context
                    Navigator.pop(bottomSheetContext);

                    await APIs.deleteAllChatsWith(user);

                    // Use outer context for snackbar and check if mounted
                    if (mounted) {
                      Dialogs.showSnackbar(
                        outerContext,
                        'Chats deleted with ${user.name}',
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
