// adapted from Johannes Milke https://www.youtube.com/watch?v=4vKiJZNPhss
import 'package:capstone/main.dart';
import 'package:capstone/services/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  final Function() onClickedSignIn;

  const SignUp({
    Key? key,
    required this.onClickedSignIn,
  }) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            const Icon(
              Icons.scuba_diving_rounded,
              size: 120,
              color: Colors.blue,
              shadows: <Shadow>[
                Shadow(color: Colors.blueGrey, blurRadius: 100)
              ],
            ),
            const SizedBox(height: 60),
            const Text(
              'Sign Up For\nA New Account',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: emailController,
              cursorColor: Colors.blue.shade900,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (email) =>
                  email != null && !EmailValidator.validate(email)
                      ? 'Enter a valid email address'
                      : null,
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: passwordController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => value != null && value.length < 6
                  ? 'Enter a password of min. 6 characters'
                  : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              icon: const Icon(
                Icons.arrow_forward,
                size: 32,
              ),
              label: const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              onPressed: signUp,
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
                text: 'Already have an account? ',
                children: [
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = widget.onClickedSignIn,
                    text: 'Log In',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future signUp() async {
    // validate form
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    // start progress indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // create the user in firebase
    try {
      UserCredential userCred =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User user = userCred.user!;

      Map<String, dynamic> userInitialData = {
        'uid': user.uid,
        'email': user.email,
        'numDives': 0,
        'collectionLength': 0,
        'numVisible': 11,
        'sectionList': [
          'mainSection',
          'suit',
          'gasPressure',
          'weather',
          'stamp',
          'temperature',
          'weight',
          'timeInOut',
          'bottomTime',
          'depth',
          'visibility',
        ]
      };

      // create user doc
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');
      final docUser = usersCollection.doc(user.uid);

      // set user document info
      await docUser.set(userInitialData);

      // create log sub-collection along with Firebase-required dummy data
      await usersCollection
          .doc(user.uid)
          .collection('logs')
          .doc("dummy")
          .set({"dummy": "dummy"});

      // await usersCollection.doc(user.uid).collection('logs').doc("dummy").delete();
    } on FirebaseAuthException catch (e) {
      print(e);

      Utils.showSnackBar(e.message);
    }

    // pop back to Main
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
