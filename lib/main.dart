import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'image_transform.dart';
import 'image_transform_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Image Transformer",
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ImageTransformController? _controller;

  Future<void> _takePicture() async {
    final _picker = ImagePicker();
    final file = await _picker.pickImage(source: ImageSource.camera);

    if (file != null) {
      final imageByte = await file.readAsBytes();
      final controller = ImageTransformController(imageByte: imageByte);

      setState(() => _controller = controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image Transformer"), actions: [
        IconButton(
          onPressed: _takePicture,
          icon: const Icon(Icons.camera_alt_outlined),
        ),
      ]),
      body: _controller == null
          ? Container()
          : ImageTransform(controller: _controller!),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: () async {
                final result = await _controller?.cropImage(context);
                if (result != null) {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Image.memory(result),
                  );
                }
              },
              child: const Text("Crop"),
            ),
          ),
        ),
      ),
    );
  }
}
