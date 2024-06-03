import 'package:citylytics/Pages/SplashScreen.dart';
import 'package:citylytics/Pages/imageProcessingPage.dart';
import 'package:citylytics/Pages/Home.dart';
import 'package:citylytics/Pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';

import 'Theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: App(camera: firstCamera),
    ),
  );
}

class App extends StatelessWidget {
  final CameraDescription camera;
  const App({super.key, required this.camera});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: Provider.of<ThemeProvider>(context).themeData,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/redhome': (context) => RedHome(),
        '/settings': (context) => SettingsPage(),
        '/red': (context) => Red(
              camera: camera,
            ),
      },
    );
  }
}
