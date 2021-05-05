import 'dart:io';
//import 'dart:html';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quantify_app/loading.dart';
import 'package:quantify_app/models/mealData.dart';
import 'package:quantify_app/models/training.dart';
import 'package:quantify_app/models/userClass.dart';
import 'package:quantify_app/screens/ActivityFormScreen.dart';
import 'package:quantify_app/screens/addMealScreen.dart';
import 'package:quantify_app/screens/homeSkeleton.dart';
import 'package:quantify_app/services/database.dart';
//import 'package:flutter_svg/flutter_svg.dart';

class DiaryDetailsScreen extends StatefulWidget {
  final ValueKey keyRef;
  final String titlevalue;
  final String subtitle;
  final int dateTime;
  final int duration;
  final int intensity;
  final bool isIos;
  final List<String> localPath;
  final List<String> imgRef;
  final int category;

  const DiaryDetailsScreen(
      {Key key,
      @required this.keyRef,
      @required this.titlevalue,
      @required this.subtitle,
      @required this.dateTime,
      @required this.duration,
      @required this.intensity,
      @required this.isIos,
      @required this.localPath,
      @required this.imgRef,
      @required this.category})
      : super(key: key);

  @override
  _DiaryDetailsState createState() => _DiaryDetailsState(
      keyRef,
      titlevalue,
      subtitle,
      dateTime,
      duration,
      intensity,
      isIos,
      localPath,
      imgRef,
      category);
}

class _DiaryDetailsState extends State<DiaryDetailsScreen> {
  ValueKey keyRef;
  String titlevalue;
  String subtitle;
  int dateTime;
  int duration;
  int intensity;
  bool isIos;
  List<String> localPath;
  List<String> imgRef;
  int category;
  _DiaryDetailsState(
      this.keyRef,
      this.titlevalue,
      this.subtitle,
      this.dateTime,
      this.duration,
      this.intensity,
      this.isIos,
      this.localPath,
      this.imgRef,
      this.category);
  int _current = 0;
  List<IconData> iconList = [
    Icons.directions_bike,
    Icons.directions_run,
    Icons.directions_walk,
    Icons.sports_hockey,
    Icons.sports_baseball,
    Icons.sports_basketball,
    Icons.sports_football,
    Icons.sports_soccer,
    Icons.sports_tennis,
    Icons.sports_handball,
    Icons.miscellaneous_services,
    RpgAwesome.muscle_up,
  ];
  //remove activity from diary by deleting in database
  void _removeActivity(ValueKey dismissKey) {
    final user = Provider.of<UserClass>(context, listen: false);
    DatabaseService(uid: user.uid).removeDiaryItem(dismissKey.value);
  }

//remove meal from diary by deleting in database
  void _removeMeal(MealData mealToRemove) {
    final user = Provider.of<UserClass>(context, listen: false);
    DatabaseService(uid: user.uid).removeMeal(mealToRemove);
  }

//Pushes 'addmealscreen' and fills in screen with values of mealData.
//When user presses done button, database is updated with new values if changed
//mealData contains docId which is key generated by firebase.

  updateMeal(MealData mealData) {
    List<File> file = [];
    for (String path in mealData.localPath) {
      if (path != null) {
        try {
          print('path is $path');
          file.add(File(path));
          print('File list is then $file');
        } catch (e) {}
      }
    }
    print('In edit call the file list is $file');
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddMealScreen.edit(
                file,
                mealData.mealDate,
                TimeOfDay.fromDateTime(mealData.mealDate),
                mealData.mealDescription,
                mealData.mealImageUrl,
                true,
                mealData.docId)));
  }

//Updates database with new and edited data from activitydata
  Future updateActivity(context, activityData) async {
    final user = Provider.of<UserClass>(context, listen: false);
    await DatabaseService(uid: user.uid).updateTrainingDiaryData(
        activityData.trainingid, //ID
        activityData.name, //name
        activityData.description, //description
        activityData.date, //date
        activityData.duration, //duration
        activityData.intensity, //Intensity
        activityData.category //category
        );
  }

