import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:olivos_verdes/core/constants/app_colors.dart';
import 'package:olivos_verdes/providers/product_provider.dart';
import 'package:olivos_verdes/providers/cart_provider.dart';
import 'package:olivos_verdes/providers/category_provider.dart';
import 'package:olivos_verdes/models/fruta_model.dart';

class PublicMenuScreen extends StatefulWidget {
  const PublicMenuScreen({super.key});

  @override
  State<PublicMenuScreen> createState() => _PublicMenuScreenState();
}

class _PublicMenuScreenState extends State<PublicMenuScreen> {
  int _currentTab = 0;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _categoriaFiltro;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _mostrarDetalle(Fruta fruta) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PublicFruitDetailSheet(
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
                onPressed: () => setState(() => _currentTab = 2),
              ),
            ),
          );
        },
      ),
    );
  }

  void _agregarAlCarrito(Fruta fruta) {
    context.read<CartProvider>().agregarItem(
      fruta.id, fruta.nombre, fruta.precio, imagen: fruta.imagen,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${fruta.nombre} agregado al carrito'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Ir al carrito',
          onPressed: () => setState(() => _currentTab = 2),
        ),
      ),
    );
  }

  void _filtrarPorCategoria(String categoriaId) {
    setState(() {
      _categoriaFiltro = categoriaId;
      _currentTab = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.verdeFondo,
      appBar: _currentTab == 0 || _currentTab == 3
          ? AppBar(
              title: Text(_currentTab == 3 ? 'Cuenta' : 'Menú Virtual'),
              backgroundColor: AppColors.verdeOliva,
              actions: [
                if (_currentTab == 0)
                  IconButton(
                    icon: const Icon(Icons.person),
                    tooltip: 'Iniciar sesión',
                    onPressed: () => context.push('/login'),
                  ),
              ],
            )
          : null,
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildMenuTab(),
          _buildCategoriesTab(),
          _buildCartTab(),
          _buildAccountTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (i) {
          if (i == 3) { context.push('/login'); return; }
          setState(() => _currentTab = i);
        },
        selectedItemColor: AppColors.verdeOliva,
        unselectedItemColor: AppColors.textoGris,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Menú'),
          const BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categorías'),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (context.watch<CartProvider>().itemCount > 0)
                  Positioned(
                    right: -4,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: AppColors.rosa, shape: BoxShape.circle),
                      child: Text(
                        '${context.watch<CartProvider>().itemCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Carrito',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cuenta'),
        ],
      ),
    );
  }

  Widget _buildMenuTab() {
    return Column(
      children: [
        if (_categoriaFiltro != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
            child: Row(
              children: [
                Consumer<CategoryProvider>(
                  builder: (_, catProvider, __) {
                    final cat = catProvider.categorias.where((c) => c.id == _categoriaFiltro).firstOrNull;
                    return Text(
                      cat?.nombre ?? 'Categoría',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.verdeOliva, fontSize: 15),
                    );
                  },
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _categoriaFiltro = null),
                  child: const Text('Limpiar filtro', style: TextStyle(color: AppColors.rosa, fontSize: 13)),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
          child: Consumer2<ProductProvider, CategoryProvider>(
            builder: (_, prodProvider, catProvider, __) {
              if (prodProvider.loading) return const Center(child: CircularProgressIndicator());
              var frutas = _searchQuery.isEmpty ? prodProvider.frutas : prodProvider.buscar(_searchQuery);
              if (_categoriaFiltro != null) {
                frutas = frutas.where((f) => f.categoria == _categoriaFiltro).toList();
              }
              if (frutas.isEmpty) {
                return const Center(child: Text('No se encontraron productos', style: TextStyle(color: AppColors.textoGris)));
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemCount: frutas.length,
                itemBuilder: (_, i) => _FruitCard(
                  fruta: frutas[i],
                  onInfoTap: () => _mostrarDetalle(frutas[i]),
                  onBuyTap: () => _agregarAlCarrito(frutas[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesTab() {
    return Consumer<CategoryProvider>(
      builder: (_, catProvider, __) {
        if (catProvider.loading) return const Center(child: CircularProgressIndicator());
        if (catProvider.categorias.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.category_outlined, size: 60, color: AppColors.textoGris),
                SizedBox(height: 12),
                Text('Sin categorías', style: TextStyle(color: AppColors.textoGris)),
              ],
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.2,
          ),
          itemCount: catProvider.categorias.length,
          itemBuilder: (_, i) {
            final cat = catProvider.categorias[i];
            return GestureDetector(
              onTap: () => _filtrarPorCategoria(cat.id),
              child: Container(
                decoration: BoxDecoration(color: AppColors.verdeClaro, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.category, size: 40, color: AppColors.verdeOliva),
                    const SizedBox(height: 8),
                    Text(cat.nombre, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.verdeOliva)),
                    Text(cat.descripcion, style: const TextStyle(fontSize: 12, color: AppColors.textoGris), textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCartTab() {
    final cart = context.watch<CartProvider>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (cart.isEmpty)
          Column(
            children: [
              const SizedBox(height: 60),
              const Icon(Icons.shopping_cart_outlined, size: 60, color: AppColors.textoGris),
              const SizedBox(height: 12),
              const Text('Carrito vacío', style: TextStyle(fontSize: 18, color: AppColors.textoGris)),
            ],
          )
        else ...[
          ...cart.items.map((item) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.shopping_basket, color: AppColors.verdeOliva),
              title: Text(item.nombre),
              subtitle: Text('\$${item.precioUnitario.toStringAsFixed(2)} x ${item.cantidad}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.remove_circle_outline, color: AppColors.rosa), onPressed: () => cart.actualizarCantidad(item.productoId, item.cantidad - 1)),
                  Text('${item.cantidad}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.add_circle_outline, color: AppColors.verdeOliva), onPressed: () => cart.actualizarCantidad(item.productoId, item.cantidad + 1)),
                ],
              ),
            ),
          )),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('\$${cart.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.rosa)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => context.push('/login'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.rosa, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              child: const Text('Inicia sesión para comprar', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAccountTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_outline, size: 80, color: AppColors.verdeOliva),
            const SizedBox(height: 20),
            const Text('Inicia sesión para ver tu perfil', style: TextStyle(fontSize: 18, color: AppColors.textoGris), textAlign: TextAlign.center),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => context.push('/login'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.rosa, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: const Text('Iniciar sesión', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.push('/register'),
              child: const Text('¿No tienes cuenta? Crea una aquí', style: TextStyle(color: AppColors.verdeOliva, decoration: TextDecoration.underline)),
            ),
          ],
        ),
      ),
    );
  }
}

class _FruitCard extends StatelessWidget {
  final Fruta fruta;
  final VoidCallback onInfoTap;
  final VoidCallback onBuyTap;

  const _FruitCard({required this.fruta, required this.onInfoTap, required this.onBuyTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: fruta.imagen.isNotEmpty
                        ? Image.network(fruta.imagen, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.verdeClaro, child: const Icon(Icons.image, color: AppColors.verdeOliva, size: 30)))
                        : Container(color: AppColors.verdeClaro, child: const Icon(Icons.image, color: AppColors.verdeOliva, size: 30)),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: onInfoTap,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.rosa,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: AppColors.rosa.withValues(alpha: 0.5), blurRadius: 4, offset: const Offset(0, 2))],
                        ),
                        child: const Icon(Icons.visibility, color: Colors.white, size: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fruta.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('\$${fruta.precio.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.rosa, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  height: 28,
                  child: ElevatedButton(
                    onPressed: onBuyTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.rosa,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(double.infinity, 28),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Comprar', style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PublicFruitDetailSheet extends StatelessWidget {
  final Fruta fruta;
  final VoidCallback? onAddToCart;
  const _PublicFruitDetailSheet({required this.fruta, this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
                  ? Image.network(fruta.imagen, height: 220, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 220, color: AppColors.verdeClaro, child: const Icon(Icons.image, size: 50, color: AppColors.verdeOliva)))
                  : Container(height: 220, color: AppColors.verdeClaro, child: const Icon(Icons.image, size: 50, color: AppColors.verdeOliva)),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(fruta.nombre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.verdeOliva))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.verdeClaro, borderRadius: BorderRadius.circular(10)),
                        child: Text(fruta.categoria, style: const TextStyle(color: AppColors.verdeOliva, fontWeight: FontWeight.w600, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('\$${fruta.precio.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, color: AppColors.rosa, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text('Descripción', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.verdeOliva)),
                  const SizedBox(height: 6),
                  Text(fruta.descripcion.isNotEmpty ? fruta.descripcion : 'Sin descripción disponible', style: const TextStyle(fontSize: 14, color: AppColors.textoGris, height: 1.4)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        if (onAddToCart != null) {
                          onAddToCart!();
                        } else {
                          context.read<CartProvider>().agregarItem(fruta.id, fruta.nombre, fruta.precio, imagen: fruta.imagen);
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.rosa, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Agregar al carrito', style: TextStyle(color: Colors.white, fontSize: 16)),
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
