import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:io';
import 'PreviewScreen.dart';
import 'main.dart';

class CameraApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const CameraApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: CameraScreen(cameras: cameras),
    );
  }
}

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  List<File> _capturedImages = [];

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.cameras[0], ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      setState(() {
        _capturedImages.add(File(image.path));
      });
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  Future<void> _saveImagesToGallery(BuildContext context) async {
    if (_capturedImages.isNotEmpty) {
      for (var image in _capturedImages) {
        await PhotoManager.editor.saveImageWithPath(image.path);
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Images saved to gallery!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No images to save!')),
      );
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveImagesToGallery(context),
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Preview button on the left, only if there are captured images.
            if (_capturedImages.isNotEmpty)
              FloatingActionButton(
                heroTag: "previewButton",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PreviewScreen(images: _capturedImages),
                    ),
                  );
                },
                child: const Icon(Icons.preview),
              ),
            const SizedBox(width: 40), // Spacing between buttons.
            // Capture button at the center.
            FloatingActionButton(
              heroTag: "captureButton",
              onPressed: () => _captureImage(),
              child: const Icon(Icons.camera_alt),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
