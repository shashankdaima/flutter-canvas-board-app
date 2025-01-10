import 'package:canvas_app/providers/canvas_provider.dart';
import 'package:canvas_app/providers/edit_mode_provider.dart';
import 'package:canvas_app/providers/page_content_provider.dart';
import 'package:canvas_app/widgets/drawable_area.dart';
import 'package:canvas_app/widgets/home.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'providers/export_handler_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark, // Ensure brightness matches
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CanvasState()),
          ChangeNotifierProvider(create: (_) => EditModeProvider()),
          ChangeNotifierProvider(create: (_) => PageContentProvider()),
          ChangeNotifierProvider(create: (_) => ExportHandlerProvider()),
        ],
        child: const SafeArea(
          child: Scaffold(body: Home()),
        ),
      ),
    );
  }
}
