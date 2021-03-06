import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';

class AppVersionPage extends StatefulWidget {
  PackageInfo packageInfo;

  AppVersionPage({Key key, @required this.packageInfo}) : super(key: key);

  @override
  _AppVersionPageState createState() => _AppVersionPageState();
}

class _AppVersionPageState extends State<AppVersionPage> {
  double sizeUnit = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        //사용자 스케일팩터 무시
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Scaffold(
              appBar: SheepsAppBar(context, '앱 버전'),
              body: Container(
                color: Color(0xFFF8F8F8),
                child: Column(
                  children: [
                    SheepsSimpleListItemBox(
                      context,
                      Row(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '앱 이름',
                              style: SheepsTextStyle.b1(context),
                            ),
                          ),
                          Expanded(child: SizedBox()),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.packageInfo.appName,
                              style: SheepsTextStyle.b2(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 1 * sizeUnit),
                    SheepsSimpleListItemBox(
                      context,
                      Row(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '패키지 이름',
                              style: SheepsTextStyle.b1(context),
                            ),
                          ),
                          Expanded(child: SizedBox()),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.packageInfo.packageName,
                              style: SheepsTextStyle.b2(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 1 * sizeUnit),
                    SheepsSimpleListItemBox(
                      context,
                      Row(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '버전 정보',
                              style: SheepsTextStyle.b1(context),
                            ),
                          ),
                          Expanded(child: SizedBox()),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.packageInfo.version,
                              style: SheepsTextStyle.b2(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 1 * sizeUnit),
                    SheepsSimpleListItemBox(
                      context,
                      Row(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '빌드 넘버',
                              style: SheepsTextStyle.b1(context),
                            ),
                          ),
                          Expanded(child: SizedBox()),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.packageInfo.buildNumber,
                              style: SheepsTextStyle.b2(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
