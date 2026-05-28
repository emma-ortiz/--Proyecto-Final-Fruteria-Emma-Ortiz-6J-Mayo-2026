import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:olivos_verdes/core/constants/app_colors.dart';
import 'package:olivos_verdes/providers/offer_provider.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ofertas')),
      body: Consumer<OfferProvider>(
        builder: (_, offerProvider, __) {
          if (offerProvider.loading) return const Center(child: CircularProgressIndicator());

          final activas = offerProvider.activas;

          if (activas.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer_outlined, size: 80, color: AppColors.textoGris),
                  SizedBox(height: 16),
                  Text('No hay ofertas activas', style: TextStyle(fontSize: 18, color: AppColors.textoGris)),
                  Text('Vuelve pronto para nuevas promociones', style: TextStyle(color: AppColors.textoGris)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activas.length,
            itemBuilder: (_, i) {
              final oferta = activas[i];
              final diasRestantes = oferta.fechaFin.difference(DateTime.now()).inDays;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.warning.withValues(alpha: 0.2),
                    child: Text('${oferta.descuento.toStringAsFixed(0)}%', style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  title: Text(oferta.productoNombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Válido hasta: ${oferta.fechaFin.day}/${oferta.fechaFin.month}/${oferta.fechaFin.year}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$diasRestantes', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.warning)),
                      const Text('días', style: TextStyle(fontSize: 11, color: AppColors.textoGris)),
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
