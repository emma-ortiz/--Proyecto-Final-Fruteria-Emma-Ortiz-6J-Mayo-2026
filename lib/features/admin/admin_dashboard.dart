import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:olivos_verdes/core/constants/app_colors.dart';
import 'package:olivos_verdes/providers/auth_provider.dart';
import 'package:olivos_verdes/services/seed_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool? _hayAdmins;

  @override
  void initState() {
    super.initState();
    _verificarAdmins();
  }

  Future<void> _verificarAdmins() async {
    final hay = await SeedService().hayAdmins();
    if (mounted) setState(() => _hayAdmins = hay);
  }

  Future<void> _hacerAdmin() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;

    await SeedService().hacerAdmin(auth.user!.id);

    if (mounted) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('¡Ahora eres admin!'),
          content: const Text('Se cerrará tu sesión. Vuelve a iniciar sesión para acceder al panel de administración.'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    }

    await auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 80, color: AppColors.error),
                const SizedBox(height: 16),
                const Text('Acceso restringido', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Solo administradores pueden acceder', style: TextStyle(color: AppColors.textoGris)),
                const SizedBox(height: 30),
                if (_hayAdmins == null)
                  const CircularProgressIndicator()
                else if (_hayAdmins == false)
                  ElevatedButton.icon(
                    onPressed: _hacerAdmin,
                    icon: const Icon(Icons.admin_panel_settings),
                    label: const Text('Hacerme admin (primer usuario)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.verdeOliva,
                      foregroundColor: Colors.white,
                    ),
                  )
                else
                  const Text('Ya existe un admin en el sistema', style: TextStyle(color: AppColors.textoGris)),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Panel Admin')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Administración', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.verdeOliva)),
            const SizedBox(height: 8),
            Text('Bienvenido, ${auth.user?.nombre}', style: const TextStyle(color: AppColors.textoGris)),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                children: [
                  _AdminCard(
                    icon: Icons.inventory_2,
                    label: 'Productos',
                    color: AppColors.verdeOliva,
                    onTap: () => context.push('/admin/productos'),
                  ),
                  _AdminCard(
                    icon: Icons.category,
                    label: 'Categorías',
                    color: Colors.blue,
                    onTap: () => context.push('/admin/categorias'),
                  ),
                  _AdminCard(
                    icon: Icons.local_offer,
                    label: 'Ofertas',
                    color: AppColors.warning,
                    onTap: () => context.push('/admin/ofertas'),
                  ),
                  _AdminCard(
                    icon: Icons.receipt_long,
                    label: 'Pedidos',
                    color: AppColors.rosa,
                    onTap: () => context.push('/admin/pedidos'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AdminCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 36, color: color),
              ),
              const SizedBox(height: 12),
              Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
