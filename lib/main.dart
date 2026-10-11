import 'package:flutter/material.dart';

import 'app.dart';
import 'bridge/native_bridge.dart';
import 'persistence/local_store.dart';
import 'state/app_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = LocalStore();
  final controller = AppController(store: store, bridge: NativeBridge());
  await controller.bootstrap();
  runApp(ReThinkApp(controller: controller));
}
