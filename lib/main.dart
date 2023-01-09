import 'package:capstone/firebase_options.dart';
import 'package:capstone/screens/authenticate/auth.dart';
import 'package:capstone/screens/home/home.dart';
import 'package:capstone/services/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:capstone/singletons/user_data.dart';
import 'package:path_provider/path_provider.dart';
import 'screens/shared/loading.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

final navigatorKey = GlobalKey<
    NavigatorState>(); // nav key for popping progress indicator in Login.signIn

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // removes 'debug' banner from emulator
      navigatorKey: navigatorKey, // nav key for progress indicator
      scaffoldMessengerKey: Utils.messengerKey, // messenger key for snack bar
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  // route to Home if there are user credentials, else route to Auth
  @override
  Widget build(BuildContext) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loading();
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Login Error'),
            );
          } else if (snapshot.hasData) {
            userData.uid = snapshot.data!.uid;
            setup();  // create user data singleton
            return const Home();
          } else {
            return const Auth();
          }
        },
      ),
    );
  }
}

setup() async {
  // get single user doc by uid
  final docUser =
      FirebaseFirestore.instance.collection('users').doc(userData.uid);

  final docSnapshot = await docUser.get();

  if (docSnapshot.exists) {
    final userJson = docSnapshot.data()!;
    userData.email = userJson['email'];
    userData.numDives = userJson['numDives'];
    userData.collectionLength = userJson['collectionLength'];
    userData.numVisible = userJson['numVisible'];
    userData.sectionList = userJson['sectionList'];

    userData.appDir = await getApplicationDocumentsDirectory();
  }
}
