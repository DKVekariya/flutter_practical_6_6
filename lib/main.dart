import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'CameraView.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(CameraApp(cameras: cameras));
}
