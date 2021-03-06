import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sheeps_app/chat/models/ChatGlobal.dart';
import 'package:sqflite/sqflite.dart';
import 'ChatRecvMessageModel.dart';

final String TableName = "ChatLogs";

class ChatDBHelper {

  ChatDBHelper._();

  static final ChatDBHelper _db = ChatDBHelper._();

  factory ChatDBHelper() => _db;

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'SheepsDB.db');

    return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          try{
            await db.execute("CREATE TABLE $TableName(chatId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, roomId INTEGER, roomName TEXT, userId INTEGER, message TEXT, date INTEGER, isImage INTEGER, isRead INTEGER, updatedAt TEXT)");
          }
          catch(e){
            debugPrint(e);
          }

        },
        onUpgrade: (db, oldVersion, newVersion){},
    );
  }

  Future<String> createData(ChatRecvMessageModel messageModel) async {
    final db = await database;

    String resUrl;
    String resMessage = messageModel.message;
    if(messageModel.isImage == 1){
      resUrl = await base64ToFileURL(messageModel.message);
      resMessage = messageModel.chatId.toString();
    }

    var res = await db.rawInsert("INSERT INTO $TableName(roomId, roomName, userId, message, date, isImage, isRead, updatedAt) VALUES(?,?,?,?,?,?,?,?)",
        [
          messageModel.roomId,
          messageModel.roomName,
          messageModel.from,
          resMessage,
          messageModel.date,
          messageModel.isImage,
          messageModel.isRead,
          messageModel.updatedAt
        ]
    );

    if(false == kReleaseMode){
      debugPrint("TABLE SIZE" + res.toString());
    }

    return resUrl;
  }

  Future<String> createImageData(ChatRecvMessageModel messageModel) async{
    final db = await database;

    final decodedBytes = base64Decode(messageModel.message);

    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    String name = DateFormat('yyyyMMddHHmmss').format(DateTime.now().toLocal());

    var file = File(documentsDirectory.path + '/' +  name + ".png");
    await file.writeAsBytes(decodedBytes);
    var fileUrl = file.path;

    print(fileUrl);

    var res = await db.rawInsert("INSERT INTO $TableName(roomId, roomName, userId, message, date, isImage, isRead,updatedAt) VALUES(?,?,?,?,?,?,?,?)",
        [
          messageModel.roomId,
          messageModel.roomName,
          messageModel.from,
          fileUrl,
          messageModel.date,
          messageModel.isImage,
          messageModel.isRead,
          messageModel.updatedAt
        ]
    );

    if(false == kReleaseMode){
      debugPrint("TABLE SIZE" + res.toString());
    }

    return fileUrl;
  }

  updateDate(int chatId, int isRead) async {
    final db = await database;

    var res = await db.rawUpdate('''
      UPDATE $TableName
      SET isRead = ?
      WHERE chatId = ?
      ''',
        [isRead, chatId]);

    print(res);
  }

  updateRoomData(String roomName, int isRead) async {
    final db = await database;

    var res = await db.rawUpdate('''
      UPDATE $TableName
      SET isRead = ?
      WHERE roomName = ?
      ''',
        [isRead, roomName]);
  }

  Future<List<ChatRecvMessageModel>> getRoomData(String roomName, {offset = 0}) async {
    final db = await database;

    var res = await db.query(TableName, where: 'roomName = ?', whereArgs: [roomName], orderBy: 'chatId DESC', limit: 20, offset: offset);
    List<ChatRecvMessageModel> list  = res.isNotEmpty ? res.map((c) => ChatRecvMessageModel(
      chatId: c['chatId'],
      roomId: c['roomId'],
      roomName: c['roomName'],
      from: c['userId'],
      message: c['message'],
      date: c['date'],
      isImage: c['isImage'],
      isRead: c['isRead'],
      updatedAt: c['updatedAt'],
      isContinue: true
    )).toList()
        : [];

    return list.reversed.toList();
  }

  getData(int id) async {
    final db = await database;
    var res = await db.rawQuery(
        'SELECT * FROM $TableName where roomId = ?', [id]);
    return res.isNotEmpty ?
    ChatRecvMessageModel(
      chatId: res.first['chatId'],
      roomId: res.first['roomId'],
      roomName: res.first['roomName'],
      from: res.first['userId'],
      message: res.first['message'],
      date: res.first['date'],
      isImage: res.first['isImage'],
      isRead: res.first['isRead'],
      updatedAt: res.first['updatedAt']
    )
        : null;
  }

  Future<List<ChatRecvMessageModel>> getAllData() async {
    final db = await database;
    var res = await db.rawQuery('SELECT * FRom $TableName');
    List<ChatRecvMessageModel> list  = res.isNotEmpty ? res.map((c) => ChatRecvMessageModel(
      chatId: c['chatId'],
      roomId: c['roomId'],
      roomName: c['roomName'],
      from: c['userId'],
      message: c['message'],
      date: c['date'],
      isImage: c['isImage'],
      isRead: c['isRead'],
      updatedAt: c['updatedAt']
    )).toList()
        : [];

    return list;
  }

  deleteData(int id) async{
    final db = await database;
    var res = db.rawDelete('DELETE FROM $TableName where roomId = ?', [id]);
    return res;
  }

  deleteAllDatas() async {
    final db = await database;
    db.rawDelete("DELETE from $TableName");
  }

  dropTable() async{
    final db = await database;
    db.execute("DROP TABLE IF EXISTS $TableName");
    await db.execute(
        "CREATE TABLE $TableName(chatId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, roomId INTEGER, roomName TEXT, userId INTEGER, message TEXT, date INTEGER, isImage INTEGER, isRead INTEGER, updatedAt TEXT)"
    );
  }
}