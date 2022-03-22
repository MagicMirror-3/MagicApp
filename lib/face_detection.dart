import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart' as ml;
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as img;
import 'package:learning_input_image/learning_input_image.dart';

import 'util/communication_handler.dart';

int numberOfImages = 3;

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
  // The camera controller
  CameraController? controller;
  late List<CameraDescription> cameras;

  // face detection class
  FaceDetection faceDetection = FaceDetection();

  /// start periodically taking images and detecting faces, until [numberOfFaces]
  /// valid images are detected.
  void startDetection(int numberOfFaces) async {
    while (faceDetection.numberOfValidFaces() != numberOfFaces) {
      // wait
      // await Future.delayed(const Duration(milliseconds: 300), () {});
      await controller?.takePicture().then((image) async {
        // returns true when the image was valid
        if (await faceDetection.handleNewImage(image)) {
          // update the overlay
          setState(() {});
        }
      });
    }

    print("############################# Finished #######################");

    List<String> base64images = faceDetection.convertAndCrop();

    print(
        CommunicationHandler.createUser("test", "testest", "no", base64images));
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

          // connect to the front facing camera
          controller = CameraController(frontFacingCamera, ResolutionPreset.max,
              enableAudio: false);
          await controller!.initialize();
          if (!mounted) {
            return;
          }
          setState(() {});
          controller?.lockCaptureOrientation(DeviceOrientation.portraitUp);

          // start face detection
          startDetection(numberOfImages);
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
    faceDetection.dispose();
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
      body: CameraPreview(
        controller!,
        child: CameraOverlay(
          counter: faceDetection.numberOfValidFaces(),
          maxImages: numberOfImages,
        ),
      ),
    );
  }
}

/// This class defines an overlay with a CircularProgressIndicator, which
/// shows how many pictures have been taken.
class CameraOverlay extends StatefulWidget {
  const CameraOverlay(
      {required this.counter, required this.maxImages, Key? key})
      : super(key: key);

  final int counter;
  final int maxImages;

  @override
  _CameraOverlayState createState() => _CameraOverlayState();
}

class _CameraOverlayState extends State<CameraOverlay> {
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
              duration: const Duration(milliseconds: 600),
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

class FaceDetection {
  FaceDetector detector =
      GoogleMlKit.vision.faceDetector(const ml.FaceDetectorOptions(
    mode: ml.FaceDetectorMode.fast,
    enableLandmarks: false,
    enableContours: false,
    enableClassification: false,
    enableTracking: false,
    minFaceSize: 0.15,
  ));

  List<Face> facePositions = [];
  List<XFile> faceImages = [];

  /// Detect multiple [Face]s from an [image]
  Future<List<Face>> detectFaces(XFile image) async {
    // convert the XFile image to an InputImage
    File file = File(image.path);
    ml.InputImage inputImage = ml.InputImage.fromFile(file);

    //the detector needs an InputImage
    return detector.processImage(inputImage);
  }

  /// If exactly one faces is detected in [image], save it.
  Future<bool> handleNewImage(XFile image) async {
    List<Face> faces = await detectFaces(image);

    if (faces.length == 1) {
      facePositions.add(faces[0]);
      faceImages.add(image);
      print("###################### ${image.path} ########################");
      return true;
    }
    return false;
  }

  /// return the number of already saved images
  int numberOfValidFaces() {
    return facePositions.length;
  }

  /// convert XFile to img.Image
  img.Image xFile2Image(XFile image) {
    return img.decodeImage(File(image.path).readAsBytesSync())!;
  }

  /// convert the XFile to base64
  String image2base64(XFile image) {
    final bytes = File(image.path).readAsBytesSync();
    return base64.encode(bytes);
  }

  List<String> convertAndCrop() {
    List<String> base64images = [];

    for (int face_index = 0; face_index < faceImages.length; face_index++) {
      XFile faceImage = faceImages[face_index];
      Face facePosition = facePositions[face_index];

      final h = facePosition.boundingBox.bottom.toInt();
      final w = facePosition.boundingBox.width.toInt();
      final y = facePosition.boundingBox.top.toInt();
      final x = facePosition.boundingBox.left.toInt();

      img.Image croppedImage = img.copyCrop(xFile2Image(faceImage), x, y, w, h);
      base64images.add(base64.encode(img.encodeJpg(croppedImage)));
    }
    return base64images;
  }

  void dispose() {
    detector.close();
  }
}
