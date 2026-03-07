import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tripmates/app/theme/app_colors.dart';
import 'package:tripmates/core/services/media/media_upload_service.dart';

typedef OnSendMessage =
    void Function(
      String content, {
      List<String>? imageUrls,
      String? replyToMessageId,
    });

typedef OnTyping = void Function(bool isTyping);

class MessageInputField extends ConsumerStatefulWidget {
  final String conversationId;
  final OnSendMessage onSendMessage;
  final OnTyping onTyping;

  const MessageInputField({
    super.key,
    required this.conversationId,
    required this.onSendMessage,
    required this.onTyping,
  });

  @override
  ConsumerState<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends ConsumerState<MessageInputField> {
  late TextEditingController _messageController;
  final List<File> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isComposing = false;
  bool _isTyping = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _messageController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final isComposing = _messageController.text.isNotEmpty;
    setState(() {
      _isComposing = isComposing;
    });

    // Send typing indicator
    if (isComposing && !_isTyping) {
      _isTyping = true;
      widget.onTyping(true);
    } else if (!isComposing && _isTyping) {
      _isTyping = false;
      widget.onTyping(false);
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty && _selectedImages.isEmpty) return;
    if (_isUploading) return;

    List<String>? imageUrls;
    if (_selectedImages.isNotEmpty) {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      final mediaUploadService = ref.read(mediaUploadServiceProvider);
      final total = _selectedImages.length;
      final uploadedUrls = <String>[];

      for (var i = 0; i < _selectedImages.length; i++) {
        final result = await mediaUploadService.uploadImage(_selectedImages[i]);

        final url = result.fold<String?>((failure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(failure.message)));
          return null;
        }, (url) => url);

        if (url == null) {
          setState(() {
            _isUploading = false;
          });
          return;
        }

        uploadedUrls.add(url);
        setState(() {
          _uploadProgress = (i + 1) / total;
        });
      }

      imageUrls = uploadedUrls;
      setState(() {
        _isUploading = false;
      });
    }

    widget.onSendMessage(message, imageUrls: imageUrls);

    _messageController.clear();
    _selectedImages.clear();
    _isTyping = false;
    setState(() {
      _isComposing = false;
      _uploadProgress = 0.0;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isUploading)
            LinearProgressIndicator(
              value: _uploadProgress == 0.0 ? null : _uploadProgress,
              minHeight: 2,
              color: AppColors.primary,
              backgroundColor: Colors.grey[200],
            ),
          if (_selectedImages.isNotEmpty) _buildImagePreview(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: _buildTextField()),
                SizedBox(width: 8),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 100,
      padding: EdgeInsets.all(8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImages[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedImages.removeAt(index);
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: _messageController,
        maxLines: null,
        minLines: 1,
        textInputAction: TextInputAction.send,
        onSubmitted: (_) {
          if (_isComposing) {
            _sendMessage();
          }
        },
        decoration: InputDecoration(
          hintText: 'Type a message...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_isComposing) ...[
            IconButton(
              icon: Icon(Icons.add_a_photo, color: AppColors.primary),
              onPressed: _isUploading ? null : _onPickImage,
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.emoji_emotions, color: AppColors.primary),
              onPressed: _isUploading ? null : _showEmojiPicker,
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ] else
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.send, color: Colors.white),
                onPressed: _isUploading ? null : _sendMessage,
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _onPickImage() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          // Limit to 5 images max
          final remainingSlots = 5 - _selectedImages.length;
          final filesToAdd = pickedFiles
              .take(remainingSlots)
              .map((xFile) => File(xFile.path))
              .toList();
          _selectedImages.addAll(filesToAdd);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick images: $e')));
      }
    }
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 300,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Emoji Picker',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Divider(),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_emotions, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Emoji picker requires emoji_picker_flutter package',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add this to integrate: 😀 😃 😄 😁 😆 😅 😂 🤣',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
