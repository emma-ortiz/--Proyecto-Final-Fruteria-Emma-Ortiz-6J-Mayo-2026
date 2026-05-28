import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:olivos_verdes/core/constants/app_colors.dart';
import 'package:olivos_verdes/providers/category_provider.dart';
import 'package:olivos_verdes/models/categoria_model.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Categorías'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCategoryDialog(context),
          ),
        ],
      ),
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
                  Text('Agrega la primera categoría', style: TextStyle(color: AppColors.textoGris)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: catProvider.categorias.length,
            itemBuilder: (_, i) {
              final cat = catProvider.categorias[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.verdeClaro,
                    child: const Icon(Icons.category, color: AppColors.verdeOliva),
                  ),
                  title: Text(cat.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(cat.descripcion),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showCategoryDialog(context, categoria: cat),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Eliminar categoría'),
                              content: Text('¿Eliminar "${cat.nombre}"?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: AppColors.error))),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await catProvider.eliminarCategoria(cat.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

void _showCategoryDialog(BuildContext context, {Categoria? categoria}) {
  final nombreCtrl = TextEditingController(text: categoria?.nombre ?? '');
  final descCtrl = TextEditingController(text: categoria?.descripcion ?? '');
  final imagenCtrl = TextEditingController(text: categoria?.imagen ?? '');
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(categoria == null ? 'Nueva categoría' : 'Editar categoría'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: nombreCtrl, decoration: const InputDecoration(hintText: 'Nombre'), validator: (v) => v?.isEmpty == true ? 'Requerido' : null),
              TextFormField(controller: descCtrl, decoration: const InputDecoration(hintText: 'Descripción'), maxLines: 2),
              TextFormField(controller: imagenCtrl, decoration: const InputDecoration(hintText: 'URL de imagen (opcional)')),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            final catProvider = context.read<CategoryProvider>();
            if (categoria == null) {
              await catProvider.agregarCategoria(Categoria(
                id: '',
                nombre: nombreCtrl.text,
                descripcion: descCtrl.text,
                imagen: imagenCtrl.text.isNotEmpty ? imagenCtrl.text : null,
              ));
            } else {
              await catProvider.actualizarCategoria(categoria.id, {
                'nombre': nombreCtrl.text,
                'descripcion': descCtrl.text,
                'imagen': imagenCtrl.text.isNotEmpty ? imagenCtrl.text : null,
              });
            }
            if (dialogContext.mounted) Navigator.pop(dialogContext);
          },
          child: Text(categoria == null ? 'Crear' : 'Guardar'),
        ),
      ],
    ),
  );
}
