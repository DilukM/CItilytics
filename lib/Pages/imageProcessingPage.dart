import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:citylytics/Pages/settings.dart';

import 'package:citylytics/util/shape.dart';
import 'package:flutter/material.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:path_provider/path_provider.dart';

class Red extends StatefulWidget {
  final CameraDescription camera;
  const Red({Key? key, required this.camera}) : super(key: key);

  @override
  State<Red> createState() => _RedState();
}

class _RedState extends State<Red> {
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;

  String label = '';
  double confidence = 0.0;
  late double _confidence;
  bool _isProcessingPaused = false;
  late SharedPreferences _prefs;
  Map<String, List<String>> groupedImagePaths = {};

  @override
  void initState() {
    super.initState();

    // Initialize SharedPreferences
    SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
      _confidence = _prefs.getDouble('confidence') ?? 0.8;
      // Initialize camera controller
      _controller = CameraController(widget.camera, ResolutionPreset.high);
      _initializeControllerFuture = _controller.initialize().then((_) async {
        await _tfLiteInit();
        if (!_isProcessingPaused) {
          await _startStreaming();
        }
      });
    });
  }

  Future<void> _tfLiteInit() async {
    await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
  }

  Future<void> _startStreaming() async {
    await _controller.startImageStream((CameraImage image) {
      _processImage(image);
    });
  }

  Future<void> _processImage(CameraImage image) async {
    if (mounted && !_isProcessingPaused) {
      var recognitions = await Tflite.runModelOnFrame(
        bytesList: image.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: MediaQuery.of(context).size.height.toInt(),
        imageWidth: image.width,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.2,
        rotation: -90,
      );

      if (recognitions == null || recognitions.isEmpty) {
        setState(() {
          label = '';
          confidence = 0.0;
        });
      } else {
        setState(() {
          confidence = recognitions[0]['confidence'] * 100;
          label = recognitions[0]['label'].toString();
          // Set detected color
        });
        //Logic to check detected color and confidence level
        if (recognitions[0]['label'].toString() == 'advertise' &&
            recognitions[0]['confidence'] >= _confidence) {
          await _captureAndSaveImages();
        } else {
          setState(() {
            confidence = recognitions[0]['confidence'] * 100;
            label = recognitions[0]['label'].toString();
          });
        }
      }
    }
  }

  Future<void> _captureAndSaveImages() async {
    // Pause image streaming
    _controller.stopImageStream();
    String groupId = DateTime.now().toString();
    List<String> newImagePaths = [];
    for (int i = 0; i < 3; i++) {
      final XFile file = await _controller.takePicture();
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/picture_${groupId}_$i.jpg';
      await file.saveTo(filePath);
      newImagePaths.add(filePath);

      // await Future.delayed(Duration(milliseconds: 500));
    }
    setState(() {
      groupedImagePaths[groupId] = newImagePaths;
    });

    // Save to shared preferences
    await _saveImagePathsToPrefs();
    // Resume image streaming
    _startStreaming();
  }

  Future<void> _saveImagePathsToPrefs() async {
    String jsonString = jsonEncode(groupedImagePaths);
    await _prefs.setString('groupedImagePaths', jsonString);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Images saved to Storage')),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    Tflite.close();

    super.dispose();
    WakelockPlus.disable();
  }

  void _toggleProcessingAndNavigate(int index) {
    setState(() {
      _isProcessingPaused = true; // Pause processing

      // Stop image stream
      _controller.stopImageStream();
    });

    // Navigate after processing has been paused
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    WakelockPlus.enable();
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return OrientationBuilder(
                builder: (context, orientation) =>
                    orientation == Orientation.portrait
                        ? buildProtrait()
                        : buildLandscape());
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget buildProtrait() => Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                CameraPreview(_controller),
                ClipPath(
                  clipper: RectangularHoleClipper(
                      holeWidth: MediaQuery.of(context).size.width * 0.65,
                      holeHeight: MediaQuery.of(context).size.width * 0.85,
                      borderRadius: 25), // Adjust hole size as needed
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width * 1.77,
                    color: Colors.black45,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(12))),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Label',
                                ),
                                Text('$label',
                                    style: TextStyle(
                                        color: Color(0xff01aded),
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Confidence'),
                                Text('${confidence.toInt()}',
                                    style: TextStyle(
                                        color: Color(0xff01aded),
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_isProcessingPaused) {
                              _startStreaming();
                              setState(() {
                                _isProcessingPaused = false;
                              });
                            } else {
                              _controller.stopImageStream();

                              setState(() {
                                _isProcessingPaused = true;
                              });
                            }
                          },
                          child: Container(
                            height: 60,
                            width: MediaQuery.of(context).size.width / 1.5,
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
                                _isProcessingPaused
                                    ? 'Start capturing'
                                    : 'Stop capturing',
                                style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                    top: 40,
                    right: 10,
                    child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration:
                                  const Duration(milliseconds: 300),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const SettingsPage(),
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
                        icon: Icon(
                          Icons.settings,
                          color: Colors.white,
                        ))),
                Positioned(
                    top: 40,
                    left: 10,
                    child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ))),
              ],
            ),
          ),
        ],
      );

  Widget buildLandscape() => Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                CameraPreview(_controller),
                ClipPath(
                  clipper: RectangularHoleClipper(
                      holeWidth: MediaQuery.of(context).size.width * 0.5,
                      holeHeight: MediaQuery.of(context).size.height * 0.85,
                      borderRadius: 25), // Adjust hole size as needed
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.black45,
                  ),
                ),
                Positioned(
                  right: 0,
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width * 0.3,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius:
                            BorderRadius.horizontal(left: Radius.circular(12))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Label',
                                ),
                                Text('$label',
                                    style: TextStyle(
                                        color: Color(0xff01aded),
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Confidence'),
                                Text('${confidence.toInt()}',
                                    style: TextStyle(
                                        color: Color(0xff01aded),
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_isProcessingPaused) {
                              _startStreaming();
                              setState(() {
                                _isProcessingPaused = false;
                              });
                            } else {
                              _controller.stopImageStream();

                              setState(() {
                                _isProcessingPaused = true;
                              });
                            }
                          },
                          child: Container(
                            height: 60,
                            width: MediaQuery.of(context).size.width,
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
                                _isProcessingPaused
                                    ? 'Start capturing'
                                    : 'Stop capturing',
                                style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                    bottom: 30,
                    left: 10,
                    child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration:
                                  const Duration(milliseconds: 300),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const SettingsPage(),
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
                        icon: Icon(
                          Icons.settings,
                          color: Colors.white,
                        ))),
                Positioned(
                    top: 30,
                    left: 10,
                    child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ))),
              ],
            ),
          ),
        ],
      );
}
