import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sheeps_app/Community/CommunityMainDetail.dart';
import 'package:sheeps_app/Community/models/Community.dart';
import 'package:sheeps_app/chat/ChatPage.dart';
import 'package:sheeps_app/chat/TeamChatPage.dart';
import 'package:sheeps_app/chat/models/ChatGlobal.dart';
import 'package:sheeps_app/chat/models/Room.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/network/ApiProvider.dart';
import 'package:sheeps_app/network/SocketProvider.dart';
import 'package:sheeps_app/notification/TotalNotificationPage.dart';
import 'package:sheeps_app/userdata/GlobalProfile.dart';
import 'package:vibration/vibration.dart';

class ReceivedNotification {
  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}

class LocalNotification{
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =  FlutterLocalNotificationsPlugin();
  BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();
  BehaviorSubject<String> selectNotificationSubject = BehaviorSubject<String>();
  String selectedNotificationPayload;

  NotificationDetails platformChannelSpecifics;
  bool hasCheck = false;

  Future<bool> init() async{
    if(hasCheck == true) return hasCheck;

    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {
          didReceiveLocalNotificationSubject.add(ReceivedNotification(
              id: id, title: title, body: body, payload: payload));
        });
    var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
          if (payload != null) {
            debugPrint('notification payload: $payload');
          }
          selectedNotificationPayload = payload;
          selectNotificationSubject.add(payload);
        });

    _configureSelectNotificationSubject();

    hasCheck = true;
    return hasCheck;
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {
      switch(globalNotificationType){
        case "NOTIFICATION":
          {
            Navigator.push(
                navigatorKey.currentContext,
                // 기본 파라미터, SecondRoute로 전달
                MaterialPageRoute(
                    builder: (context) =>
                        TotalNotificationPage()));
          }
          break;
        case "CHATROOM":
          {
            var roomName = payload;

            ChatGlobal.socket.setRoomStatus(ROOM_STATUS_CHAT);

            for(int i = 0; i < ChatGlobal.roomInfoList.length; ++i){
              if(roomName == ChatGlobal.roomInfoList[i].roomName){

                if(ChatGlobal.currentRoomIndex != i){
                  RoomInfo roomInfo = ChatGlobal.roomInfoList[i];

                  if(roomInfo.isPersonal){
                    Navigator.push(
                        navigatorKey.currentContext,
                        MaterialPageRoute(
                            builder: (context) => new ChatPage(
                              roomName: roomInfo.roomName,
                              chatUser: GlobalProfile.getUserByUserID(roomInfo.chatUserIDList[0]),))).then((value){
                      ChatGlobal.socket.setPrevStatus();
                    });
                  }else{
                    Navigator.push(
                        navigatorKey.currentContext,
                        MaterialPageRoute(
                            builder: (context) => new TeamChatPage(
                                roomName: roomName,
                                titleName: roomInfo.name,
                                chatUserList: GlobalProfile.getUserListByUserIDList(roomInfo.chatUserIDList)))).then((value){
                      ChatGlobal.socket.setPrevStatus();
                    });
                  }
                  break;
                }
              }
            }
          }
          break;
        case "COMMUNITY":
          {
            var resCommunity = await ApiProvider().post('/CommunityPost/SelectID', jsonEncode({
              "id" : int.parse(payload)
            }));

            Community community = Community.fromJson(resCommunity);

            var tmp = await ApiProvider().post('/CommunityPost/PostSelect',jsonEncode({
              "id" : int.parse(payload)
            }));

            if (tmp == null) return;

            GlobalProfile.communityReply = new List<CommunityReply>();
            for (int i = 0; i < tmp.length; i++) {
              Map<String, dynamic> data = tmp[i];
              CommunityReply tmpReply = CommunityReply.fromJson(data);
              GlobalProfile.communityReply.add(tmpReply);
            }

            Navigator.push(
                navigatorKey.currentContext, // 기본 파라미터, SecondRoute로 전달
                MaterialPageRoute(
                    builder: (context) =>
                        CommunityMainDetail(community)));
          }
          break;
      }
    });
  }

  Future<bool> showNoti({String title = "welcome", String des = "JamesFlutter", String payload = ''}) async{
    if(false == await Permission.notification.isGranted){
      return Future.value(false);
    }

    if(!hasCheck) await init();
    if(Platform.isIOS){
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    await flutterLocalNotificationsPlugin.show(0, title, des, platformChannelSpecifics, payload: payload);
    if(await Vibration.hasVibrator()){
      await Vibration.vibrate();
    }
    return true;
  }

  showTime() async{
    if(!hasCheck) await init();
    var scheduledNotificationDateTime =
    DateTime.now().add(Duration(seconds: 5));
    var androidPlatformChannelSpecifics =
    AndroidNotificationDetails('your other channel id',
        'your other channel name', 'your other channel description');
    var iOSPlatformChannelSpecifics =
    IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        0,
        'scheduled title',
        'scheduled body',
        scheduledNotificationDateTime,
        platformChannelSpecifics);
  }

  showInterval() async{
    if(!hasCheck) await init();
    var androidPlatformChannelSpecifics = AndroidNotificationDetails('repeating channel id','repeating channel name', 'repeating description');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.periodicallyShow(0, 'repeating title','repeating body', RepeatInterval.EveryMinute, platformChannelSpecifics);
  }

  everyDayTime() async{
    if(!hasCheck) await init();
    var time = Time(10, 0, 0);
    var androidPlatformChannelSpecifics =
    AndroidNotificationDetails('repeatDailyAtTime channel id',
        'repeatDailyAtTime channel name', 'repeatDailyAtTime description');
    var iOSPlatformChannelSpecifics =
    IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        0,
        'show daily title',
        'Daily notification shown at approximately ${time.hour}:${time.minute}:${time.second}',
        time,
        platformChannelSpecifics);
  }
  weeklyTargetDayTimeInterval() async{
    if(!hasCheck) await init();
    var time = Time(10, 0, 0);
    var androidPlatformChannelSpecifics =
    AndroidNotificationDetails('show weekly channel id',
        'show weekly channel name', 'show weekly description');
    var iOSPlatformChannelSpecifics =
    IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
        0,
        'show weekly title',
        'Weekly notification shown on Monday at approximately ${time.hour}:${time.minute}:${time.second}',
        Day.Monday,
        time,
        platformChannelSpecifics);
  }

  Future<void> targetNotiCancel({int targetIndex}) async => await flutterLocalNotificationsPlugin.cancel(targetIndex);
  Future<void> allNotiCancel() async => await flutterLocalNotificationsPlugin.cancelAll();

}