//Convert duration from milliseconds to readable string
  String convertTime(int time) {
    time ~/= 1000; //To centiseconds
    time ~/= 60; //to seconds
    int minutes = time % 60;
    time ~/= 60;
    int hours = time;
    if (hours == 1) {
      if (minutes == 0) {
        return "$hours Hour";
      } else {
        return "$hours Hour and $minutes Minutes";
      }
    }
    if (hours > 1) {
      if (minutes == 0) {
        return "$hours Hours";
      } else {
        return "$hours Hours and $minutes Minutes";
      }
    } else if (minutes > 0) {
      return "$minutes Minutes";
    } else {
      return "No duration";
    }
  }

//Builds the widget displayed in top half of screen if diary item is meal
//This widget is an image with a date/time overlay
  Widget mealImage(context, String imageRef, String localPath, bool _isIos) {
    return FutureBuilder(
        future: displayImage(context, _isIos, localPath, imageRef),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            Loading();
          } else {
            return snapshot.data;
          }
          return Container();
        });
  }

//Builds the widget displayed in top half of screen if diary item is meal
//This widget is the categorical icon, date/time, duration and intensity in
//a squared container
  Widget activityImage(context, int duration, int intensity, int category) {
    return Container(
      color: Color(0xFF99163D),
      child: Container(
          child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Container(
                  child: FittedBox(
                fit: BoxFit.fill,
                child: Icon(iconList[category]),
              ))),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                    flex: 1,
                    child: Container(
                        child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                          duration == 0 ? 'NO DURATION' : convertTime(duration),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'rubik',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ))),
                Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                          ),
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: Text(intensity.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'rubik',
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFFFFF6))),
                          )),
                    ))
              ],
            ),
          )
        ],
      )),
    );
  }

/*
  If image found locally, return image
  If image found on database, fetch image and return
  If image not found return 'No image' icon
  If image found but unable to fetch, return warning icon
*/
  Future<Widget> displayImage(BuildContext context, bool _isIos,
      String localPath, String imgRef) async {
    if (localPath != null) {
      try {
        File imageFile = File(localPath);
        if (await imageFile.exists()) {
          Image img = Image.file(imageFile);
          return img;
        }
      } on FileSystemException {
        print("Couldn't find local image");
      } catch (e) {
        print(e);
      }
    }
    return imgRef != null
        ? CachedNetworkImage(
            width: 85,
            progressIndicatorBuilder: (context, url, downProg) =>
                CircularProgressIndicator(value: downProg.progress),
            imageUrl: imgRef,
            errorWidget: (context, url, error) => Icon(_isIos
                ? CupertinoIcons.exclamationmark_triangle_fill
                : Icons.error),
          )
        : Container(
            child: Icon(
              Icons.image_not_supported,
              size: 60,
            ),
          );
  }

  List<Widget> buildCarousel(context, imgref, localpath) {
    List<Widget> imgList = [];
    if (imgref.length <= localpath.length) {
      for (int i = 0; i < imgref.length; i++) {
        imgList.add(mealImage(context, imgRef[i], localPath[i], isIos));
      }
    } else {
      for (int i = 0; i < localpath.length; i++) {
        imgList.add(mealImage(context, imgRef[i], localPath[i], isIos));
      }
    }

    return imgList;
  }

  Widget verticalSlider(BuildContext context) {
    List<Widget> imgList = buildCarousel(context, imgRef, localPath);

    return Stack(children: [
      Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        child: CarouselSlider(
          items: buildCarousel(context, imgRef, localPath),
          options: CarouselOptions(
              height: MediaQuery.of(context).size.height,
              autoPlay: true,
              viewportFraction: 1,
              enlargeCenterPage: true,
              aspectRatio: 1,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                  print('current updated : $_current');
                });
              }),
        ),
      ),
      Container(
        height: MediaQuery.of(context).size.width,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: imgList.map((url) {
              int index = imgList.indexOf(url);
              return Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == _current ? Colors.white : Colors.black,
                ),
              );
            }).toList(),
          ),
        ),
      )
    ]);
  }

