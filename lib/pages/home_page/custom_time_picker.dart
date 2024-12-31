import 'dart:math';
import 'package:flutter/material.dart';

class Custom24HourTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeSelected;

  const Custom24HourTimePicker({
    Key? key,
    required this.initialTime,
    required this.onTimeSelected,
  }) : super(key: key);

  @override
  _Custom24HourTimePickerState createState() => _Custom24HourTimePickerState();
}

class _Custom24HourTimePickerState extends State<Custom24HourTimePicker> {
  late int _selectedHour;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hour;
  }

  void _updateHourFromPosition(Offset position, Offset center, Size size) {
    final radius = min(size.width, size.height) / 2;
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;
    
    // 터치 위치가 시계 원 안에 있는지 확인
    if (dx * dx + dy * dy > radius * radius) {
      return;
    }

    // 각도 계산 (12시 방향이 0도)
    var angle = (atan2(dy, dx) * 180 / pi + 90);
    if (angle < 0) angle += 360;
    
    // 각도를 시간으로 변환 (15도당 1시간)
    final newHour = ((angle + 7.5) / 15).floor() % 24;
    
    if (newHour != _selectedHour) {
      setState(() {
        _selectedHour = newHour;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 300,
              width: 300,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onTapDown: (details) {
                      final RenderBox renderBox = context.findRenderObject() as RenderBox;
                      final position = renderBox.globalToLocal(details.globalPosition);
                      final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
                      _updateHourFromPosition(position, center, Size(constraints.maxWidth, constraints.maxHeight));
                    },
                    onPanStart: (details) {
                      final RenderBox renderBox = context.findRenderObject() as RenderBox;
                      final position = renderBox.globalToLocal(details.globalPosition);
                      final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
                      _updateHourFromPosition(position, center, Size(constraints.maxWidth, constraints.maxHeight));
                    },
                    onPanUpdate: (details) {
                      final RenderBox renderBox = context.findRenderObject() as RenderBox;
                      final position = renderBox.globalToLocal(details.globalPosition);
                      final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
                      _updateHourFromPosition(position, center, Size(constraints.maxWidth, constraints.maxHeight));
                    },
                    child: CustomPaint(
                      painter: Clock24HourPainter(
                        selectedHour: _selectedHour,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              '${_selectedHour.toString().padLeft(2, '0')}시',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    widget.onTimeSelected(TimeOfDay(
                      hour: _selectedHour,
                      minute: 0,
                    ));
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                  child: Text('확인'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Clock24HourPainter extends CustomPainter {
  final int selectedHour;

  Clock24HourPainter({
    required this.selectedHour,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // 시계 테두리 그리기
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, borderPaint);

    // 시간 숫자 그리기
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < 24; i++) {
      final angle = (i - 6) * (2 * pi / 24);
      final offset = Offset(
        center.dx + (radius - 30) * cos(angle),
        center.dy + (radius - 30) * sin(angle),
      );

      textPainter.text = TextSpan(
        text: i.toString(),
        style: TextStyle(
          color: i == selectedHour ? Colors.blue : Colors.black,
          fontSize: 16,
          fontWeight: i == selectedHour ? FontWeight.bold : FontWeight.normal,
        ),
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          offset.dx - textPainter.width / 2,
          offset.dy - textPainter.height / 2,
        ),
      );
    }

    // 시침 그리기
    final hourPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4;

    final hourAngle = (selectedHour - 6) * (2 * pi / 24);
    canvas.drawLine(
      center,
      Offset(
        center.dx + (radius - 40) * cos(hourAngle),
        center.dy + (radius - 40) * sin(hourAngle),
      ),
      hourPaint,
    );
  }

  @override
  bool shouldRepaint(Clock24HourPainter oldDelegate) {
    return oldDelegate.selectedHour != selectedHour;
  }
}
