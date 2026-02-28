import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountScreen extends StatefulWidget {
  const CountScreen({super.key});

  @override
  State<CountScreen> createState() => _CountScreenState();
}

class _CountScreenState extends State<CountScreen> {
  // ✅ Switch state
  bool isRunning = false;

  // ✅ Timer
  Timer? timer;

  // ✅ Total seconds counter
  int totalSeconds = 0;

  //set target time
  int targetSeconds = 120;

  //disable countdown
  bool isSwitchDisabled = false;

  // ✅ Stored stopped time
  String stoppedTime = "00:00:00";

  // ✅ Username
  String username = "";

  // ✅ Current date
  String currentDate = "";

  // ✅ INIT
  @override
  void initState() {
    super.initState();
    loadUsername();
    loadDate();
  }

  // ✅ Load username from SharedPreferences
  Future<void> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      username = prefs.getString('username') ?? "User";
    });
  }

  // ✅ Load current date
  void loadDate() {
    final now = DateTime.now();
    currentDate = "${now.day}/${now.month}/${now.year}";
  }

  // ✅ Start counter
  void startCounter() {
    setState(() {
      isSwitchDisabled = true;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      {
        setState(() {
          totalSeconds++;
        });
      }
      if (totalSeconds >= targetSeconds) {
        timer.cancel();

        setState(() {
          isRunning = false;

          isSwitchDisabled = false; // ✅ enable switch again

          stoppedTime = formatTime(totalSeconds);
        });
      }
    });
  }

  // ✅ Stop counter
  void stopCounter() {
    timer?.cancel();

    setState(() {
      stoppedTime = formatTime(totalSeconds);
    });
  }

  // ✅ Convert seconds → HH:MM:SS
  String formatTime(int seconds) {
    int hours = seconds ~/ 3600;

    int minutes = (seconds % 3600) ~/ 60;

    int secs = seconds % 60;

    return "${hours.toString().padLeft(2, '0')}:"
        "${minutes.toString().padLeft(2, '0')}:"
        "${secs.toString().padLeft(2, '0')}";
  }

  // ✅ Dispose
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // ✅ UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome $username")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ✅ TOP ROW
            Row(
              children: [
                // ✅ TOP LEFT → SWITCH
                Switch(
                  value: isRunning,

                  onChanged: isSwitchDisabled
                      ? null
                      : (value) {
                          setState(() {
                            isRunning = value;
                          });

                          if (value) {
                            startCounter();
                          }
                        },
                ),

                const Spacer(),

                // ✅ TOP RIGHT → LIVE COUNTER
                Text(
                  formatTime(totalSeconds),

                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // ✅ BOTTOM ROW
            Row(
              children: [
                // ✅ STOPPED TIME
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text("Stopped Time", style: TextStyle(fontSize: 16)),

                    Text(
                      stoppedTime,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // ✅ CURRENT DATE
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,

                  children: [
                    const Text("Current Date", style: TextStyle(fontSize: 16)),

                    Text(
                      currentDate,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
