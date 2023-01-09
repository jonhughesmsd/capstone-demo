import 'package:capstone/screens/log/log.dart';
import 'package:capstone/screens/log/log_settings.dart';
import 'package:capstone/screens/logbook/logbook.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:capstone/singletons/user_data.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    // fetch user data from firebase and populate in database member variables
    final user = FirebaseAuth.instance.currentUser!;
    userData.uid = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              child: const Icon(Icons.settings_rounded),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LogSettings(),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              child: const Icon(Icons.exit_to_app),
              onTap: () => FirebaseAuth.instance.signOut(),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            heightFactor: 1.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  child: Image.asset(
                    'assets/diver.png',
                    color: Colors.blue.shade700,
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  'Dive Log App',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,),
                ),

                const SizedBox(height: 80),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  icon: const Icon(
                    Icons.post_add_rounded,
                    size: 32,
                  ),
                  label: const Text(
                    'New Log',
                    style: TextStyle(fontSize: 24),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Log(prevLogData: null),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    disabledBackgroundColor: Colors.grey.shade500,
                  ),
                  icon: const Icon(
                    Icons.library_books_rounded,
                    size: 32,
                  ),
                  label: const Text(
                    'Logbook',
                    style: TextStyle(fontSize: 24),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Logbook(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
