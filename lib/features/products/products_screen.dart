import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:olivos_verdes/core/constants/app_colors.dart';
import 'package:olivos_verdes/providers/product_provider.dart';
import 'package:olivos_verdes/providers/cart_provider.dart';
import 'package:olivos_verdes/providers/category_provider.dart';
import 'package:olivos_verdes/models/fruta_model.dart';

class ProductsScreen extends StatefulWidget {
  final String? categoriaId;
  const ProductsScreen({super.key, this.categoriaId});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _categoriaNombre;

  @override
  void initState() {
    super.initState();
    if (widget.categoriaId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final catProvider = context.read<CategoryProvider>();
        final cat = catProvider.categorias.where((c) => c.id == widget.categoriaId).firstOrNull;
        if (cat != null) setState(() => _categoriaNombre = cat.nombre);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _mostrarDetalle(BuildContext context, Fruta fruta) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FruitDetailSheet(
        fruta: fruta,
        onAddToCart: () {
          context.read<CartProvider>().agregarItem(
            fruta.id, fruta.nombre, fruta.precio, imagen: fruta.imagen,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${fruta.nombre} agregado al carrito'),
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'Ir al carrito',
                onPressed: () => context.go('/home/carrito'),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.verdeFondo,
      appBar: AppBar(
        title: Text(_categoriaNombre ?? 'Menú Virtual'),
        backgroundColor: AppColors.verdeOliva,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar frutas...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textoGris),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textoGris),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (_, prodProvider, __) {
                if (prodProvider.loading) return const Center(child: CircularProgressIndicator());

                final frutas = () {
                  var base = widget.categoriaId != null
                      ? prodProvider.filtrarPorCategoria(widget.categoriaId!)
                      : prodProvider.frutas;
                  if (_searchQuery.isNotEmpty) {
                    base = base.where((f) =>
                      f.nombre.toLowerCase().contains(_searchQuery.toLowerCase())
                    ).toList();
                  }
                  return base;
                }();

                if (frutas.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron productos', style: TextStyle(color: AppColors.textoGris)),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: frutas.length,
                  itemBuilder: (_, i) => _FruitCard(
                    fruta: frutas[i],
                    onInfoTap: () => _mostrarDetalle(context, frutas[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FruitCard extends StatelessWidget {
  final Fruta fruta;
  final VoidCallback onInfoTap;

  const _FruitCard({required this.fruta, required this.onInfoTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: fruta.imagen.isNotEmpty
                        ? Image.network(fruta.imagen, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.verdeClaro, child: const Icon(Icons.image, color: AppColors.verdeOliva, size: 40)))
                        : Container(color: AppColors.verdeClaro, child: const Icon(Icons.image, color: AppColors.verdeOliva, size: 40)),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: onInfoTap,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.rosa,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.rosa.withValues(alpha: 0.5),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.visibility, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fruta.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${fruta.precio.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.rosa,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<CartProvider>().agregarItem(
                        fruta.id, fruta.nombre, fruta.precio, imagen: fruta.imagen,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${fruta.nombre} agregado al carrito'),
                          duration: const Duration(seconds: 2),
                          action: SnackBarAction(
                            label: 'Ir al carrito',
                            onPressed: () => context.go('/home/carrito'),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.rosa,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(double.infinity, 30),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Comprar', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FruitDetailSheet extends StatelessWidget {
  final Fruta fruta;
  final VoidCallback? onAddToCart;

  const _FruitDetailSheet({required this.fruta, this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              child: fruta.imagen.isNotEmpty
                  ? Image.network(fruta.imagen, height: 260, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 260, color: AppColors.verdeClaro, child: const Icon(Icons.image, size: 60, color: AppColors.verdeOliva)))
                  : Container(height: 260, color: AppColors.verdeClaro, child: const Icon(Icons.image, size: 60, color: AppColors.verdeOliva)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(fruta.nombre, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.verdeOliva)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.verdeClaro,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(fruta.categoria, style: const TextStyle(color: AppColors.verdeOliva, fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('\$${fruta.precio.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, color: AppColors.rosa, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text('Descripción', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.verdeOliva)),
                  const SizedBox(height: 8),
                  Text(
                    fruta.descripcion.isNotEmpty ? fruta.descripcion : 'Sin descripción disponible',
                    style: const TextStyle(fontSize: 15, color: AppColors.textoGris, height: 1.5),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.inventory, size: 16, color: AppColors.textoGris),
                      const SizedBox(width: 4),
                      Text('Stock: ${fruta.stock}', style: const TextStyle(color: AppColors.textoGris)),
                      const SizedBox(width: 20),
                      Icon(Icons.shopping_bag, size: 16, color: fruta.disponible ? AppColors.verdeOliva : AppColors.error),
                      const SizedBox(width: 4),
                      Text(fruta.disponible ? 'Disponible' : 'Agotado', style: TextStyle(color: fruta.disponible ? AppColors.verdeOliva : AppColors.error)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (onAddToCart != null) {
                          onAddToCart!();
                        } else {
                          context.read<CartProvider>().agregarItem(
                            fruta.id, fruta.nombre, fruta.precio, imagen: fruta.imagen,
                          );
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.rosa,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('Agregar al carrito', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textoGris,
                        side: const BorderSide(color: AppColors.textoGris),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('Cerrar'),
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
