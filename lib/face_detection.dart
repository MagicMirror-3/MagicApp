import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learning_face_detection/learning_face_detection.dart';
import 'package:learning_input_image/learning_input_image.dart';

class Start extends StatefulWidget {
  const Start({Key? key}) : super(key: key);

  @override
  _StartState createState() => _StartState();
}

class _StartState extends State<Start> {
  @override
  Widget build(BuildContext context) {
    return CameraApp();
  }
}

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController? controller;
  late List<CameraDescription> cameras;
  FaceDetector detector = FaceDetector(
    mode: FaceDetectorMode.accurate,
    detectLandmark: false,
    detectContour: false,
    enableClassification: false,
    enableTracking: false,
    minFaceSize: 0.15,
  );
  int frameCounter = 0;
  List<Face> validFaces = [];
  late Image image;

  int numberOfImages = 5;

  Future<List<Face>> detectFaces(XFile image) async {
    File file = File(image.path);
    InputImage inputImage = InputImage.fromFile(file);

    //the detector needs a InputImage
    return detector.detect(inputImage);
  }

  void startDetection(int numberOfFaces) async {
    while (validFaces.length != 5) {
      // wait
      await Future.delayed(const Duration(milliseconds: 300));

      controller?.takePicture().then((value) async {
        List<Face> facelist = await detectFaces(value);
        if (facelist.length == 1) {
          print("###################### face ########################");
          validFaces.add(facelist[0]);

          // update the overlay
          setState(() {});
        } else {
          print("###################### no face ########################");
          print(facelist);
        }
      });

      print("###################### Found 5 faces ########################");
    }
  }

  @override
  void initState() {
    super.initState();
    availableCameras().then((value) async {
      cameras = value;

      // select the front facing camera
      CameraDescription frontFacingCamera;
      for (CameraDescription camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          frontFacingCamera = camera;

          controller = CameraController(frontFacingCamera, ResolutionPreset.max,
              enableAudio: false);
          await controller!.initialize();
          if (!mounted) {
            return;
          }
          setState(() {});
          controller?.lockCaptureOrientation(DeviceOrientation.portraitUp);

          // start detection
          startDetection(numberOfImages);
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test"),
      ),
      body: CameraPreview(controller!,
          child: Overlay(
            counter: validFaces.length,
            maxImages: numberOfImages,
          )),
    );
  }
}

class Overlay extends StatefulWidget {
  const Overlay({required this.counter, required this.maxImages, Key? key})
      : super(key: key);

  final int counter;
  final int maxImages;

  @override
  _OverlayState createState() => _OverlayState();
}

class _OverlayState extends State<Overlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: const ColorFilter.mode(
              Colors.black, BlendMode.srcOut), // This one will create the magic
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode
                        .dstOut), // This one will handle background + difference out
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Center(
                  child: Container(
                    height: 350,
                    width: 350,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: SizedBox(
            height: 350,
            width: 350,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                  begin: 0.0, end: widget.counter * 1.0 / widget.maxImages),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, _) => CircularProgressIndicator(
                value: value,
                strokeWidth: 10,
                backgroundColor: Colors.black,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
