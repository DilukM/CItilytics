import 'dart:ui';

import 'package:citylytics/Pages/images.dart';
import 'package:citylytics/Pages/settings.dart';
import 'package:flutter/material.dart';

class RedHome extends StatefulWidget {
  const RedHome({
    super.key,
  });

  @override
  State<RedHome> createState() => _RedHomeState();
}

class _RedHomeState extends State<RedHome> {
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
        builder: (context, orientation) => orientation == Orientation.portrait
            ? buildPortrait()
            : buildLandscape());
  }

  Widget buildPortrait() => Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover, image: AssetImage('assets/BG.png')),
            color: Colors.white),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 300),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const SettingsPage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                                    begin: const Offset(1.0, 0.0),
                                    end: Offset.zero)
                                .animate(animation),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.settings,
                    size: 26,
                    color: Colors.grey.shade800,
                  ))
            ],
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 20,
                  ),
                  child: Text(
                    textAlign: TextAlign.center,
                    "Discover the pulse of urban advertising with Citilytics",
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 70,
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width / 1.5,
                    child: Image.asset("assets/home.png")),
                const SizedBox(
                  height: 70,
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 60,
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/red');
                        },
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment(0.8, 1),
                                colors: <Color>[
                                  Color(0xff01aded),
                                  Color.fromARGB(255, 134, 222, 253),
                                ], // Gradient from https://learnui.design/tools/gradient-generator.html
                                tileMode: TileMode.mirror,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Click to set camera",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 60,
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration:
                                  const Duration(milliseconds: 300),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      ImageDisplayPage(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                          begin: const Offset(1.0, 0.0),
                                          end: Offset.zero)
                                      .animate(animation),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment(0.8, 1),
                                colors: <Color>[
                                  Color.fromARGB(255, 134, 222, 253),
                                  Color(0xff01aded),
                                ], // Gradient from https://learnui.design/tools/gradient-generator.html
                                tileMode: TileMode.mirror,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Captured Images",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  Widget buildLandscape() => Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                alignment: Alignment.topCenter,
                fit: BoxFit.cover,
                image: AssetImage('assets/BG1.png')),
            color: Colors.white),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              textAlign: TextAlign.center,
              "Discover the pulse of urban advertising with Citilytics",
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 22,
              ),
            ),
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 300),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const SettingsPage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                                    begin: const Offset(1.0, 0.0),
                                    end: Offset.zero)
                                .animate(animation),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.settings,
                    size: 26,
                    color: Colors.grey.shade800,
                  ))
            ],
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width / 4,
                        child: Image.asset("assets/home.png")),
                    Column(
                      children: [
                        SizedBox(
                          height: 60,
                          width: MediaQuery.of(context).size.width / 2,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/red');
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment(0.8, 1),
                                    colors: <Color>[
                                      Color(0xff01aded),
                                      Color.fromARGB(255, 134, 222, 253),
                                    ], // Gradient from https://learnui.design/tools/gradient-generator.html
                                    tileMode: TileMode.mirror,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Click to set camera",
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          height: 60,
                          width: MediaQuery.of(context).size.width / 2,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration:
                                      const Duration(milliseconds: 300),
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      ImageDisplayPage(),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                              begin: const Offset(1.0, 0.0),
                                              end: Offset.zero)
                                          .animate(animation),
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment(0.8, 1),
                                    colors: <Color>[
                                      Color.fromARGB(255, 134, 222, 253),
                                      Color(0xff01aded),
                                    ], // Gradient from https://learnui.design/tools/gradient-generator.html
                                    tileMode: TileMode.mirror,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Captured Images",
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
