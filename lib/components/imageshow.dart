import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImageScreen extends StatefulWidget {
  final String imageUrl;
  const FullScreenImageScreen({Key? key, required this.imageUrl})
      : super(key: key);
  @override
  FullScreenImageScreenState createState() => FullScreenImageScreenState();
}

class FullScreenImageScreenState extends State<FullScreenImageScreen> {
  double _scale = 1;
  double _previousScale = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onScaleStart: (ScaleStartDetails details) {
          _previousScale = _scale;
          setState(() {});
        },
        onScaleUpdate: (ScaleUpdateDetails details) {
          setState(() {
            _scale = _previousScale * details.scale;
          });
        },
        onScaleEnd: (ScaleEndDetails details) {
          _previousScale = 1.0;
          setState(() {});
        },
        child: Hero(
          tag: widget.imageUrl,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: PhotoView(
              imageProvider: NetworkImage(widget.imageUrl),
              minScale: PhotoViewComputedScale.contained * 0.8,
              maxScale: PhotoViewComputedScale.covered * 2,
              initialScale: PhotoViewComputedScale.contained,
              backgroundDecoration: const BoxDecoration(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
