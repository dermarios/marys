import 'package:flutter/material.dart';

class PhotoViewerScreen extends StatefulWidget {
  final String photoAsset;
  const PhotoViewerScreen({super.key, required this.photoAsset});

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late TransformationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: InteractiveViewer(
          transformationController: _controller,
          boundaryMargin: const EdgeInsets.all(100),
          minScale: 0.5,
          maxScale: 4,
          child: Center(
            child: Image.asset(
              widget.photoAsset,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Center(
                child: Text(
                  'Erro ao carregar imagem',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}