/*
Widget for bottom half of screen and top overlay with date
In the bottom half this widget displays
String title, 
String description
And Row with button to delete and edit activity/meal
*/
  overlayView(bool isMeal, String titlevalue, String subtitle, int dateTime,
      {bool isIos,
      List<String> localPath,
      List<String> imgRef,
      int duration,
      int intensity,
      int category}) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(
          child: Column(children: [
        Container(
            width: MediaQuery.of(context).size.width,
            height: isMeal
                ? MediaQuery.of(context).size.width
                : MediaQuery.of(context).size.height * 0.35,
            child: Stack(
              children: [
                isMeal
                    ? FittedBox(
                        fit: BoxFit.fill,
                        child: verticalSlider(context),
                      )
                    : Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: activityImage(
                            context, duration, intensity, category),
                      ),
                Container(
                    color: Colors.black.withOpacity(0.5),
                    height: MediaQuery.of(context).size.height * 0.07,
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.fitHeight,
                      child: Text(
                          DateFormat('HH:mm\nEEEE - d MMMM').format(
                              DateTime.fromMillisecondsSinceEpoch(dateTime)),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'rubik',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.8))),
                    )),
              ],
            )), //displayImage(context, isIos, localPath, imgRef))),
        Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Container(
                alignment: Alignment.topLeft,
                decoration: BoxDecoration(
                    color: Color(0xFFFFFFF6),
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(3, 8),
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 8)
                    ],
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50))),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(titlevalue,
                                    style: TextStyle(
                                        fontFamily: 'rubik',
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(subtitle,
                                    style: TextStyle(
                                        fontFamily: 'rubik',
                                        fontSize: 22,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey[800])),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(left: 20.0, bottom: 10),
                          child: (Row(
                            children: [
                              IconButton(
                                  icon: Icon(Icons.delete,
                                      color: Color(0xFF99163D)),
                                  iconSize:
                                      MediaQuery.of(context).size.height * 0.06,
                                  onPressed: () {
                                    if (isMeal) {
                                      _removeMeal(new MealData(
                                          subtitle,
                                          DateTime.fromMillisecondsSinceEpoch(
                                              dateTime),
                                          imgRef,
                                          keyRef.value,
                                          localPath));
                                    } else {
                                      _removeActivity(keyRef);
                                    }
                                    Navigator.of(context).pop();
                                  }),
                              IconButton(
                                  icon: Icon(Icons.edit,
                                      color: Color(0xFF99163D)),
                                  iconSize:
                                      MediaQuery.of(context).size.height * 0.06,
                                  onPressed: () async {
                                    if (!isMeal) {
                                      TrainingData activityData =
                                          await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ActivityPopup(
                                                          keyRef: keyRef.value
                                                              .toString(),
                                                          isAdd: true,
                                                          titlevalue:
                                                              titlevalue,
                                                          subtitle: subtitle,
                                                          date: DateTime
                                                              .fromMillisecondsSinceEpoch(
                                                                  dateTime),
                                                          duration: duration,
                                                          intensity: intensity,
                                                          category: category)));
                                      if (activityData != null) {
                                        updateActivity(context, activityData);
                                      }
                                      if (Navigator.canPop(context)) {
                                        Navigator.pop(context);
                                      }
                                    } else {
                                      updateMeal(new MealData(
                                          subtitle,
                                          DateTime.fromMillisecondsSinceEpoch(
                                              dateTime),
                                          imgRef,
                                          keyRef.value,
                                          localPath));
                                    }
                                    /*while (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }*/
                                  })
                            ],
                          )),
                        ))
                  ],
                ),
              ),
            ))
      ])),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (localPath[0] == 'activity') {
      return overlayView(false, titlevalue, subtitle, dateTime,
          duration: duration, intensity: intensity, category: category);
    } else {
      return overlayView(true, titlevalue, subtitle, dateTime,
          isIos: isIos, localPath: localPath, imgRef: imgRef);
    }
  }
}
