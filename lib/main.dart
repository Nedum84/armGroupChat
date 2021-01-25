import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/image_upload_provider.dart';
import 'screen/login/login_register.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
      ],
      child: MaterialApp(
        title: 'ARG Group Chat',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: LoginRegister(),
      ),
    );
  }

}
