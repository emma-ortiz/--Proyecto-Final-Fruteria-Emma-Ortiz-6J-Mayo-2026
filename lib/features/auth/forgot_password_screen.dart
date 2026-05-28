import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:olivos_verdes/core/constants/app_colors.dart';
import 'package:olivos_verdes/core/widgets/custom_button.dart';
import 'package:olivos_verdes/providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa tu correo')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.sendPasswordReset(email);
    if (success && mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Recuperar contraseña'),
        backgroundColor: AppColors.verdeOliva,
      ),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_sent)
              Column(
                children: [
                  const Icon(Icons.check_circle, size: 80, color: AppColors.verdeOliva),
                  const SizedBox(height: 20),
                  const Text(
                    'Correo enviado',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.verdeOliva),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Revisa tu bandeja de entrada y sigue las instrucciones',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: AppColors.textoGris),
                  ),
                  const SizedBox(height: 30),
                  CustomButton(
                    text: 'Volver al inicio de sesión',
                    onPressed: () => context.go('/login'),
                  ),
                ],
              )
            else
              Column(
                children: [
                  const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.verdeOliva),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Ingresa tu correo y te enviaremos un enlace para restablecerla',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: AppColors.textoGris),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'Correo'),
                  ),
                  const SizedBox(height: 30),
                  Consumer<AuthProvider>(
                    builder: (_, auth, __) {
                      return CustomButton(
                        text: 'Enviar correo de recuperación',
                        onPressed: auth.loading ? null : _sendResetEmail,
                        loading: auth.loading,
                      );
                    },
                  ),
                  TextButton(
                    onPressed: () => context.push('/login'),
                    child: const Text(
                      'Volver al inicio de sesión',
                      style: TextStyle(color: Colors.black, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
