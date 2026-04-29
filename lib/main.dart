import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/datasources/progress_data_source.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait – best experience for this game.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Immersive status bar without hiding it.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Open Hive box before app starts. Swallow failures on web (e.g. private
  // browsing or browser storage blocked) so the app still launches.
  try {
    await ProgressDataSource.init();
  } catch (e, st) {
    debugPrint('Hive init failed – progress will not persist: $e\n$st');
  }

  runApp(
    const ProviderScope(
      child: BottleSortApp(),
    ),
  );
}
