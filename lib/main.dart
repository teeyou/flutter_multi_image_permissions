import 'package:flutter/material.dart';

import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Asset> images;
  String _error;

  @override
  void initState() {
    super.initState();
  }

  Widget buildGridView(List<Asset> images) {
    if(images != null ) {
      return GridView.count(
        crossAxisCount: 3,
        children: List.generate(images.length, (index) {
          Asset asset = images[index];
          return AssetThumb(
            asset: asset,
            width: 300,
            height: 300,
          );
        }),
      );
    }
   else {
     return Placeholder();
    }
  }

  Future<bool> checkPermission() async {
    PermissionStatus permission_camera = await PermissionHandler().checkPermissionStatus(PermissionGroup.camera);
    PermissionStatus permission_storage = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);

    print('check1 : $permission_camera');
    print('check2 : $permission_storage');

    if(permission_camera == PermissionStatus.granted && permission_storage == PermissionStatus.granted)
      return true;
    else
      return false;
  }

  void requestPermission() async {

    Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.camera, PermissionGroup.storage]);
    print('request : $permissions');

  }

  Future<void> loadAssets() async {

    bool check = await checkPermission();

    if(check) {
      print("1");
      setState(() {
        images = List<Asset>();
      });

      print("2");
      List<Asset> resultList;
      String error;

      try {
        resultList = await MultiImagePicker.pickImages(
          maxImages: 300,
        );
        print("3");
      } on Exception catch (e) {

        error = e.toString();
        print("4");
      }

      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
      if (!mounted) return;

      setState(() {
        print("5");
        images = resultList;
        if (error == null) _error = 'No Error Dectected';
        print("6");
      });
    } else {
      requestPermission();
    }

  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: <Widget>[
            Center(child: Text('Error: $_error')),
            RaisedButton(
              child: Text("Pick images"),
              onPressed: loadAssets,
            ),
            Expanded(
              child: buildGridView(images),
            )
          ],
        ),
      ),
    );
  }
}