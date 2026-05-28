import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:olivos_verdes/core/constants/app_colors.dart';
import 'package:olivos_verdes/providers/product_provider.dart';
import 'package:olivos_verdes/providers/cart_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  final String id;

  const ProductDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final prodProvider = context.watch<ProductProvider>();
    final fruta = prodProvider.obtenerPorId(id);

    if (fruta == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Producto')),
        body: const Center(child: Text('Producto no encontrado')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(fruta.nombre)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              child: fruta.imagen.isNotEmpty
                  ? Image.network(fruta.imagen, height: 280, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 280, color: AppColors.verdeClaro, child: const Icon(Icons.image, size: 80, color: AppColors.verdeOliva)))
                  : Container(height: 280, color: AppColors.verdeClaro, child: const Icon(Icons.image, size: 80, color: AppColors.verdeOliva)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fruta.nombre, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.verdeOliva)),
                  const SizedBox(height: 8),
                  Text('\$${fruta.precio.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, color: AppColors.rosa, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (fruta.stock > 0)
                        const Chip(label: Text('Disponible', style: TextStyle(color: Colors.white)), backgroundColor: AppColors.verdeOliva)
                      else
                        const Chip(label: Text('Agotado', style: TextStyle(color: Colors.white)), backgroundColor: AppColors.error),
                      const SizedBox(width: 8),
                      Text('Stock: ${fruta.stock}', style: const TextStyle(color: AppColors.textoGris)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Descripción', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.verdeOliva)),
                  const SizedBox(height: 8),
                  Text(fruta.descripcion.isNotEmpty ? fruta.descripcion : 'Sin descripción disponible', style: const TextStyle(fontSize: 16, color: AppColors.textoGris)),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<CartProvider>().agregarItem(
                          fruta.id,
                          fruta.nombre,
                          fruta.precio,
                          imagen: fruta.imagen,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${fruta.nombre} agregado al carrito'),
                            action: SnackBarAction(label: 'Ver carrito', textColor: Colors.white, onPressed: () => context.push('/home/carrito')),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.rosa),
                      child: const Text('Agregar al carrito', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
