import 'package:flutter/material.dart';
import 'package:youtube_fb/crudeoperation.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CRUDEoperation(),
      // home: UniversityScreen(),
    );
  }
}
