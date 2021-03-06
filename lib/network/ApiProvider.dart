import 'package:flutter/foundation.dart';
import 'package:sheeps_app/network/CustomException.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:sheeps_app/userdata/GlobalProfile.dart';

class Response<T> {
  Status status;
  T data;
  String message;

  Response.loading(this.message) : status = Status.LOADING;
  Response.completed(this.data) : status = Status.COMPLETED;
  Response.error(this.message) : status = Status.ERROR;

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $data";
  }
}

enum Status { LOADING, COMPLETED, ERROR }

class ApiProvider {
  final String _baseUrl = "http://121.172.129.206:"; //서버 붙는 위치
  final String port = kReleaseMode == true ? "20001" : "20000";                       //기본 포트 50004~50007 LoadBalencer
  final String imgPort = kReleaseMode == true ? "50008" : "50104";                    //이미지 포트
  final String chatPort = kReleaseMode == true ? "50009" : "50105";                   //채팅 포트
  //final String _baseUrl = "http://121.172.129.206:50000"; //서버 붙는 위치
  String get getUrl => _baseUrl + port;
  String get getImgUrl => _baseUrl + imgPort;
  String get getChatUrl => _baseUrl + chatPort;

  //get
  Future<dynamic> get(String url) async {
    var responseJson;

    try {
      final response = await http.get(_baseUrl + port + url,
      headers: {
        'Content-Type' : 'application/json',
        'user' : GlobalProfile.loggedInUser == null ? 'sheepsToken' : GlobalProfile.loggedInUser.userID.toString(),
        'accessToken' : GlobalProfile.accessToken
      },);

      if(response.body == "" || response.body == null) return null;

      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException('인터넷 접속이 원활하지 않습니다.');
    }
    return responseJson;
  }

  //post
  Future<dynamic> post(String url, dynamic data, {bool isChat = false}) async{
    var responseJson;

    String tarPort = false == isChat ? port : chatPort;

    try {
      final response = await http.post(_baseUrl + tarPort + url,
        headers: {
          'Content-Type' : 'application/json',
          'user' : GlobalProfile.loggedInUser == null ? 'sheepsToken' : GlobalProfile.loggedInUser.userID.toString(),
          'accessToken' : GlobalProfile.accessToken
        },
        body: data,
        encoding: Encoding.getByName('utf-8'));

      if(response.body == "" || response.body == null) return null;

      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException('인터넷 접속이 원활하지 않습니다.');
    }
    return responseJson;
  }

  dynamic _response(http.Response response) {
      switch (response.statusCode) {
        case 200:
          var responseJson = json.decode(response.body.toString());
          if(!kReleaseMode) print(responseJson);
          return responseJson;
        case 400:
          //throw BadRequestException(response.body.toString());
          BadRequestException(response.body.toString());
          return null;
        case 401: //토큰 정보 실패
          BadRequestException(response.body.toString());
          return null;
        case 403:
          //throw UnauthorisedException(response.body.toString());
          BadRequestException(response.body.toString());
          return null;
        case 404: //토큰 정보 실패
          BadRequestException(response.body.toString());
          return null;
        case 500:
          return null;
        default:
        //throw FetchDataException('Error occured while Communication with Server with StatusCode : ${response.statusCode}');
          FetchDataException('Error occured while Communication with Server with StatusCode : ${response.statusCode}');
          return null;
    }
  }
}