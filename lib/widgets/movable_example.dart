import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:movable/movable.dart";

class MovableExample extends StatefulWidget {
  const MovableExample({super.key, required this.title});

  final String title;

  @override
  State<MovableExample> createState() => _MovableExampleState();
}

class _MovableExampleState extends State<MovableExample> {
  MovableInfo info = MovableInfo(
    size: const Size(100, 100),
    position: const Offset(10, 10),
    rotateAngle: 0,
  );
  bool isSelected = true;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CraftorMovable(
          isSelected: isSelected,
          keepRatio: RawKeyboard.instance.keysPressed
              .contains(LogicalKeyboardKey.shiftLeft),
          scale: 1,
          scaleInfo: info,
          onTapInside: () => setState(() => isSelected = true),
          onTapOutside: (details) => setState(() => isSelected = false),
          onChange: (newInfo) => setState(() => info = newInfo),
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: TextField(
              maxLines: null,
              expands: true,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(8.0),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        )
      ],
    );
  }
}
