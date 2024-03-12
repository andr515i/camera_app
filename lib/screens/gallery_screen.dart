import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:camera_app/providers/camera_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late Future<List<Uint8List>> _loadPicturesFuture;
  List<Uint8List> _pictures = [];
  late Image _emptyPicture;

  @override
  void initState() {
    super.initState();
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    _loadPicturesFuture = cameraProvider.loadAllPictures();
    _loadPicturesFuture.then((pictures) {
      setState(() {
        _pictures = pictures;
        _emptyPicture = const Image(image: AssetImage("images/empty.png"));
      });
    });
  }

  void _removePicture(Uint8List pictureBytes) {
    setState(() {
      _pictures.remove(pictureBytes);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
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
                      builder: (context, acceptedData, rejectedData) {
                        return DottedBorder(
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(12),
                            padding: const EdgeInsets.all(6),
                            color: Colors.grey,
                            strokeWidth: 2,
                            dashPattern: const [8],
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                  height: 200,
                                  width: 200,
                                  // child: Image.asset("empty.png")
                                  child: _emptyPicture),
                            ));
                      },
                      onAcceptWithDetails: (data) {
                        _emptyPicture = Image.memory(data.data);
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
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final pictureBytes = _pictures[index];
                              return LongPressDraggable(
                                data: pictureBytes,
                                feedback: Image.memory(pictureBytes),
                                child: Image.memory(pictureBytes),
                                onDragEnd: (details) {
                                  if (details.wasAccepted) {
                                    _removePicture(pictureBytes);
                                  }
                                },
                              );
                            },
                            childCount: _pictures.length,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 25,
                            crossAxisSpacing: 25,
                            childAspectRatio: 1,
                          ),
                        ),
                      ),
                    ],
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
