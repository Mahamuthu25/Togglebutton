import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🟢 NEW

class CountScreen extends StatefulWidget {
  const CountScreen({Key? key}) : super(key: key);

  @override
  State<CountScreen> createState() => _CountScreenState();
}

class _CountScreenState extends State<CountScreen> {
  bool isRunning = false;

  int totalSeconds = 0;

  String formattedTime = "00:00:00";

  String stoppedTime = "00:00:00";

  String username = "";

  String docId = "";

  Timer? timer;

  final firestore = FirebaseFirestore.instance;

  final FirebaseAuth auth = FirebaseAuth.instance; // 🟢 NEW

  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser == null) {
    Navigator.pop(context);
    return;
  }

  loadUser();
  }

  Future<void> loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    username = prefs.getString("username") ?? "";

    User? user = auth.currentUser;

if (user == null) {
  
  return;
}

docId = user.uid; // 🟢 NEW

    await loadFromFirestore();
  }

  Future<void> loadFromFirestore() async {
    DocumentSnapshot doc = await firestore.collection("users").doc(docId).get();

    if (doc.exists) {
      isRunning = doc["isRunning"] ?? false;

      totalSeconds = doc["totalSeconds"] ?? 0;

      stoppedTime = doc["stoppedTime"] ?? "00:00:00";

      formattedTime = doc["formattedTime"] ?? formatTime(totalSeconds);

      setState(() {});

      if (isRunning) {
        startTimer();
      }
    }
  }

  void startTimer() {
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      totalSeconds++;

      formattedTime = formatTime(totalSeconds);

      setState(() {});

      await firestore.collection("users").doc(docId).update({
        "formattedTime": formattedTime,

        "totalSeconds": totalSeconds,
      });
    });
  }

  Future<void> startCount() async {
    isRunning = true;

    totalSeconds = 0;

    formattedTime = "00:00:00";

    await firestore.collection("users").doc(docId).set({
      "username": username,

      "isRunning": true,

      "startTime": DateTime.now().toIso8601String(),

      "stoppedTime": stoppedTime,

      "totalSeconds": totalSeconds,

      "formattedTime": formattedTime,

      "date": getDate(),
    });

    startTimer();

    setState(() {});
  }

  Future<void> stopCount() async {
    isRunning = false;

    timer?.cancel();

    stoppedTime = formatTime(totalSeconds);

    formattedTime = stoppedTime;

    await firestore.collection("users").doc(docId).update({
      "isRunning": false,

      "stoppedTime": stoppedTime,

      "formattedTime": formattedTime,

      "totalSeconds": totalSeconds,
    });

    setState(() {});
  }

  String formatTime(int seconds) {
    int hours = seconds ~/ 3600;

    int minutes = (seconds % 3600) ~/ 60;

    int secs = seconds % 60;

    return "${hours.toString().padLeft(2, '0')}:"
        "${minutes.toString().padLeft(2, '0')}:"
        "${secs.toString().padLeft(2, '0')}";
  }

  String getDate() {
    DateTime now = DateTime.now();

    return "${now.day.toString().padLeft(2, '0')}/"
        "${now.month.toString().padLeft(2, '0')}/"
        "${now.year}";
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Count Screen"), centerTitle: true),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          const SizedBox(height: 50),

          Center(
            child: Text(
              formattedTime,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 30),

         Switch(
  value: isRunning,
  onChanged: (value) async {
    setState(() {
      isRunning = value;
    });

    if (value) {
      await startCount();
    } else {
      await stopCount();
    }
  },
),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(20),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Text(stoppedTime, style: const TextStyle(fontSize: 16)),

                Text(getDate(), style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
