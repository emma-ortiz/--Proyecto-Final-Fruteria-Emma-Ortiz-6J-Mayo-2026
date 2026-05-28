import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:olivos_verdes/core/constants/app_colors.dart';
import 'package:olivos_verdes/core/constants/app_strings.dart';
import 'package:olivos_verdes/providers/product_provider.dart';
import 'package:olivos_verdes/providers/category_provider.dart';
import 'package:olivos_verdes/models/pedido_model.dart';
import 'package:olivos_verdes/providers/offer_provider.dart';
import 'package:olivos_verdes/providers/auth_provider.dart';
import 'package:olivos_verdes/providers/cart_provider.dart';
import 'package:olivos_verdes/providers/order_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeTab(context),
      const _CategoriesTab(),
      const _CartTab(),
      const _ProfileTab(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categorías'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Carrito'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          if (context.watch<AuthProvider>().isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () => context.push('/admin'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BannerWidget(),
            const SizedBox(height: 24),
            const Text('Categorías', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.verdeOliva)),
            const SizedBox(height: 12),
            Consumer<CategoryProvider>(
              builder: (_, catProvider, __) {
                if (catProvider.loading) return const LinearProgressIndicator();
                return SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: catProvider.categorias.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final cat = catProvider.categorias[i];
                      return GestureDetector(
                        onTap: () => context.push('/home/productos', extra: cat.id),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: AppColors.verdeClaro,
                              child: Icon(Icons.category, color: AppColors.verdeOliva),
                            ),
                            const SizedBox(height: 4),
                            Text(cat.nombre, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Productos Destacados', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.verdeOliva)),
                TextButton(
                  onPressed: () => context.push('/home/productos'),
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Consumer<ProductProvider>(
              builder: (_, prodProvider, __) {
                if (prodProvider.loading) return const LinearProgressIndicator();
                final frutas = prodProvider.destacadas;
                if (frutas.isEmpty) return const Center(child: Text('Sin productos destacados'));
                return SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: frutas.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => _ProductCard(fruta: frutas[i]),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text('Ofertas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.verdeOliva)),
            const SizedBox(height: 12),
            Consumer<OfferProvider>(
              builder: (_, offerProvider, __) {
                if (offerProvider.loading) return const LinearProgressIndicator();
                final activas = offerProvider.activas;
                if (activas.isEmpty) return const Text('No hay ofertas activas', style: TextStyle(color: AppColors.textoGris));
                return SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: activas.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final oferta = activas[i];
                      return GestureDetector(
                        onTap: () => context.push('/home/productos/${oferta.productoId}'),
                        child: Container(
                          width: 200,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(oferta.productoNombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('${oferta.descuento.toStringAsFixed(0)}% OFF', style: const TextStyle(color: AppColors.warning, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 155,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppColors.verdeOliva, Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🍏 Olivos Verdes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            const Text('Fruta fresca directo del campo', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 8),
            SizedBox(
              width: 130,
              height: 36,
              child: ElevatedButton(
                onPressed: () => context.push('/home/productos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.verdeOliva,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Ver catálogo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final dynamic fruta;
  const _ProductCard({required this.fruta});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/home/productos/${fruta.id}'),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: fruta.imagen.isNotEmpty
                  ? Image.network(fruta.imagen, height: 100, width: 150, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 100, color: AppColors.verdeClaro, child: const Icon(Icons.image, color: AppColors.verdeOliva)))
                  : Container(height: 100, color: AppColors.verdeClaro, child: const Icon(Icons.image, color: AppColors.verdeOliva)),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fruta.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('\$${fruta.precio.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.rosa, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      body: Consumer<CategoryProvider>(
        builder: (_, catProvider, __) {
          if (catProvider.loading) return const Center(child: CircularProgressIndicator());
          if (catProvider.categorias.isEmpty) return const Center(child: Text('Sin categorías'));
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.2),
            itemCount: catProvider.categorias.length,
            itemBuilder: (_, i) {
              final cat = catProvider.categorias[i];
              return GestureDetector(
                onTap: () => context.push('/home/productos', extra: cat.id),
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
      ),
    );
  }
}

class _CartTab extends StatelessWidget {
  const _CartTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carrito')),
      body: Consumer<CartProvider>(
        builder: (_, cart, __) {
          if (cart.isEmpty) return const Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 80, color: AppColors.textoGris),
              SizedBox(height: 16),
              Text('Carrito vacío', style: TextStyle(fontSize: 18, color: AppColors.textoGris)),
            ],
          ));
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  itemCount: cart.items.length,
                  itemBuilder: (_, i) {
                    final item = cart.items[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 56, height: 56,
                                color: AppColors.verdeClaro,
                                child: item.imagen != null && item.imagen!.isNotEmpty
                                    ? Image.network(item.imagen!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.shopping_basket, color: AppColors.verdeOliva))
                                    : const Icon(Icons.shopping_basket, color: AppColors.verdeOliva),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text('\$${item.precioUnitario.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.rosa, fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: AppColors.rosa),
                                  onPressed: () => cart.actualizarCantidad(item.productoId, item.cantidad - 1),
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  padding: EdgeInsets.zero,
                                ),
                                Text('${item.cantidad}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, color: AppColors.verdeOliva),
                                  onPressed: () => cart.actualizarCantidad(item.productoId, item.cantidad + 1),
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('\$${cart.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.rosa)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => context.push('/home/checkout'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.rosa),
                          child: const Text('Ir a pagar', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileTab extends StatefulWidget {
  const _ProfileTab();

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  bool _ordersLoaded = false;

  @override
  void initState() {
    super.initState();
    _tryLoadOrders();
  }

  void _tryLoadOrders() {
    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      context.read<OrderProvider>().cargarPedidos(auth.user!.id);
      _ordersLoaded = true;
    }
  }

  void _editarCampo(BuildContext context, String label, String currentValue, Function(String) onSave) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Editar $label'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final val = controller.text.trim();
              if (val.isNotEmpty) {
                onSave(val);
                Navigator.pop(context);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.verdeOliva),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  IconData _estadoIcono(String estado) {
    switch (estado) {
      case 'pendiente': return Icons.hourglass_empty;
      case 'preparando': return Icons.restaurant;
      case 'en camino': return Icons.local_shipping;
      case 'entregado': return Icons.check_circle;
      default: return Icons.receipt_long;
    }
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'pendiente': return AppColors.warning;
      case 'preparando': return Colors.blue;
      case 'en camino': return Colors.orange;
      case 'entregado': return AppColors.verdeOliva;
      default: return AppColors.textoGris;
    }
  }

  void _mostrarDetallePedido(Pedido pedido) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Pedido #${pedido.id.substring(0, 8)}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_estadoIcono(pedido.estado), color: _estadoColor(pedido.estado), size: 18),
                  const SizedBox(width: 8),
                  Text('Estado: ${pedido.estado}', style: TextStyle(color: _estadoColor(pedido.estado), fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Text('Fecha: ${pedido.fecha.day}/${pedido.fecha.month}/${pedido.fecha.year}', style: const TextStyle(color: AppColors.textoGris, fontSize: 13)),
              if (pedido.direccionEntrega != null && pedido.direccionEntrega!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('Dirección: ${pedido.direccionEntrega}', style: const TextStyle(color: AppColors.textoGris, fontSize: 13)),
              ],
              const Divider(height: 20),
              const Text('Productos:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...pedido.productos.map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('${p.nombre} x${p.cantidad}', style: const TextStyle(fontSize: 14))),
                    Text('\$${(p.precioUnitario * p.cantidad).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.rosa)),
                  Text('\$${pedido.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.rosa)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final orders = context.watch<OrderProvider>();

    if (user != null && !_ordersLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_ordersLoaded) {
          context.read<OrderProvider>().cargarPedidos(user.id);
          _ordersLoaded = true;
        }
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        children: [
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.verdeClaro,
                  child: Icon(Icons.person, size: 50, color: AppColors.verdeOliva),
                ),
                const SizedBox(height: 16),
                Text(user?.nombre ?? 'Usuario', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text(user?.correo ?? '', style: const TextStyle(color: AppColors.textoGris)),
                if (user?.rol == 'admin')
                  const Chip(
                    label: Text('Admin', style: TextStyle(color: Colors.white)),
                    backgroundColor: AppColors.verdeOliva,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Información personal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.verdeOliva)),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person, color: AppColors.verdeOliva),
                  title: const Text('Nombre'),
                  subtitle: Text(user?.nombre ?? 'No registrado'),
                  trailing: const Icon(Icons.edit, color: AppColors.verdeOliva, size: 20),
                  onTap: () => _editarCampo(context, 'Nombre', user?.nombre ?? '', (val) => auth.actualizarPerfil({'nombre': val})),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email, color: AppColors.verdeOliva),
                  title: const Text('Correo'),
                  subtitle: Text(user?.correo ?? 'No registrado'),
                  trailing: const Icon(Icons.edit, color: AppColors.verdeOliva, size: 20),
                  onTap: () => _editarCampo(context, 'Correo', user?.correo ?? '', (val) => auth.actualizarPerfil({'correo': val})),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_on, color: AppColors.verdeOliva),
                  title: const Text('Dirección'),
                  subtitle: Text(user?.direccion ?? 'No registrada'),
                  trailing: const Icon(Icons.edit, color: AppColors.verdeOliva, size: 20),
                  onTap: () => _editarCampo(context, 'Dirección', user?.direccion ?? '', (val) => auth.actualizarPerfil({'direccion': val})),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone, color: AppColors.verdeOliva),
                  title: const Text('Teléfono'),
                  subtitle: Text(user?.telefono ?? 'No registrado'),
                  trailing: const Icon(Icons.edit, color: AppColors.verdeOliva, size: 20),
                  onTap: () => _editarCampo(context, 'Teléfono', user?.telefono ?? '', (val) => auth.actualizarPerfil({'telefono': val})),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Historial de pagos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.verdeOliva)),
          const SizedBox(height: 12),
          if (orders.loading)
            const Center(child: CircularProgressIndicator())
          else if (orders.pedidos.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.receipt_long, color: AppColors.textoGris),
                title: Text('Sin pedidos aún'),
                subtitle: Text('Tus pedidos aparecerán aquí'),
              ),
            )
          else
            ...orders.pedidos.map((pedido) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(_estadoIcono(pedido.estado), color: _estadoColor(pedido.estado)),
                title: Text('Pedido #${pedido.id.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${pedido.productos.length} productos - \$${pedido.total.toStringAsFixed(2)}'),
                trailing: Chip(
                  label: Text(pedido.estado, style: const TextStyle(color: Colors.white, fontSize: 11)),
                  backgroundColor: _estadoColor(pedido.estado),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                onTap: () => _mostrarDetallePedido(pedido),
              ),
            )),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              await auth.logout();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, minimumSize: const Size(double.infinity, 50)),
          ),
        ],
      ),
    );
  }
}
