import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:olivos_verdes/core/constants/app_colors.dart';
import 'package:olivos_verdes/providers/category_provider.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      body: Consumer<CategoryProvider>(
        builder: (_, catProvider, __) {
          if (catProvider.loading) return const Center(child: CircularProgressIndicator());
          if (catProvider.categorias.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 80, color: AppColors.textoGris),
                  SizedBox(height: 16),
                  Text('No hay categorías', style: TextStyle(fontSize: 18, color: AppColors.textoGris)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            itemCount: catProvider.categorias.length,
            itemBuilder: (_, i) {
              final cat = catProvider.categorias[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.verdeClaro,
                    child: const Icon(Icons.category, color: AppColors.verdeOliva),
                  ),
                  title: Text(cat.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(cat.descripcion),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/home/productos', extra: cat.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
