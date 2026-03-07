// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatHiveModelAdapter extends TypeAdapter<ChatHiveModel> {
  @override
  final int typeId = 6;

  @override
  ChatHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatHiveModel(
      messageId: fields[0] as String,
      conversationId: fields[1] as String,
      senderId: fields[2] as String,
      senderName: fields[3] as String,
      senderProfilePicture: fields[4] as String?,
      content: fields[5] as String,
      createdAt: fields[6] as DateTime,
      editedAt: fields[7] as DateTime?,
      isRead: fields[8] as bool,
      imageUrls: (fields[9] as List?)?.cast<String>(),
      replyToMessageId: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatHiveModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.messageId)
      ..writeByte(1)
      ..write(obj.conversationId)
      ..writeByte(2)
      ..write(obj.senderId)
      ..writeByte(3)
      ..write(obj.senderName)
      ..writeByte(4)
      ..write(obj.senderProfilePicture)
      ..writeByte(5)
      ..write(obj.content)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.editedAt)
      ..writeByte(8)
      ..write(obj.isRead)
      ..writeByte(9)
      ..write(obj.imageUrls)
      ..writeByte(10)
      ..write(obj.replyToMessageId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConversationHiveModelAdapter extends TypeAdapter<ConversationHiveModel> {
  @override
  final int typeId = 7;

  @override
  ConversationHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversationHiveModel(
      conversationId: fields[0] as String,
      name: fields[1] as String?,
      participantIds: (fields[2] as List).cast<String>(),
      type: fields[3] as String,
      lastMessage: fields[4] as String?,
      unreadCount: fields[5] as int,
      groupProfilePicture: fields[6] as String?,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
      lastMessageAt: fields[9] as DateTime?,
      otherUserProfilePicture: fields[10] as String?,
      otherUserName: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ConversationHiveModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.conversationId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.participantIds)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.lastMessage)
      ..writeByte(5)
      ..write(obj.unreadCount)
      ..writeByte(6)
      ..write(obj.groupProfilePicture)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.lastMessageAt)
      ..writeByte(10)
      ..write(obj.otherUserProfilePicture)
      ..writeByte(11)
      ..write(obj.otherUserName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
