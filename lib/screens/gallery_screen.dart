import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:camera_app/providers/camera_provider.dart';
import 'package:provider/provider.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late Future<List<Uint8List>> _loadPicturesFuture;

  @override
  void initState() {
    super.initState();
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    _loadPicturesFuture = cameraProvider.loadAllPictures();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gallery')),
      body: Stack(
        children: [
          FutureBuilder<List<Uint8List>>(
            future: _loadPicturesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (snapshot.hasData) {
                final pictures = snapshot.data!;
                return GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 25,
                  children: pictures.map((pictureBytes) {
                    return DragTarget<Uint8List>(
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          child: Image.memory(pictureBytes),
                        );
                      },
                      onAcceptWithDetails: (data) {
                        // Handle the dropped image here
                      },
                    );
                  }).toList(),
                );
              } else {
                return const Center(
                  child: Text('No pictures found.'),
                );
              }
            },
          ),
          Positioned(
            bottom: 0,
            top: 0,
            left: 0,
            right: 0,
            child: DraggableScrollableSheet(
              minChildSize: 0.1,
              maxChildSize: 0.9,
              initialChildSize: 0.1,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: FutureBuilder<List<Uint8List>>(
                    future: _loadPicturesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else if (snapshot.hasData) {
                        final pictures = snapshot.data!;
                        return GridView.count(
                          controller: scrollController,
                          crossAxisCount: 3,
                          mainAxisSpacing: 25,
                          children: pictures.map((pictureBytes) {
                            return Draggable(
                              data: pictureBytes,
                              feedback: Image.memory(pictureBytes),
                              child: Image.memory(pictureBytes),
                            );
                          }).toList(),
                        );
                      } else {
                        return const Center(
                          child: Text('No pictures found.'),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
