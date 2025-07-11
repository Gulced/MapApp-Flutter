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

    ref.listen<AuthViewModel>(authViewModelProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated) {
        Navigator.pushReplacementNamed(context, '/login');
      } else if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? 'Bir hata oluştu')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text('Kayıt Ol')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _emailCtrl, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _passCtrl, decoration: InputDecoration(labelText: 'Şifre'), obscureText: true),
            SizedBox(height: 20),
            vm.status == AuthStatus.loading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () => vm.register(_emailCtrl.text.trim(), _passCtrl.text.trim()),
              child: Text('Kayıt Ol'),
            ),
            if (vm.status == AuthStatus.error) ...[
              SizedBox(height: 12),
              Text(vm.errorMessage ?? '', style: TextStyle(color: Colors.red)),
            ],
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              child: Text('Zaten hesabın var mı? Giriş yap'),
            ),
          ],
        ),
      ),
    );
  }
}
