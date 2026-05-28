import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:olivos_verdes/core/constants/app_colors.dart';
import 'package:olivos_verdes/core/constants/app_strings.dart';
import 'package:olivos_verdes/core/widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.verdeFondo,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                const SizedBox(height: 50),
                const Text(
                  AppStrings.bienvenido,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.verdeOliva,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  height: 180,
                  width: 180,
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
                const SizedBox(height: 40),
                const Text(
                  AppStrings.appName,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.verdeOliva,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  AppStrings.tagline,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: AppColors.textoGris),
                ),
                const SizedBox(height: 40),
                CustomButton(
                  text: 'Menú Virtual',
                  onPressed: () => context.push('/menu'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.push('/login'),
                  child: const Text(
                    AppStrings.iniciarSesion,
                    style: TextStyle(
                      color: AppColors.verdeOliva,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
