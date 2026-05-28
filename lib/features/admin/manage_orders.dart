import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:olivos_verdes/core/constants/app_colors.dart';
import 'package:olivos_verdes/providers/order_provider.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  String _filter = 'todos';

  @override
  void initState() {
    super.initState();
    context.read<OrderProvider>().cargarTodosPedidos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Pedidos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['todos', 'pendiente', 'preparando', 'en camino', 'entregado'].map((estado) {
                  final selected = _filter == estado;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(estado == 'todos' ? 'Todos' : estado),
                      selected: selected,
                      onSelected: (_) => setState(() => _filter = estado),
                      selectedColor: AppColors.verdeOliva,
                      labelStyle: TextStyle(color: selected ? Colors.white : null),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (_, orders, __) {
                if (orders.loading) return const Center(child: CircularProgressIndicator());

                var pedidos = _filter == 'todos'
                    ? orders.pedidos
                    : orders.pedidos.where((p) => p.estado == _filter).toList();

                if (pedidos.isEmpty) {
                  return const Center(child: Text('No hay pedidos', style: TextStyle(color: AppColors.textoGris)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: pedidos.length,
                  itemBuilder: (_, i) {
                    final pedido = pedidos[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExpansionTile(
                        leading: Icon(_estadoIcono(pedido.estado), color: _estadoColor(pedido.estado)),
                        title: Text('Pedido #${pedido.id.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${pedido.nombreUsuario.isNotEmpty ? '${pedido.nombreUsuario} - ' : ''}${pedido.productos.length} productos - \$${pedido.total.toStringAsFixed(2)}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...pedido.productos.map((p) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${p.nombre} x${p.cantidad}'),
                                      Text('\$${(p.precioUnitario * p.cantidad).toStringAsFixed(2)}'),
                                    ],
                                  ),
                                )),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Estado:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    DropdownButton<String>(
                                      value: pedido.estado,
                                      items: ['pendiente', 'preparando', 'en camino', 'entregado'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          orders.actualizarEstado(pedido.id, value);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
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
