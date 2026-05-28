import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:olivos_verdes/core/constants/app_colors.dart';
import 'package:olivos_verdes/providers/offer_provider.dart';
import 'package:olivos_verdes/models/oferta_model.dart';

class ManageOffersScreen extends StatelessWidget {
  const ManageOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Ofertas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showOfferDialog(context),
          ),
        ],
      ),
      body: Consumer<OfferProvider>(
        builder: (_, offerProvider, __) {
          if (offerProvider.loading) return const Center(child: CircularProgressIndicator());
          if (offerProvider.ofertas.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer_outlined, size: 80, color: AppColors.textoGris),
                  SizedBox(height: 16),
                  Text('No hay ofertas', style: TextStyle(fontSize: 18, color: AppColors.textoGris)),
                  Text('Crea la primera oferta', style: TextStyle(color: AppColors.textoGris)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: offerProvider.ofertas.length,
            itemBuilder: (_, i) {
              final oferta = offerProvider.ofertas[i];
              final activa = oferta.fechaInicio.isBefore(DateTime.now()) && oferta.fechaFin.isAfter(DateTime.now());
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: activa ? AppColors.verdeClaro : Colors.grey.shade200,
                    child: Text('${oferta.descuento.toStringAsFixed(0)}%', style: TextStyle(fontWeight: FontWeight.bold, color: activa ? AppColors.warning : AppColors.textoGris, fontSize: 14)),
                  ),
                  title: Text(oferta.productoNombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${oferta.fechaInicio.day}/${oferta.fechaInicio.month} - ${oferta.fechaFin.day}/${oferta.fechaFin.month}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showOfferDialog(context, oferta: oferta),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Eliminar oferta'),
                              content: Text('¿Eliminar oferta de "${oferta.productoNombre}"?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: AppColors.error))),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await offerProvider.eliminarOferta(oferta.id);
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

void _showOfferDialog(BuildContext context, {Oferta? oferta}) {
  final prodIdCtrl = TextEditingController(text: oferta?.productoId ?? '');
  final prodNomCtrl = TextEditingController(text: oferta?.productoNombre ?? '');
  final descCtrl = TextEditingController(text: oferta?.descuento.toString() ?? '');
  final fechaInicioCtrl = TextEditingController(text: oferta != null ? '${oferta.fechaInicio.year}-${_pad(oferta.fechaInicio.month)}-${_pad(oferta.fechaInicio.day)}' : '');
  final fechaFinCtrl = TextEditingController(text: oferta != null ? '${oferta.fechaFin.year}-${_pad(oferta.fechaFin.month)}-${_pad(oferta.fechaFin.day)}' : '');
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(oferta == null ? 'Nueva oferta' : 'Editar oferta'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: prodIdCtrl, decoration: const InputDecoration(hintText: 'ID del producto'), validator: (v) => v?.isEmpty == true ? 'Requerido' : null),
              TextFormField(controller: prodNomCtrl, decoration: const InputDecoration(hintText: 'Nombre del producto'), validator: (v) => v?.isEmpty == true ? 'Requerido' : null),
              TextFormField(controller: descCtrl, decoration: const InputDecoration(hintText: 'Descuento (%)'), keyboardType: TextInputType.number, validator: (v) => v?.isEmpty == true ? 'Requerido' : null),
              TextFormField(controller: fechaInicioCtrl, decoration: const InputDecoration(hintText: 'Fecha inicio (YYYY-MM-DD)')),
              TextFormField(controller: fechaFinCtrl, decoration: const InputDecoration(hintText: 'Fecha fin (YYYY-MM-DD)')),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            final offerProvider = context.read<OfferProvider>();
            final desc = double.tryParse(descCtrl.text) ?? 0;
            final inicio = _parseDate(fechaInicioCtrl.text);
            final fin = _parseDate(fechaFinCtrl.text);

            if (oferta == null) {
              await offerProvider.agregarOferta(Oferta(
                id: '',
                productoId: prodIdCtrl.text,
                productoNombre: prodNomCtrl.text,
                descuento: desc,
                fechaInicio: inicio,
                fechaFin: fin,
              ));
            } else {
              await offerProvider.actualizarOferta(oferta.id, {
                'productoId': prodIdCtrl.text,
                'productoNombre': prodNomCtrl.text,
                'descuento': desc,
                'fechaInicio': inicio,
                'fechaFin': fin,
              });
            }
            if (dialogContext.mounted) Navigator.pop(dialogContext);
          },
          child: Text(oferta == null ? 'Crear' : 'Guardar'),
        ),
      ],
    ),
  );
}

String _pad(int n) => n.toString().padLeft(2, '0');

DateTime _parseDate(String date) {
  try {
    final parts = date.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  } catch (_) {
    return DateTime.now();
  }
}
