import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageDisplayPage extends StatefulWidget {
  @override
  _ImageDisplayPageState createState() => _ImageDisplayPageState();
}

class _ImageDisplayPageState extends State<ImageDisplayPage> {
  Map<String, List<String>> groupedImagePaths = {};

  @override
  void initState() {
    super.initState();
    _loadImagePathsFromPrefs();
  }

  Future<void> _loadImagePathsFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('groupedImagePaths');
    if (jsonString != null) {
      Map<String, dynamic> decodedMap = jsonDecode(jsonString);
      Map<String, List<String>> convertedMap = decodedMap.map((key, value) {
        return MapEntry(key, List<String>.from(value));
      });
      setState(() {
        groupedImagePaths = convertedMap;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (groupedImagePaths.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios)),
          title: Text('Captured Images'),
        ),
        body: Center(
          child: Text('No images found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Captured Images'),
      ),
      body: ListView.builder(
        itemCount: groupedImagePaths.keys.length,
        itemBuilder: (context, index) {
          String groupId = groupedImagePaths.keys.elementAt(index);
          List<String> images = groupedImagePaths[groupId]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('$groupId',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: images.map((path) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FullScreenImage(imagePath: path),
                            ),
                          );
                        },
                        child: Image.file(File(path),
                            width: MediaQuery.of(context).size.width / 4,
                            height: MediaQuery.of(context).size.width / 4),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imagePath;

  FullScreenImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios)),
      ),
      body: Center(
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
