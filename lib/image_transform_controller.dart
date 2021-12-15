import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_lib;

class _ProcessCropImageValue {
  final Uint8List imageByte;
  final List<Offset> points;
  final double areaWidth;
  final double areaHeight;

  _ProcessCropImageValue({
    required this.imageByte,
    required this.points,
    required this.areaWidth,
    required this.areaHeight,
  });
}

class ImageTransformController extends ChangeNotifier {
  ImageTransformController({required Uint8List imageByte}) {
    _imageByte = imageByte;
  }

  late Uint8List _imageByte;
  Uint8List get imageByte => _imageByte;

  List<Offset> _points = [];

  double? _areaWidth;
  double? _areaHeight;

  set points(List<Offset> value) {
    _points = value;
    notifyListeners();
  }

  set areaWidth(double areaWidth) => _areaWidth = areaWidth;
  set areaHeight(double areaHeight) => _areaHeight = areaHeight;

  Future<Uint8List> cropImage(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final result = await compute<_ProcessCropImageValue, List<int>>(
      _processCropImage,
      _ProcessCropImageValue(
        imageByte: _imageByte,
        points: _points,
        areaWidth: _areaWidth!,
        areaHeight: _areaHeight!,
      ),
    );

    Navigator.of(context).pop();
    return Uint8List.fromList(result);
  }

  static List<int> _processCropImage(_ProcessCropImageValue value) {
    final image = image_lib.decodeImage(value.imageByte)!;
    final areaAspectRatio = value.areaWidth / value.areaHeight;

    image_lib.Image? croppedImage;
    if (image.height > image.width) {
      final newHeight = image.width / areaAspectRatio;
      croppedImage = image_lib.copyCrop(
        image,
        0,
        (image.height / 2 - newHeight / 2).toInt(),
        image.width,
        newHeight.toInt(),
      );
    } else {
      final newWidth = image.height * areaAspectRatio;
      croppedImage = image_lib.copyCrop(
        image,
        (image.width / 2 - newWidth / 2).toInt(),
        0,
        newWidth.toInt(),
        image.height,
      );
    }

    final widthRatio = croppedImage.width / value.areaWidth;
    final heightRatio = croppedImage.height / value.areaHeight;

    final transformedImage = image_lib.copyRectify(
      croppedImage,
      topLeft: image_lib.Point(
        value.points[0].dx * widthRatio,
        value.points[0].dy * heightRatio,
      ),
      topRight: image_lib.Point(
        value.points[1].dx * widthRatio,
        value.points[1].dy * heightRatio,
      ),
      bottomRight: image_lib.Point(
        value.points[2].dx * widthRatio,
        value.points[2].dy * heightRatio,
      ),
      bottomLeft: image_lib.Point(
        value.points[3].dx * widthRatio,
        value.points[3].dy * heightRatio,
      ),
    );

    return image_lib.writePng(image_lib.flipVertical(transformedImage));
  }

  @override
  void dispose() {
    _points.clear();
    super.dispose();
  }
}
