import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'edit_mode_provider.dart';

class PageContent extends StatelessWidget {
  const PageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final currentMode = Provider.of<EditModeProvider>(context).currentMode;
    // print('Current Edit Mode: ${currentMode ?? 'None'}');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
         currentMode?.toString().split('.').last ?? "None",
          // style: theme.textTheme.bodyLarge?.copyWith(
          //   color: Colors.black,
          // ),
        ),
      ),
    );
  }
}
