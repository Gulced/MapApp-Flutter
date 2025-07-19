// lib/ui/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class RegisterScreen extends ConsumerWidget {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(authViewModelProvider);

    // Kayıt durumunu dinle
    ref.listen<AuthViewModel>(authViewModelProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated) {
        // Kayıt başarılıysa giriş sayfasına dön
        Navigator.pushReplacementNamed(context, '/login');
      } else if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? 'Bir hata oluştu')),
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Gradient arka plan
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade300],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Formu ortala
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo veya başlık
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: FlutterLogo(size: 72),
                      ),
                      Text(
                        'Hesap Oluştur',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Yeni hesabınızı oluşturun',
                        style: TextStyle(color: Colors.blueGrey.shade600),
                      ),
                      SizedBox(height: 24),
                      // Email alanı
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      // Şifre alanı
                      TextField(
                        controller: _passCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          labelText: 'Şifre',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      // Kayıt butonu
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: vm.status == AuthStatus.loading
                            ? Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 4,
                          ),
                          onPressed: () {
                            vm.register(
                              _emailCtrl.text.trim(),
                              _passCtrl.text.trim(),
                            );
                          },
                          child: Text(
                            'Kayıt Ol',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      // Hata mesajı (ekran altı)
                      if (vm.status == AuthStatus.error)
                        Text(
                          vm.errorMessage ?? '',
                          style: TextStyle(color: Colors.red),
                        ),
                      SizedBox(height: 8),
                      // Giriş sayfasına dön
                      TextButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/login'),
                        child: Text(
                          'Zaten hesabın var mı? Giriş yap',
                          style: TextStyle(color: Colors.blueGrey.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
