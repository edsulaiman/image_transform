import 'package:flutter/material.dart';

import 'image_transform_controller.dart';

class ImageTransform extends StatefulWidget {
  const ImageTransform({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final ImageTransformController controller;

  @override
  State<ImageTransform> createState() => _ImageTransformState();
}

class _ImageTransformState extends State<ImageTransform> {
  Offset? _point1;
  Offset? _point2;
  Offset? _point3;
  Offset? _point4;

  bool _isPoint1Moving = false;
  bool _isPoint2Moving = false;
  bool _isPoint3Moving = false;
  bool _isPoint4Moving = false;

  Size? size;

  Future<void> _sizeNotifier(Size size) async {
    if (this.size != size) {
      this.size = size;

      final dxCenter = size.width / 2;
      final dyCenter = size.height / 2;

      await Future.delayed(Duration.zero, () {
        setState(() {
          _point1 = Offset(dxCenter - 50, dyCenter + 50);
          _point2 = Offset(dxCenter + 50, dyCenter + 50);
          _point3 = Offset(dxCenter + 50, dyCenter - 50);
          _point4 = Offset(dxCenter - 50, dyCenter - 50);
        });
      });

      widget.controller.areaHeight = size.height;
      widget.controller.areaWidth = size.width;
      widget.controller.points = [_point1!, _point2!, _point3!, _point4!];
    }
  }

  void _onPanStart(DragStartDetails details) {
    final _point1Radius = Rect.fromCircle(center: _point1!, radius: 16);
    final _point2Radius = Rect.fromCircle(center: _point2!, radius: 16);
    final _point3Radius = Rect.fromCircle(center: _point3!, radius: 16);
    final _point4Radius = Rect.fromCircle(center: _point4!, radius: 16);

    if (_point1Radius.contains(details.localPosition)) {
      _isPoint1Moving = true;
      return;
    } else if (_point2Radius.contains(details.localPosition)) {
      _isPoint2Moving = true;
    } else if (_point3Radius.contains(details.localPosition)) {
      _isPoint3Moving = true;
    } else if (_point4Radius.contains(details.localPosition)) {
      _isPoint4Moving = true;
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final boundary = Rect.fromLTRB(0, 0, size!.width, size!.height);

    if (boundary.contains(details.localPosition)) {
      if (_isPoint1Moving == true) {
        setState(
          () => _point1 = Offset(
            details.localPosition.dx,
            details.localPosition.dy,
          ),
        );
      } else if (_isPoint2Moving == true) {
        setState(
          () => _point2 = Offset(
            details.localPosition.dx,
            details.localPosition.dy,
          ),
        );
      } else if (_isPoint3Moving == true) {
        setState(
          () => _point3 = Offset(
            details.localPosition.dx,
            details.localPosition.dy,
          ),
        );
      } else if (_isPoint4Moving == true) {
        setState(
          () => _point4 = Offset(
            details.localPosition.dx,
            details.localPosition.dy,
          ),
        );
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    _isPoint1Moving = false;
    _isPoint2Moving = false;
    _isPoint3Moving = false;
    _isPoint4Moving = false;

    widget.controller.points = [_point1!, _point2!, _point3!, _point4!];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: CustomPaint(
          foregroundPainter: _ShapePainter(
            point1: _point1,
            point2: _point2,
            point3: _point3,
            point4: _point4,
            sizeNotifier: _sizeNotifier,
          ),
          child: Image.memory(
            widget.controller.imageByte,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  _ShapePainter({
    required this.point1,
    required this.point2,
    required this.point3,
    required this.point4,
    required this.sizeNotifier,
  });

  final Offset? point1;
  final Offset? point2;
  final Offset? point3;
  final Offset? point4;
  final void Function(Size size) sizeNotifier;

  @override
  void paint(Canvas canvas, Size size) {
    sizeNotifier(size);

    if (point1 == null || point2 == null || point3 == null || point4 == null) {
      return;
    }

    final dotPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final linepathPaint = Paint()
      ..color = Colors.red.withOpacity(.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final linePath = Path()
      ..moveTo(point1!.dx, point1!.dy)
      ..lineTo(point2!.dx, point2!.dy)
      ..lineTo(point3!.dx, point3!.dy)
      ..lineTo(point4!.dx, point4!.dy)
      ..close();

    canvas
      ..drawCircle(point1!, 8, dotPaint)
      ..drawCircle(point2!, 8, dotPaint)
      ..drawCircle(point3!, 8, dotPaint)
      ..drawCircle(point4!, 8, dotPaint)
      ..drawPath(linePath, linepathPaint);
  }

  @override
  bool shouldRepaint(_ShapePainter oldDelegate) {
    return true;
  }
}
