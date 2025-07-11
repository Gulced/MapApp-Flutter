// lib/ui/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Göreli import: viewmodels ve providers klasörleriniz lib/ altında olmalı
import '../viewmodels/auth_viewmodel.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends ConsumerWidget {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Burada AuthViewModel örneğini alıyoruz
    final authVm = ref.watch(authViewModelProvider);

    ref.listen<AuthViewModel>(authViewModelProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated) {
        // Giriş başarılıysa HomeScreen'e geç
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } else if (next.status == AuthStatus.error) {
        // Hata varsa kullanıcıya göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text('Giriş Yap')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailCtrl,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passCtrl,
              decoration: InputDecoration(labelText: 'Şifre'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            authVm.status == AuthStatus.loading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () {
                authVm.login(
                  _emailCtrl.text.trim(),
                  _passCtrl.text.trim(),
                );
              },
              child: Text('Giriş'),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RegisterScreen()),
              ),
              child: Text('Hesabın yok mu? Kayıt ol'),
            ),
          ],
        ),
      ),
    );
  }
}
