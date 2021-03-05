import 'package:cupertino_will_pop_scope/cupertino_will_pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sheeps_app/TeamProfileModifys/model/DummyForTeamProfileModify.dart';
import 'package:sheeps_app/config/AppConfig.dart';
import 'package:sheeps_app/config/GlobalAsset.dart';
import 'package:sheeps_app/config/ListForProfileModify.dart';
import 'package:sheeps_app/config/SheepsTextStyle.dart';
import 'package:sheeps_app/config/GlobalWidget.dart';

class SelectTeamArea extends StatefulWidget {
  SelectTeamArea({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _SelectTeamAreaState createState() => _SelectTeamAreaState();
}

class _SelectTeamAreaState extends State<SelectTeamArea> {
  TextEditingController editingController = TextEditingController();

  var items = List<String>();
  double sizeUnit = 1;
  
  String location;
  
  @override
  void initState() {
    items.addAll(AreaCategory);
    super.initState();
  }

  void filterSearchResults(String query) {

    List<String> dummySearchList = List<String>();
    dummySearchList.addAll(AreaAllCategory);

    if(query.isNotEmpty) {
      List<String> dummyListData = List<String>();
      dummySearchList.forEach((item) {

        if(item.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(AreaCategory);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ModelTeamProfile _ModifiedTeamProfile = Provider.of<ModelTeamProfile>(context);
    sizeUnit = SheepsTextStyle.sizeUnit(context).fontSize;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),//사용자 스케일팩터 무시
      child: Scaffold(
        backgroundColor: hexToColor("#FFFFFF"),
        appBar: SheepsAppBar(context, '지역 선택', isBackButton: false),
        body: ConditionalWillPopScope(
          shouldAddCallbacks: true,
          onWillPop: null,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return FlatButton(
                      onPressed: (){
                        if(!AreaCategory.contains(items[index])) {
                          _ModifiedTeamProfile.ChangeFlagForTeamArea(true);
                          _ModifiedTeamProfile.ChangeTeamAreaByAdd(false, location + ' ' + items[index]);
                          Navigator.pop(context);
                        }
                        else {
                          if(items[index] == '서울특별시') {
                            setState(() {
                              location = '서울특별시';
                              items.clear();
                              items.addAll(AreaSeoulCategory);
                            });
                          } else if(items[index] == '인천광역시') {
                            setState(() {
                              _ModifiedTeamProfile.ChangeTeamAreaByAdd(false,'');
                              location = '인천광역시';
                              items.clear();
                              items.addAll(AreaInCheonCategory);
                            });
                          } else if(items[index] == '경기도') {
                            setState(() {
                              _ModifiedTeamProfile.ChangeTeamAreaByAdd(false,'');
                              location = '경기도';
                              items.clear();
                              items.addAll(AreaGyongGiCategory);
                            });
                          } else if(items[index] == '강원도') {
                            setState(() {
                              _ModifiedTeamProfile.ChangeTeamAreaByAdd(false,'');
                              location = '강원도';
                              items.clear();
                              items.addAll(AreaKangWonCategory);
                            });
                          } else if(items[index] == '충청남도') {
                            setState(() {
                              _ModifiedTeamProfile.ChangeTeamAreaByAdd(false,'');
                              location = '충청남도';
                              items.clear();
                              items.addAll(AreaChungSouthCategory);
                            });
                          } else if(items[index] == '충청북도') {
                            setState(() {
                              _ModifiedTeamProfile.ChangeTeamAreaByAdd(false,'');
                              location = '충청북도';
                              items.clear();
                              items.addAll(AreaChungNorthCategory);
                            });
                          } else if(items[index] == '세종시') {
                            setState(() {
                              _ModifiedTeamProfile.ChangeTeamAreaByAdd(false,'');
                              location = '세종시';
                              items.clear();
                              items.addAll(AreaSejongCategory);
                            });
                          } else if(items[index] == '대전광역시') {
                            setState(() {
                              _ModifiedTeamProfile.ChangeTeamAreaByAdd(false,'');
                              location = '대전광역시';
                              items.clear();
                              items.addAll(AreaDaejeonCategory);
                            });
                          } else if(items[index] == '경상북도') {
                            setState(() {
                              _ModifiedTeamProfile.ChangeTeamAreaByAdd(false,'');
                              location = '경상북도';
                              items.clear();
                              items.addAll(AreaGyeongsangNorthCategory);
                            });
                          } else if(items[index] == '경상남도') {
                            setState(() {
                              _ModifiedTeamProfile.ChangeTeamAreaByAdd(false,'');
                              location = '경상남도';
                              items.clear();
                              items.addAll(AreaGyeongsangSouthCategory);
                            });
                          } else if(items[index] == '대구광역시') {
                            setState(() {
                              _ModifiedTeamProfile.ChangeTeamAreaByAdd(false,'');
                              location = '대구광역시';
                              items.clear();
                              items.addAll(AreaDaeguCategory);
                            });
                          } else if(items[index] == '부산광역시') {
                            setState(() {
                              _ModifiedTeamProfile.ChangeTeamAreaByAdd(false,'');
                              location = '부산광역시';
                              items.clear();
                              items.addAll(AreaBusanCategory);
                            });
                          } else if(items[index] == '전라북도') {
                            setState(() {
                              _ModifiedTeamProfile.ChangeTeamAreaByAdd(false,'');
                              location = '전라북도';
                              items.clear();
                              items.addAll(AreaJeonNorthCategory);
                            });
                          } else if(items[index] == '전라남도') {
                            setState(() {
                              _ModifiedTeamProfile.ChangeTeamAreaByAdd(false,'');
                              location = '전라남도';
                              items.clear();
                              items.addAll(AreaJeonSouthCategory);
                            });
                          } else if(items[index] == '광주광역시') {
                            setState(() {
                              _ModifiedTeamProfile.ChangeTeamAreaByAdd(false,'');
                              location = '광주광역시';
                              items.clear();
                              items.addAll(AreaGwangjuCategory);
                            });
                          } else if(items[index] == '울산광역시') {
                            setState(() {
                              _ModifiedTeamProfile.ChangeTeamAreaByAdd(false,'');
                              location = '울산광역시';
                              items.clear();
                              items.addAll(AreaUlsanCategory);
                            });
                          } else if(items[index] == '제주특별자치도') {
                            setState(() {
                              _ModifiedTeamProfile.ChangeTeamAreaByAdd(false,'');
                              location = '제주특별자치도';
                              items.clear();
                              items.addAll(AreaJejuCategory);
                            });
                          }
                        }
                      },
                      child: Container(
                        height: 48*sizeUnit,
                        child: Row(
                          children: [
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${items[index]}',
                                  style: SheepsTextStyle.b1(context),
                                )),
                            Expanded(child: SizedBox()),
                            SvgPicture.asset(
                              svgGreyNextIcon,
                              width: 16*sizeUnit,
                              height: 16*sizeUnit,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

