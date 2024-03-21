import 'dart:convert';
import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:camera_app/providers/camera_provider.dart';
import 'package:provider/provider.dart';

// Defines the GalleryScreen widget that displays a grid of draggable images.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  GalleryScreenState createState() => GalleryScreenState();
}

// A StatelessWidget that displays an image which can be dragged.
class MyDraggablePicture extends StatelessWidget {
  const MyDraggablePicture({super.key, required this.picture});

  final Uint8List picture; // The binary data for the image.

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: LongPressDraggable<Uint8List>(
        data: picture,
        feedback: Image.memory(
          picture,
          height: 150, // Set the height for the draggable image feedback.
        ),
        child: Container(
          alignment: Alignment.center,
          height: 150, // Set the height for the draggable image in the gallery.
          padding: const EdgeInsets.all(12),
          child: Image.memory(picture), // Display the image from binary data.
        ),
      ),
    );
  }
}

// State class for GalleryScreen that handles loading and displaying images.
class GalleryScreenState extends State<GalleryScreen> {
  late Future<List<Uint8List>> _loadPicturesFuture; // Future to load pictures.
  List<Uint8List> _pictures = []; // List of pictures as Uint8List.
  final Map<int, Uint8List?> _draggedPictures = {}; // Tracks dragged pictures.

  @override
  void initState() {
    super.initState();
    // Access the CameraProvider to fetch pictures.
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    // Load all pictures and update the state when complete.
    _loadPicturesFuture = cameraProvider.loadAllPictures();
    _loadPicturesFuture.then((pictures) {
      setState(() {
        _pictures = pictures; // Update the pictures list.
      });
    });
  }

  // Builds a widget that acts as a drop target for draggable pictures.
  Widget _buildDragTarget(int index, Uint8List picture) {
    final encodedPicture = base64Encode(picture); // Encode picture to Base64.
    final draggedPicture = _draggedPictures[index]; // Retrieve dragged picture if exists.

    return DragTarget<Uint8List>(
      builder: (context, incoming, rejected) {
        if (draggedPicture != null && base64Encode(draggedPicture) == encodedPicture) {
          debugPrint("Dragged picture matched");
          // Display the dragged picture if it matches the target.
          return Container(
            color: Colors.white,
            height: 150,
            width: 150,
            alignment: Alignment.center,
            child: MyDraggablePicture(picture: picture),
          );
        } else {
          debugPrint("No matched picture dragged");
          // Display a dotted border container when no matching picture is dragged.
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
                height: 150,
                width: double.infinity,
                child: Image.asset("images/empty.png", fit: BoxFit.fill,), // Placeholder image.
              ),
            ),
          );
        }
      },
      onWillAcceptWithDetails: (data) {
        // return base64Encode(data.data) == encodedPicture; // Accept only if pictures match.
        return true;
      },
      onAcceptWithDetails: (data) {
        setState(() {
          _draggedPictures[index] = data.data; // Update the state with the dragged picture.
        });
        debugPrint("Drag accepted");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')), // AppBar with title.
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(children: [
            Expanded(
              child: Stack(
                children: [
                  // Build list of images using FutureBuilder.
                  FutureBuilder<List<Uint8List>>(
                    future: _loadPicturesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: _pictures.length,
                          itemBuilder: (context, index) {
                            final pictureBytes = _pictures[index];
                            return _buildDragTarget(index, pictureBytes); // Build draggable targets.
                          },
                        );
          
                      } else {
                        return const Center(child: Text('No pictures found.'));
                      }
                    },
                  ),
                  // DraggableScrollableSheet for additional UI or functionality.
                  Positioned(
                    bottom: 0,
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: constraints.maxHeight,
                      child: DraggableScrollableSheet(
                        minChildSize: 0.3,
                        maxChildSize: 0.3,
                        initialChildSize: 0.3,
                        builder: (context, scrollController) {
                          return Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              controller: scrollController,
                              itemCount: _pictures.length,
                              itemBuilder: (context, index) {
                                final pictureBytes = _pictures[index];
                                return MyDraggablePicture(picture: pictureBytes); // Display draggable pictures.
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]);
        },
      ),
    );
  }
}
