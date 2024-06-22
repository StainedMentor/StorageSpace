

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:storagespace/scanner.dart';

class PieSliceData {
  final Color color;
  final double percentage;
  final String label; 
  final int value;  

  PieSliceData({
    required this.color,
    required this.percentage,
    required this.label, 
    required this.value, 
  });
}


class PieChart extends StatefulWidget {
  final List<PieSliceData> slices;
  final double radius;
  final ValueChanged<int> onPressed;

  PieChart({
    required this.slices,
    required this.radius,
    required this.onPressed,
  });

  @override
  _PieChartState createState() => _PieChartState();
}

class _PieChartState extends State<PieChart> {
  int? _hoveredIndex;
  Offset _hoverPosition = Offset.zero;
  @override
  void didUpdateWidget(PieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if slices have changed
    if (widget.slices != oldWidget.slices) {
      // Reset hoveredIndex when slices change
      setState(() {
        _hoveredIndex = null;
      });
    }
  }
  void _onHover(int index, Offset position) {
    setState(() {
      _hoveredIndex = index;
      _hoverPosition = position;
    });
  }

  void _onExit() {
    setState(() {
      _hoveredIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Pie slices
        ..._buildPieSlices(),
        // Hover text
        if (_hoveredIndex != null)
          Positioned(
            left: _hoverPosition.dx,
            top: _hoverPosition.dy,
            child: _buildHoverText(),
          ),
      ],
    );
  }

  List<Widget> _buildPieSlices() {
    List<Widget> widgets = [];

    double startAngle = -pi / 2; // Start from the top
    for (int i = 0; i < widget.slices.length; i++) {
      double sweepAngle = widget.slices[i].percentage * 2 * pi; // Convert percentage to radians

      widgets.add(
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: SliceButton(
              radius: widget.radius,
              startAngle: startAngle,
              sweepAngle: sweepAngle,
              color: widget.slices[i].color,
              onPressed: () {
                widget.onPressed(i);
              },
              onHover: (isHovering, position) {
                if (isHovering) {
                  _onHover(i, position);
                } else {
                  _onExit();
                }
              },
            ),
          ),
        ),
      );

      startAngle += sweepAngle;
    }

    return widgets;
  }

Widget _buildHoverText() {
  final hoveredSlice = widget.slices[_hoveredIndex!];
  return Container(
    padding: EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.7),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Label: ${hoveredSlice.label}',  // Display label
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
        Text(
          'Value: ${formatBytes(hoveredSlice.value, 2)}',  // Display value
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
        Text(
          'Percentage: ${(hoveredSlice.percentage * 100).toStringAsFixed(2)}%', 
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    ),
  );
}
}

class SliceButton extends StatefulWidget {
  final double radius;
  final double startAngle;
  final double sweepAngle;
  final Color color;
  final VoidCallback onPressed;
  final Function(bool isHovering, Offset position) onHover;

  

  SliceButton({
    required this.radius,
    required this.startAngle,
    required this.sweepAngle,
    required this.color,
    required this.onPressed,
        required this.onHover,

  });

  @override
  _SliceButtonState createState() => _SliceButtonState();
}

class _SliceButtonState extends State<SliceButton> {
  bool _isHover = false;
  double ownRad = 100;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ownRad = widget.radius;
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
        child: ClipPath(
          clipper: SliceClipper(
            startAngle: widget.startAngle,
            sweepAngle: widget.sweepAngle,
            radius: ownRad,
          ),
          child:
          MouseRegion(
        onEnter: (details)  {
          _setHover(true, details);
          setState(() {
            ownRad = widget.radius + 10;
          });
          },
        onExit: (_) { _setHover(false, null);
                  setState(() {
            ownRad = widget.radius;
          });},
            
            child:   
           CustomPaint(
            size: Size(ownRad * 2, ownRad * 2),
            painter: SlicePainter(
              startAngle: widget.startAngle,
              sweepAngle: widget.sweepAngle,
              color: _isHover ? widget.color.withOpacity(0.8) : widget.color, // Change color on hover
            ),
            
          ))
      ),
    );
  }

  void _setHover(bool value, PointerEvent? details) {
    setState(() {
      _isHover = value;
    });
    widget.onHover(value, details?.position ?? Offset.zero);
  }


}

class SliceClipper extends CustomClipper<Path> {
  final double startAngle;
  final double sweepAngle;
  final double radius;

  SliceClipper({
    required this.startAngle,
    required this.sweepAngle,
    required this.radius,
  });

  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.moveTo(size.width / 2, size.height / 2);
    path.lineTo(
      size.width / 2 + radius * cos(startAngle),
      size.height / 2 + radius * sin(startAngle),
    );
    path.arcTo(
      Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: radius),
      startAngle,
      sweepAngle,
      false,
    );
    path.lineTo(size.width / 2, size.height / 2);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    // Always reclip for simplicity, or you can add logic to only reclip if angles have changed
    return true;
  }
}

class SlicePainter extends CustomPainter {
  final double startAngle;
  final double sweepAngle;
  final Color color;

  SlicePainter({
    required this.startAngle,
    required this.sweepAngle,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Rect rect = Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2);

    // Correct the arc drawing to fill the slice correctly
    canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Always repaint for simplicity, or add logic to repaint only when necessary
    return true;
  }
}