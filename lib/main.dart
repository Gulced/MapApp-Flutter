// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui/login_screen.dart';
import 'ui/register_screen.dart';
import 'ui/home_screen.dart';
import 'providers/auth_provider.dart';
import 'viewmodels/auth_viewmodel.dart';

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authVm = ref.watch(authViewModelProvider);
    final status = authVm.status;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Map App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: status == AuthStatus.authenticated
          ? HomeScreen()
          : LoginScreen(),
      routes: {
        '/login': (_) => LoginScreen(),
        '/register': (_) => RegisterScreen(),
        '/home': (_) => HomeScreen(),
      },
    );
  }
}
