import 'package:flutter/material.dart';

import 'app.dart';
import 'bridge/native_bridge.dart';
import 'demo/demo_mode.dart';
import 'persistence/local_store.dart';
import 'state/app_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = demoMode
      ? AppController(store: DemoStore(), bridge: DemoBridge())
      : AppController(store: LocalStore(), bridge: NativeBridge());
  await controller.bootstrap();
  runApp(RecenterApp(controller: controller));
}
