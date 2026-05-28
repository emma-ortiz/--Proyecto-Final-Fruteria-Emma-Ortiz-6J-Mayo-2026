import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:olivos_verdes/core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.verdeFondo,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                  'https://raw.githubusercontent.com/emma-ortiz/imagenes-flutter/refs/heads/main/olivos.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Olivos Verdes',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.verdeOliva,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Fruta fresca, calidad garantizada',
              style: TextStyle(fontSize: 16, color: AppColors.textoGris),
            ),
          ],
        ),
      ),
    );
  }
}
