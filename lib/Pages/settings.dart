import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SharedPreferences prefs;
  late double _confidence = 0.8;

  @override
  void initState() {
    super.initState();
    _loadConfidence();
  }

  Future<void> _loadConfidence() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _confidence = prefs.getDouble('confidence') ?? 0.8;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 22.0),
              child: Text(
                'Accuracy',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Slider(
                    inactiveColor: Colors.grey,
                    activeColor: const Color.fromARGB(255, 88, 228, 244),
                    value: _confidence,
                    min: 0,
                    max: 1,
                    onChanged: (value) async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setDouble('confidence', value);
                      setState(() {
                        _confidence = value;
                      });
                    },
                  ),
                ),
                Text(
                  '${(_confidence * 100).toInt()}%',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            Divider(
              color: Colors.grey[300],
            )
          ],
        ),
      ),
    );
  }
}
