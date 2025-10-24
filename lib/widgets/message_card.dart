import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';

import '../api/apis.dart';
import '../helpers/dialogs.dart';
import '../helpers/my_date_util.dart';
import '../main.dart';
import '../models/message.dart';

// For showing single message details
class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  bool _isHovering = false;

  // Check if running on Windows or Web
  bool get isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  // Responsive sizing
  double get messagePadding => isDesktop ? 12.0 : mq.width * .04;
  double get messageMarginHorizontal => isDesktop ? 16.0 : mq.width * .04;
  double get messageMarginVertical => isDesktop ? 8.0 : mq.height * .01;
  double get maxMessageWidth => isDesktop ? 600.0 : mq.width * 0.75;
  double get fontSize => isDesktop ? 16.0 : 15.0;
  double get timeStampFontSize => isDesktop ? 13.0 : 13.0;
  double get iconSize => isDesktop ? 24.0 : 20.0;

  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: InkWell(
        onLongPress: isDesktop ? null : () => _showBottomSheet(isMe),
        onSecondaryTap: isDesktop ? () => _showContextMenu(isMe) : null,
        child: Stack(
          children: [
            isMe ? _greenMessage() : _blueMessage(),

            // Show quick actions on hover (Windows only)
            if (isDesktop && _isHovering && isMe)
              Positioned(
                left: isMe ? null : messageMarginHorizontal,
                right: isMe
                    ? messageMarginHorizontal + maxMessageWidth + 8
                    : null,
                top: messageMarginVertical,
                child: _QuickActionsBar(
                  message: widget.message,
                  onEdit: widget.message.type == Type.text
                      ? () => _showMessageUpdateDialog(context)
                      : null,
                  onDelete: () => _showDeleteConfirmation(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Sender or another user message
  Widget _blueMessage() {
    // Update last read message if sender and receiver are different
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Message content
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxMessageWidth),
            child: Container(
              padding: EdgeInsets.all(
                widget.message.type == Type.image
                    ? (isDesktop ? 8.0 : mq.width * .03)
                    : messagePadding,
              ),
              margin: EdgeInsets.symmetric(
                horizontal: messageMarginHorizontal,
                vertical: messageMarginVertical,
              ),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 221, 245, 255),
                border: Border.all(color: Colors.lightBlue),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: widget.message.type == Type.text
                  ? SelectableText(
                      widget.message.msg,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: Colors.black87,
                      ),
                    )
                  : _buildImageWidget(),
            ),
          ),
        ),

        // Message time
        Padding(
          padding: EdgeInsets.only(
            right: isDesktop ? 16.0 : mq.width * .04,
            bottom: messageMarginVertical,
          ),
          child: Text(
            MyDateUtil.getFormattedTime(
              context: context,
              time: widget.message.sent,
            ),
            style: TextStyle(
              fontSize: timeStampFontSize,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  // Our or user message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Message time
        Padding(
          padding: EdgeInsets.only(
            left: isDesktop ? 16.0 : mq.width * .04,
            bottom: messageMarginVertical,
          ),
          child: Row(
            children: [
              // Double tick blue icon for message read
              if (widget.message.read.isNotEmpty)
                Icon(
                  Icons.done_all_rounded,
                  color: const Color.fromARGB(255, 90, 42, 146),
                  size: iconSize,
                ),

              const SizedBox(width: 4),

              // Sent time
              Text(
                MyDateUtil.getFormattedTime(
                  context: context,
                  time: widget.message.sent,
                ),
                style: TextStyle(
                  fontSize: timeStampFontSize,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),

        // Message content
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxMessageWidth),
            child: Container(
              padding: EdgeInsets.all(
                widget.message.type == Type.image
                    ? (isDesktop ? 8.0 : mq.width * .03)
                    : messagePadding,
              ),
              margin: EdgeInsets.symmetric(
                horizontal: messageMarginHorizontal,
                vertical: messageMarginVertical,
              ),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 218, 255, 176),
                border: Border.all(color: Colors.lightGreen),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                ),
              ),
              child: widget.message.type == Type.text
                  ? SelectableText(
                      widget.message.msg,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: Colors.black87,
                      ),
                    )
                  : _buildImageWidget(),
            ),
          ),
        ),
      ],
    );
  }

  // Build image widget with responsive sizing
  Widget _buildImageWidget() {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(15)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 400 : mq.width * 0.6,
          maxHeight: isDesktop ? 400 : mq.height * 0.4,
        ),
        child: CachedNetworkImage(
          imageUrl: widget.message.msg,
          fit: BoxFit.contain,
          placeholder: (context, url) => Container(
            width: isDesktop ? 200 : mq.width * 0.4,
            height: isDesktop ? 200 : mq.width * 0.4,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          errorWidget: (context, url, error) =>
              const Icon(Icons.image, size: 70),
        ),
      ),
    );
  }

  // Context menu for Windows (right-click)
  void _showContextMenu(bool isMe) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset position = button.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    );

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + button.size.width,
        position.dy + button.size.height,
      ),
      items: _buildContextMenuItems(isMe),
    );
  }

  // Build context menu items
  List<PopupMenuEntry<String>> _buildContextMenuItems(bool isMe) {
    List<PopupMenuEntry<String>> items = [];

    if (widget.message.type == Type.text) {
      items.add(
        PopupMenuItem(
          value: 'copy',
          child: Row(
            children: [
              const Icon(Icons.copy_all_rounded, color: Colors.blue, size: 20),
              const SizedBox(width: 12),
              Text('Copy Text', style: TextStyle(fontSize: fontSize)),
            ],
          ),
        ),
      );
    } else {
      items.add(
        PopupMenuItem(
          value: 'save',
          child: Row(
            children: [
              const Icon(Icons.download_rounded, color: Colors.blue, size: 20),
              const SizedBox(width: 12),
              Text('Save Image', style: TextStyle(fontSize: fontSize)),
            ],
          ),
        ),
      );
    }

    if (isMe && widget.message.type == Type.text) {
      items.add(
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              const Icon(Icons.edit, color: Colors.blue, size: 20),
              const SizedBox(width: 12),
              Text('Edit Message', style: TextStyle(fontSize: fontSize)),
            ],
          ),
        ),
      );
    }

    if (isMe) {
      items.add(
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete_forever, color: Colors.red, size: 20),
              const SizedBox(width: 12),
              Text('Delete Message', style: TextStyle(fontSize: fontSize)),
            ],
          ),
        ),
      );
    }

    items.add(const PopupMenuDivider());

    items.add(
      PopupMenuItem(
        enabled: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sent: ${MyDateUtil.getMessageTime(time: widget.message.sent)}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              widget.message.read.isEmpty
                  ? 'Not seen yet'
                  : 'Read: ${MyDateUtil.getMessageTime(time: widget.message.read)}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );

    return items;
  }

  // Copy text to clipboard
  Future<void> _copyText() async {
    await Clipboard.setData(ClipboardData(text: widget.message.msg));
    if (mounted) {
      Dialogs.showSnackbar(context, 'Text Copied!');
    }
  }

  // Save image to gallery
  Future<void> _saveImage() async {
    try {
      log('Image Url: ${widget.message.msg}');
      final success = await GallerySaver.saveImage(
        widget.message.msg,
        albumName: 'Chat AB',
      );
      if (mounted && success != null && success) {
        Dialogs.showSnackbar(context, 'Image Successfully Saved!');
      }
    } catch (e) {
      log('ErrorWhileSavingImg: $e');
      if (mounted) {
        Dialogs.showSnackbar(context, 'Failed to save image');
      }
    }
  }

  // Show delete confirmation
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Message?'),
        content: const Text('This message will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await APIs.deleteMessage(widget.message);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Bottom sheet for mobile (modifying message details)
  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: [
            // Black divider
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(
                vertical: mq.height * .015,
                horizontal: mq.width * .4,
              ),
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),

            widget.message.type == Type.text
                ? _OptionItem(
                    icon: const Icon(
                      Icons.copy_all_rounded,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: 'Copy Text',
                    onTap: (ctx) async {
                      Navigator.pop(ctx);
                      await _copyText();
                    },
                  )
                : _OptionItem(
                    icon: const Icon(
                      Icons.download_rounded,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: 'Save Image',
                    onTap: (ctx) async {
                      Navigator.pop(ctx);
                      await _saveImage();
                    },
                  ),

            if (isMe)
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),

            if (widget.message.type == Type.text && isMe)
              _OptionItem(
                icon: const Icon(Icons.edit, color: Colors.blue, size: 26),
                name: 'Edit Message',
                onTap: (ctx) {
                  Navigator.pop(ctx);
                  _showMessageUpdateDialog(context);
                },
              ),

            if (isMe)
              _OptionItem(
                icon: const Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                  size: 26,
                ),
                name: 'Delete Message',
                onTap: (ctx) async {
                  Navigator.pop(ctx);
                  await APIs.deleteMessage(widget.message);
                },
              ),

            Divider(
              color: Colors.black54,
              endIndent: mq.width * .04,
              indent: mq.width * .04,
            ),

            _OptionItem(
              icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
              name:
                  'Sent At: ${MyDateUtil.getMessageTime(time: widget.message.sent)}',
              onTap: (_) {},
            ),

            _OptionItem(
              icon: const Icon(Icons.remove_red_eye, color: Colors.green),
              name: widget.message.read.isEmpty
                  ? 'Read At: Not seen yet'
                  : 'Read At: ${MyDateUtil.getMessageTime(time: widget.message.read)}',
              onTap: (_) {},
            ),
          ],
        );
      },
    );
  }

  // Dialog for updating message content
  void _showMessageUpdateDialog(final BuildContext ctx) {
    String updatedMsg = widget.message.msg;

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        contentPadding: const EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: 10,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        title: const Row(
          children: [
            Icon(Icons.message, color: Colors.blue, size: 28),
            Text(' Update Message'),
          ],
        ),
        content: TextFormField(
          initialValue: updatedMsg,
          maxLines: null,
          autofocus: true,
          onChanged: (value) => updatedMsg = value,
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              APIs.updateMessage(widget.message, updatedMsg);
              Navigator.pop(ctx);
            },
            child: const Text('Update', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

// Quick actions bar for Windows (hover)
class _QuickActionsBar extends StatelessWidget {
  final Message message;
  final VoidCallback? onEdit;
  final VoidCallback onDelete;

  const _QuickActionsBar({
    required this.message,
    this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              tooltip: 'Edit',
              onPressed: onEdit,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
            tooltip: 'Delete',
            onPressed: onDelete,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

// Custom options card (for mobile bottom sheet)
class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final Function(BuildContext) onTap;

  const _OptionItem({
    required this.icon,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(context),
      child: Padding(
        padding: EdgeInsets.only(
          left: mq.width * .05,
          top: mq.height * .015,
          bottom: mq.height * .015,
        ),
        child: Row(
          children: [
            icon,
            Flexible(
              child: Text(
                '    $name',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
