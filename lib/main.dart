import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/data/session.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Session.load();

  runApp(
    GetMaterialApp(
      title: "Portal Akademik UNIB",
      initialRoute: Session.isAuthenticated ? Routes.HOME : AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
