import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'imgcrop_icons.dart';
import 'image_page.dart';
import 'text_list.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

List<CameraDescription>? cameras;
CameraDescription? camera;
typedef onAvialable = Function(CameraImage image);
Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
//  Map<Permission, PermissionStatus> statuses = await [
//   Permission.camera,
// ].request();
  //  print(statuses .toString());
  cameras = await availableCameras();
  // camera = cameras![0];
  camera =  cameras!.first;
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'croper',
      theme: new ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: new MyHomePage(title: 'croper'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key,required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  CameraController? controller;
  VideoPlayerController? _controller;
  double maskTop = 60.0;
  double maskLeft = 60.0;
  double maskWidth = 200.0;
  double maskHeight = 200.0;
  double dragStartX = 0.0;
  double dragStartY = 0.0;
  double imgDragStartX = 0.0;
  double imgDragStartY = 0.0;
  double oldScale = 1.0;
  double oldRotate = 0.0;
  double rotate = 0.0;
  ImageInfo? imageInfo;
  Offset topLeft = new Offset(0.0, 0.0);
  Matrix4 matrix = new Matrix4.identity();

  @override
  void initState() {
    super.initState();
    initCamera();
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == AppLifecycleState.resumed.toString()) {
        reloadCamera();
      }
      return "";
    });
  }

  void reloadCamera() {
    availableCameras().then((cameras) {
      camera = cameras[0];
      controller = new CameraController(camera!, ResolutionPreset.medium);
      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    });
  }
 late Future<void> _initializeControllerFuture;
  void initCamera() async {
    
    controller = new CameraController(camera!, ResolutionPreset.medium);
    _initializeControllerFuture = 
    // _controller!.initialize();
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  void captureImage(ImageSource captureMode) async {
    try {
      ImagePicker imagePickerr = ImagePicker();
      var imageFile = await imagePickerr.pickImage(source: captureMode);
      _loadImage(File(imageFile!.path)).then((image) {
        if (image != null) {
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => new CropPage(
                      title: 'crop',
                      image: image,
                      imageInfo: new ImageInfo(image: image, scale: 1.0))));
        }
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();
XFile? xxFille;

  Future<String?> capture() async {
    if (!controller!.value.isInitialized) {
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/imgcroper';
    await new Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';
    try {
    //   controller!.initialize().then((_) {
    //   if (!mounted) {
    //     return;
    //   }
    //   setState(() {});
    // }).catchError((Object e) {
    //   if (e is CameraException) {
    //     switch (e.code) {
    //       case 'CameraAccessDenied':
    //         print('User denied camera access.');
    //         break;
    //       default:
    //         print('Handle other errors.');
    //         break;
    //     }
    //   }
    // });
      // if (state == AppLifecycleState.inactive) {
      //   controller.dispose();
      // } else if (state == AppLifecycleState.resumed) {
      //   onNewCameraSelected(controller.description);
      // }
      await _initializeControllerFuture;
      if(controller != null){
        XFile image = await controller!.takePicture();
        xxFille = image;
      }else{
        return null;
      }
      
      // XFile? xxFille;
      // xxFille = await controller!.takePicture();
      // controller!.startImageStream(onAvialable2);
      // if(controller!.value.isStreamingImages &&
      //   controller != null){
       
      //   if (controller != null) {
      //     await controller!.stopImageStream();
      //     // .then((_) {
      //      await controller!.dispose();
      //     // });
      //   }
      // }else{
      //   print("errore");
      // }
      
      try {
        // File? imageFile;
        // File? imageFile  = await _pickImage();
        if(xxFille != null){
        var imagee =await  _loadImage(File(xxFille!.path));

          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => new CropPage(
                      title: 'crop',
                      image: imagee!,
                      imageInfo: new ImageInfo(image: imagee, scale: 1.0))));  
        }else{
          print("Errrore");
        }
        
        // });
      } catch (e) {
        print(e);
      }
    } on CameraException catch (e) {
      return null;
    }
    return filePath;
  }

  Future<File?> _pickImage()async {
    File? fileF;
    XFile? fileee =await  ImagePicker().pickImage(source: ImageSource.camera, maxHeight:1080 , maxWidth: 1080);
    fileF = File(fileee!.path);
     final LostDataResponse response =
      await ImagePicker().retrieveLostData();
      if (response.isEmpty) {
        return null;
      }
      if (response.files != null) {
        for (final XFile fileXX in response.files!) {
          // _handleFile(file);
          fileF = File(fileXX.path);
        }
      } else {
        // _handleError(response.exception);
      }
    
    return fileF;
  }
  onAvialable2(CameraImage img){
    // xxFille  = img.
  }

  Future<Widget> _buildImage(BuildContext context) async {
    return new Stack(children: <Widget>[
      new Container(
          height: MediaQuery.of(context).size.height- 100,
          width: MediaQuery.of(context).size.width-100,
          // child: new Transform.scale(
              // scale: 2 / controller!.value.aspectRatio,
              child: new Center(
                // child: new AspectRatio(
                    // aspectRatio: controller!.value.aspectRatio,
                    child: new CameraPreview(controller!)
                    // ),
              // )
              )),
      // new Positioned(
      //   bottom: 20.0,
      //   height: 40.0,
      //   width: 40.0,
      //   left: (20.0),
      //   child: new RaisedButton(
      //       onPressed: () => captureImage(ImageSource.gallery),
      //       padding: EdgeInsets.all(10.0),
      //       shape: new RoundedRectangleBorder(
      //           borderRadius: BorderRadius.all(Radius.circular(40.0))),
      //       // child: new Icon(Imgcrop.picture_outline,
      //       //     size: 20.0, color: Colors.red)
      //           ),
      // ),
      new Positioned(
        bottom: 20.0,
        height: 60.0,
        width: 60.0,
        left: (MediaQuery.of(context).size.width / 2 - 30.0),
        child: new RaisedButton(
            onPressed: capture,
            padding: EdgeInsets.all(10.0),
            shape: new RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(60.0))),
            // child: new Icon(Imgcrop.camera, size: 40.0, color: Colors.red)
            ),
      ),
      // new Positioned(
      //   bottom: 20.0,
      //   height: 40.0,
      //   width: 40.0,
      //   right: (20.0),
      //   child: new RaisedButton(
      //       onPressed: goToTextListPage,
      //       padding: EdgeInsets.all(10.0),
      //       shape: new RoundedRectangleBorder(
      //           borderRadius: BorderRadius.all(Radius.circular(40.0))),
      //       // child: new Icon(Imgcrop.book, size: 20.0, color: Colors.red)
      //       ),
      // ),
    ]);
  }
///历史记录
  void goToTextListPage() {
    Navigator.push(this.context,
        new MaterialPageRoute(builder: (BuildContext context) {
      return new Scaffold(
          appBar: new AppBar(
            title: new Text("历史记录"),
          ),
          body: new TextListPage());
    }));
  }

  Future<ui.Image?> _loadImage(File img) async {
    if (img != null) {
      var codec = await ui.instantiateImageCodec(img.readAsBytesSync());
      var frame = await codec.getNextFrame();
      return frame.image;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
          child: new Container(
              child: new Column(children: [
        new Expanded(
            child: new Center(
                child: new FutureBuilder(
          future: _buildImage(context),
          builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
            if (snapshot.hasData) {
              return snapshot.data ?? SizedBox();
            } else {
              return new Container();
            }
          },
        ))),
      ]))), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
