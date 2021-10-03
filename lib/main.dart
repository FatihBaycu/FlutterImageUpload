import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class MyHttpOverrides extends HttpOverrides {

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Dio dio=new Dio();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=>uploadImage(),
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  uploadImage()async{
    File? image;
    var imagePicker=await ImagePicker().pickImage(source: ImageSource.gallery);
    if(imagePicker!=null){
      setState(() {
        image=File(imagePicker.path);
      });
    }

    try{
      String fileName=image!.path.split("/").last;
      print(fileName);
      FormData formData=new FormData.fromMap({
        //backend variableName - 1 /imagePath=>IMAGE
        "imagePath":
        await MultipartFile.fromFile(image!.path,filename: fileName,
            contentType: MediaType("image","jpg")),
        "type":"image/jpg",
        //backend variableName - 2 /carId=> Car ID
        "carId":4
      });

      String accessToken="ACCESS_TOKEN";


      Response response=await dio.post(
        "https://10.0.2.2:5001/api/carimages/add",
        data: formData,
        options: Options(
          headers: {
            "accept":"*/*",
            "Authorization":"Bearer $accessToken",
            "Content-Type":"multipart/form-data"
          },
        ),
      );
    }
    catch(e){
      print(e);
    }

  }
}
