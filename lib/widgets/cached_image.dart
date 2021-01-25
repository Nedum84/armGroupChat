import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';


const NO_IMAGE = "https://www.esm.rochester.edu/uploads/NoPhotoAvailable.jpg";

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final bool isRound;
  final double radius;
  final double height;
  final double width;

  final BoxFit fit;
  final ImagePlaceholder alt;

  CachedImage(
    this.imageUrl, {
    this.isRound = false,
    this.radius = 0,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.alt = ImagePlaceholder.NoImage,
  });

  @override
  Widget build(BuildContext context) {


    try {
      return SizedBox(
        height: isRound ? radius : height,
        width: isRound ? radius : width,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(isRound ? 50 : radius),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: fit,
              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => ClipRRect(
                borderRadius: BorderRadius.circular(isRound ? 50 : radius),
                child: Image.network(
                  NO_IMAGE,
                  height: isRound ? radius : height,
                  width: isRound ? radius : width,
                  fit: fit,
                ),
              ),
            ),),
      );
    } catch (e) {
      print(e);
      return ClipRRect(
        borderRadius: BorderRadius.circular(isRound ? 50 : radius),
        child: Image.network(
          NO_IMAGE,
          height: isRound ? radius : height,
          width: isRound ? radius : width,
          fit: fit,
        ),
      );
    }
  }
}

enum ImagePlaceholder { QuestionMark, NoImage, User }
