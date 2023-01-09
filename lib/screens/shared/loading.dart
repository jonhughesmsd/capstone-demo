import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  // loading screen to show while waiting for asynchronous calls
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const Center(
        child: SpinKitRipple(
          color: Colors.lightBlue,
          size: 100,
        ),
      ),
    );
  }
}
