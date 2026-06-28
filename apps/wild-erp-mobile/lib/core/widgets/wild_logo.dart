import 'package:flutter/material.dart';

class WildLogo extends StatelessWidget {
  final double size;

  const WildLogo({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.4,
      child: CustomPaint(
        painter: _WildLogoPainter(),
      ),
    );
  }
}

class _WildLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC98300)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04;

    final fillPaint = Paint()
      ..color = const Color(0xFFC98300)
      ..style = PaintingStyle.fill;

    final scale = size.width / 200;
    final ox = 0.0;
    final oy = 0.0;

    // Helper to scale points
    double sX(double x) => ox + x * scale;
    double sY(double y) => oy + y * scale;

    // Head (diamond shape)
    final headPath = Path()
      ..moveTo(sX(100), sY(20))
      ..lineTo(sX(160), sY(80))
      ..lineTo(sX(160), sY(160))
      ..lineTo(sX(100), sY(200))
      ..lineTo(sX(40), sY(160))
      ..lineTo(sX(40), sY(80))
      ..close();
    canvas.drawPath(headPath, paint);

    // Left eye
    canvas.drawLine(
      Offset(sX(60), sY(100)),
      Offset(sX(85), sY(110)),
      paint,
    );

    // Right eye
    canvas.drawLine(
      Offset(sX(115), sY(110)),
      Offset(sX(140), sY(100)),
      paint,
    );

    // Mouth
    final mouthPath = Path()
      ..moveTo(sX(90), sY(135))
      ..quadraticBezierTo(sX(100), sY(145), sX(110), sY(135));
    final mouthPaint = Paint()
      ..color = const Color(0xFFC98300)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.03;
    canvas.drawPath(mouthPath, mouthPaint);

    // Neck line
    canvas.drawLine(
      Offset(sX(100), sY(200)),
      Offset(sX(100), sY(230)),
      paint,
    );

    // Bottom circle (moon/sun)
    canvas.drawCircle(Offset(sX(100), sY(255)), sY(20), fillPaint);

    // Moon crescent details
    final bgPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(sX(108), sY(250)), sY(16), bgPaint);
    canvas.drawCircle(Offset(sX(95), sY(260)), sY(18), bgPaint);

    // Decorative X
    canvas.drawLine(
      Offset(sX(30), sY(235)),
      Offset(sX(50), sY(255)),
      paint,
    );
    canvas.drawLine(
      Offset(sX(50), sY(235)),
      Offset(sX(30), sY(255)),
      paint,
    );

    // Decorative Z
    canvas.drawLine(
      Offset(sX(155), sY(240)),
      Offset(sX(180), sY(240)),
      paint,
    );
    canvas.drawLine(
      Offset(sX(180), sY(240)),
      Offset(sX(155), sY(270)),
      paint,
    );
    canvas.drawLine(
      Offset(sX(155), sY(270)),
      Offset(sX(180), sY(270)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
