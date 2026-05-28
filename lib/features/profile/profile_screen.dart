import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:olivos_verdes/core/constants/app_colors.dart';
import 'package:olivos_verdes/providers/auth_provider.dart';
import 'package:olivos_verdes/providers/order_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      context.read<OrderProvider>().cargarPedidos(auth.user!.id);
    }
  }

  void _editarCampo(String label, String currentValue, Function(String) onSave) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Editar $label'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final orders = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 30),
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
                  onTap: () => _editarCampo('Nombre', user?.nombre ?? '', (val) => auth.actualizarPerfil({'nombre': val})),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email, color: AppColors.verdeOliva),
                  title: const Text('Correo'),
                  subtitle: Text(user?.correo ?? 'No registrado'),
                  trailing: const Icon(Icons.edit, color: AppColors.verdeOliva, size: 20),
                  onTap: () => _editarCampo('Correo', user?.correo ?? '', (val) => auth.actualizarPerfil({'correo': val})),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_on, color: AppColors.verdeOliva),
                  title: const Text('Dirección'),
                  subtitle: Text(user?.direccion ?? 'No registrada'),
                  trailing: const Icon(Icons.edit, color: AppColors.verdeOliva, size: 20),
                  onTap: () => _editarCampo('Dirección', user?.direccion ?? '', (val) => auth.actualizarPerfil({'direccion': val})),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone, color: AppColors.verdeOliva),
                  title: const Text('Teléfono'),
                  subtitle: Text(user?.telefono ?? 'No registrado'),
                  trailing: const Icon(Icons.edit, color: AppColors.verdeOliva, size: 20),
                  onTap: () => _editarCampo('Teléfono', user?.telefono ?? '', (val) => auth.actualizarPerfil({'telefono': val})),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text('Historial de pedidos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.verdeOliva)),
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
              ),
            )),
          const SizedBox(height: 30),
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
}
