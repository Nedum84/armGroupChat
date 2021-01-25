import 'dart:io';
import 'package:flutter/material.dart';
import 'cached_image.dart';

class ViewImage extends StatefulWidget {
  final String imageUrl;

  ViewImage({@required this.imageUrl});
  @override
  _ViewImageState createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  String _imageUrl;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            child: CachedImage(
              _imageUrl,
              fit: BoxFit.contain,
              height: double.infinity,
              width: double.infinity,
            ),
          ),

          Positioned(
            top: 45,
            left: 20,
            child: IconButton(
              onPressed: () =>
                  Navigator.pop(context),
              icon: Icon(Icons.arrow_back),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
