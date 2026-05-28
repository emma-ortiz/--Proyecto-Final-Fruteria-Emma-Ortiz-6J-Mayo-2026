import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:olivos_verdes/core/constants/app_colors.dart';
import 'package:olivos_verdes/providers/product_provider.dart';
import 'package:olivos_verdes/providers/category_provider.dart';
import 'package:olivos_verdes/models/fruta_model.dart';

class ManageProductsScreen extends StatelessWidget {
  const ManageProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showProductDialog(context),
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (_, prodProvider, __) {
          if (prodProvider.loading) return const Center(child: CircularProgressIndicator());
          if (prodProvider.frutas.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: AppColors.textoGris),
                  SizedBox(height: 16),
                  Text('No hay productos', style: TextStyle(fontSize: 18, color: AppColors.textoGris)),
                  Text('Agrega el primer producto', style: TextStyle(color: AppColors.textoGris)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prodProvider.frutas.length,
            itemBuilder: (_, i) {
              final fruta = prodProvider.frutas[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.verdeClaro,
                    child: fruta.imagen.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(fruta.imagen, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image, color: AppColors.verdeOliva)),
                          )
                        : const Icon(Icons.image, color: AppColors.verdeOliva),
                  ),
                  title: Text(fruta.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('\$${fruta.precio.toStringAsFixed(2)} - Stock: ${fruta.stock}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showProductDialog(context, fruta: fruta),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Eliminar producto'),
                              content: Text('¿Eliminar "${fruta.nombre}"?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: AppColors.error))),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await prodProvider.eliminarFruta(fruta.id);
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

void _showProductDialog(BuildContext context, {Fruta? fruta}) {
  final nombreCtrl = TextEditingController(text: fruta?.nombre ?? '');
  final precioCtrl = TextEditingController(text: fruta?.precio.toString() ?? '');
  final descCtrl = TextEditingController(text: fruta?.descripcion ?? '');
  final imagenCtrl = TextEditingController(text: fruta?.imagen ?? '');
  final stockCtrl = TextEditingController(text: fruta?.stock.toString() ?? '0');
  final disponible = ValueNotifier<bool>(fruta?.disponible ?? true);
  final selectedCategoria = ValueNotifier<String?>(fruta?.categoria);
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (dialogContext) {
      final categorias = context.read<CategoryProvider>().categorias;
      return AlertDialog(
        title: Text(fruta == null ? 'Nuevo producto' : 'Editar producto'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: nombreCtrl, decoration: const InputDecoration(hintText: 'Nombre'), validator: (v) => v?.isEmpty == true ? 'Requerido' : null),
                TextFormField(controller: precioCtrl, decoration: const InputDecoration(hintText: 'Precio'), keyboardType: TextInputType.number, validator: (v) => v?.isEmpty == true ? 'Requerido' : null),
                TextFormField(controller: descCtrl, decoration: const InputDecoration(hintText: 'Descripción'), maxLines: 2),
                TextFormField(controller: imagenCtrl, decoration: const InputDecoration(hintText: 'URL de imagen')),
                TextFormField(controller: stockCtrl, decoration: const InputDecoration(hintText: 'Stock'), keyboardType: TextInputType.number),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategoria.value,
                  decoration: const InputDecoration(hintText: 'Categoría'),
                  items: categorias.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre))).toList(),
                  onChanged: (v) => selectedCategoria.value = v,
                  validator: (v) => v == null || v.isEmpty ? 'Selecciona una categoría' : null,
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<bool>(
                  valueListenable: disponible,
                  builder: (_, value, __) => SwitchListTile(
                    title: const Text('Disponible'),
                    value: value,
                    onChanged: (v) => disponible.value = v,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final prodProvider = context.read<ProductProvider>();
              if (fruta == null) {
                await prodProvider.agregarFruta(Fruta(
                  id: '',
                  nombre: nombreCtrl.text,
                  categoria: selectedCategoria.value ?? '',
                  descripcion: descCtrl.text,
                  imagen: imagenCtrl.text,
                  precio: double.parse(precioCtrl.text),
                  stock: int.tryParse(stockCtrl.text) ?? 0,
                  disponible: disponible.value,
                ));
              } else {
                await prodProvider.actualizarFruta(fruta.id, {
                  'nombre': nombreCtrl.text,
                  'categoria': selectedCategoria.value ?? '',
                  'descripcion': descCtrl.text,
                  'imagen': imagenCtrl.text,
                  'precio': double.parse(precioCtrl.text),
                  'stock': int.tryParse(stockCtrl.text) ?? 0,
                  'disponible': disponible.value,
                });
              }
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: Text(fruta == null ? 'Crear' : 'Guardar'),
          ),
        ],
      );
    },
  );
}
