import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:magic_app/util/utility.dart';
import '../settings/shared_preferences_handler.dart';
import '../util/communication_handler.dart';

int numberOfImages = 5;

class Start extends StatefulWidget {
  const Start({Key? key}) : super(key: key);

  @override
  _StartState createState() => _StartState();
}

class _StartState extends State<Start> {
  @override
  Widget build(BuildContext context) {
    return FaceRegistrationScreen(onFinished: () => print("test"));
  }
}

/// This widget is the main Face Registration Screen, it contains a face
/// recognition service, that consequently saves images that contains a persons face.
/// This is visualized using an overlay.
class FaceRegistrationScreen extends StatefulWidget {
  const FaceRegistrationScreen({required Function this.onFinished, Key? key})
      : super(key: key);

  final onFinished;

  @override
  _FaceRegistrationScreenState createState() => _FaceRegistrationScreenState();
}

class _FaceRegistrationScreenState extends State<FaceRegistrationScreen> {
  // The camera controller
  CameraController? controller;
  late List<CameraDescription> cameras;

  // face detection class
  FaceDetection faceDetection = FaceDetection();

  // If true the loading animation is shown as camera overlay
  Overlays overlay = Overlays.camera;

  /// start periodically taking images and detecting faces, until [numberOfFaces]
  /// valid images are detected.
  void startDetection(int numberOfFaces) async {
    while (faceDetection.numberOfValidFaces() != numberOfFaces) {
      // wait
      await controller?.takePicture().then((image) async {
        // returns true when the image was valid
        if (await faceDetection.handleNewImage(image)) {
          // update the overlay
          setState(() {});
        }
      });
    }

    faceDetectionFinished();
  }

  /// When enough face images are taken, this method encodes them and sends these to the controller.
  /// The controller can either accept the images or reject them. This bool is passed
  /// to the parent widget using the callback "onFinished".
  void faceDetectionFinished() async {
    await Future.delayed(const Duration(milliseconds: 500), () {});
    // update overlay to show loading animation
    setState(() => overlay = Overlays.processing);
    // send images to mirror

    /// get current user from shared preferences
    MagicUser user = PreferencesAdapter.tempUser;

    //
    compute(computeImages, faceDetection).then((base64images) async {
      // return user_id if creating user was successful, else -1
      CommunicationHandler.createUser(
        user.firstName,
        user.lastName,
        base64images,
      ).then((userID) async {
        // user was not created, show a message and the go back to the last
        // introduction page
        if (userID == -1) {
          // update overlay to failed
          setState(() {
            overlay = Overlays.failed;
          });

          await Future.delayed(const Duration(milliseconds: 1000), () {});
        } else {
          setState(() {
            overlay = Overlays.success;
          });

          await Future.delayed(const Duration(milliseconds: 1000), () {});
        }

        // sent userId to parent
        widget.onFinished(userID);
      });
    });
  }

  /// Cropping and converting images to base64 is CPU heavy and should be done
  /// in a separate isolate to avoid blocking the UI thread. Get an instance
  /// [detection], that holds the face images
  static Future<List<String>> computeImages(FaceDetection detection) async {
    // convert saved images to base64 and crop them
    return detection.convertAndCrop();
  }

  @override
  void initState() {
    super.initState();
    availableCameras().then(
      (value) async {
        cameras = value;

        // select the front facing camera
        CameraDescription frontFacingCamera;
        for (CameraDescription camera in cameras) {
          if (camera.lensDirection == CameraLensDirection.front) {
            frontFacingCamera = camera;

            // connect to the front facing camera
            controller = CameraController(
              frontFacingCamera,
              ResolutionPreset.max,
              enableAudio: false,
              imageFormatGroup: ImageFormatGroup.yuv420,
            );
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
      },
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
    faceDetection.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // remove keyboard focus
    FocusScope.of(context).unfocus();

    if (controller == null || !controller!.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      body: CameraPreview(controller!,
          child: (() {
            if (overlay == Overlays.camera) {
              return CameraOverlay(
                counter: faceDetection.numberOfValidFaces(),
                maxImages: numberOfImages,
              );
            } else if (overlay == Overlays.processing) {
              return const ProcessingOverlay();
            } else if (overlay == Overlays.failed) {
              return const FailedOverlay();
            } else if (overlay == Overlays.success) {
              return const SuccessOverlay();
            }
          }())),
      backgroundColor: Colors.black,
    );
  }
}

/// Defines the types of possible overlays of the camera
enum Overlays { camera, processing, failed, success }

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
          child: LayoutBuilder(
            builder: (_, BoxConstraints constraints) => SizedBox.square(
              dimension: constraints.maxWidth - 10,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(
                    begin: 0.0, end: widget.counter * 1.0 / widget.maxImages),
                duration: const Duration(milliseconds: 400),
                builder: (context, value, _) => CircularProgressIndicator(
                  value: value,
                  strokeWidth: 10,
                  backgroundColor: Colors.black,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 510, 0, 0),
          child: Center(
            child: Text(
              "Configuring Face Recognition for the Mirror. "
              "Please position your head in the center of the circle.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

/// Overlay that shows a progress indicator
class ProcessingOverlay extends StatelessWidget {
  const ProcessingOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Overlay that shows a failed screen.
class FailedOverlay extends StatelessWidget {
  const FailedOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Icon(
              Icons.clear,
              color: Colors.red,
              size: 50,
            ),
            Text(
              "Failed to create user, try again",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Overlay that shows a success screen
class SuccessOverlay extends StatelessWidget {
  const SuccessOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.done,
              color: Colors.green,
              size: 50,
            ),
          ],
        ),
      ),
    );
  }
}

/// Class that wraps the GoogleMLKit Face Detector and saves Face Images.
class FaceDetection {
  FaceDetector detector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableLandmarks: false,
      enableContours: false,
      enableClassification: false,
      enableTracking: false,
      minFaceSize: 0.15,
    ),
  );

  List<Face> facePositions = [];
  List<XFile> faceImages = [];

  /// Detect multiple [Face]s from an [image]
  Future<List<Face>> detectFaces(XFile image) async {
    // convert the XFile image to an InputImage
    File file = File(image.path);
    InputImage inputImage = InputImage.fromFile(file);

    if (Platform.isIOS) {
      final capturedImage =
          img.decodeImage(await File(inputImage.filePath!).readAsBytes())!;
      final orientedImage = img.bakeOrientation(capturedImage);
      final imageToBeProcessed =
          await File(image.path).writeAsBytes(img.encodeJpg(orientedImage));

      inputImage = InputImage.fromFilePath(imageToBeProcessed.path);
    }

    print(
        "Trying to detect faces on the image (${image.name}) at ${image.path}");

    print("InputImage: ${inputImage.toJson()}");

    //the detector needs an InputImage
    return detector.processImage(inputImage);
  }

  /// If exactly one faces is detected in [image], save it.
  Future<bool> handleNewImage(XFile image) async {
    List<Face> faces = await detectFaces(image);

    print("Faces found: $faces");
    if (faces.length == 1) {
      facePositions.add(faces[0]);
      faceImages.add(image);
      // print("###################### ${image.path} ########################");
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

  /// Crop the image based on it´s face position and convert it to base64
  List<String> convertAndCrop() {
    List<String> base64images = [];

    for (int faceIndex = 0; faceIndex < faceImages.length; faceIndex++) {
      XFile faceImage = faceImages[faceIndex];
      Face facePosition = facePositions[faceIndex];

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
