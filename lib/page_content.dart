import 'package:flutter/material.dart';

class PageContent extends StatelessWidget {
  const PageContent({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Drawing Area',
          // style: theme.textTheme.bodyLarge?.copyWith(
          //   color: Colors.black,
          // ),
        ),
      ),
    );
  }
}
