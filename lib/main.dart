import 'package:flutter/material.dart';
import 'package:youtube_fb/app.dart';
import 'package:youtube_fb/setup.dart';

import 'university.dart';
//
Future<void> main() async {
  await setup();
  runApp(const App());
}