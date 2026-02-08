import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:diary/providers/settings_provider.dart';
import 'package:diary/screens/home_screen.dart';
import 'package:diary/services/settings_service.dart';

class DiaryApp extends StatefulWidget {
  final SettingsService settingsService;

  const DiaryApp({super.key, required this.settingsService});

  @override
  State<DiaryApp> createState() => _DiaryAppState();
}

class _DiaryAppState extends State<DiaryApp> with WindowListener {
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    windowManager.setPreventClose(true);
    // Periodically save geometry as fallback since Linux window events
    // are unreliable.
    _saveTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _saveGeometry(),
    );
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _saveGeometry() async {
    final position = await windowManager.getPosition();
    final size = await windowManager.getSize();
    await widget.settingsService.setWindowGeometry(
      position.dx,
      position.dy,
      size.width,
      size.height,
    );
  }

  @override
  void onWindowClose() async {
    await _saveGeometry();
    await windowManager.destroy();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final localeParts = settings.effectiveLocale.split('_');
    final locale = Locale(localeParts[0], localeParts.length > 1 ? localeParts[1] : null);

    return MaterialApp(
      title: 'Diary',
      debugShowCheckedModeBanner: false,
      locale: locale,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const HomeScreen(),
    );
  }
}
