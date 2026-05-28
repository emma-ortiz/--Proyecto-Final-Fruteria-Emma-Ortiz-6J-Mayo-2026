import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:olivos_verdes/core/constants/app_colors.dart';
import 'package:olivos_verdes/providers/cart_provider.dart';
import 'package:olivos_verdes/providers/auth_provider.dart';
import 'package:olivos_verdes/providers/order_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _processing = false;

  final _cardNumberCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  bool _showPaymentForm = false;

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _cardNameCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  bool get _cardValid {
    final numClean = _cardNumberCtrl.text.replaceAll(' ', '');
    return numClean.length >= 16 &&
        _cardNameCtrl.text.trim().length > 2 &&
        _expiryCtrl.text.length == 5 &&
        (_cvvCtrl.text.length == 3 || _cvvCtrl.text.length == 4);
  }

  Future<void> _procesarPago() async {
    setState(() => _processing = true);

    await Future.delayed(const Duration(seconds: 2));

    final cart = context.read<CartProvider>();
    final auth = context.read<AuthProvider>();
    final orders = context.read<OrderProvider>();

    await orders.crearPedido(
      idUsuario: auth.user!.id,
      nombreUsuario: auth.user!.nombre,
      productos: cart.items,
      total: cart.total,
      direccionEntrega: auth.user?.direccion,
    );

    cart.limpiarCarrito();

    if (mounted) {
      setState(() => _processing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Pago exitoso! Pedido realizado.')),
      );
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(child: Text('Carrito vacío')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: _processing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 80, height: 80,
                    child: CircularProgressIndicator(strokeWidth: 6, color: AppColors.verdeOliva),
                  ),
                  SizedBox(height: 24),
                  Text('Procesando pago...', style: TextStyle(fontSize: 20, color: AppColors.verdeOliva, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Por favor espera', style: TextStyle(color: AppColors.textoGris)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dirección de entrega', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.verdeOliva)),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.location_on, color: AppColors.verdeOliva),
                      title: Text(auth.user?.direccion ?? 'Sin dirección'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Resumen del pedido', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.verdeOliva)),
                  const SizedBox(height: 12),
                  ...cart.items.map((item) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.shopping_basket, color: AppColors.verdeOliva),
                      title: Text(item.nombre),
                      subtitle: Text('${item.cantidad} x \$${item.precioUnitario.toStringAsFixed(2)}'),
                      trailing: Text('\$${item.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )),
                  const Divider(thickness: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('\$${cart.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.rosa)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text('Método de pago', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.verdeOliva)),
                  const SizedBox(height: 12),
                  _buildCreditCard(),
                  const SizedBox(height: 12),
                  if (_showPaymentForm) _buildCardForm(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _showPaymentForm
                          ? (_cardValid ? _procesarPago : null)
                          : () => setState(() => _showPaymentForm = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.verdeOliva,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text(
                        _showPaymentForm ? 'Pagar \$${cart.total.toStringAsFixed(2)}' : 'Proceder al pago',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCreditCard() {
    return Container(
      height: 190,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppColors.verdeOliva, Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: AppColors.verdeOliva.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('💳', style: TextStyle(fontSize: 28)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                  child: const Text('VISA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
            Text(
              _cardNumberCtrl.text.isEmpty ? '····  ····  ····  ····' : _cardNumberCtrl.text,
              style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TITULAR', style: TextStyle(color: Colors.white70, fontSize: 10)),
                    const SizedBox(height: 4),
                    Text(_cardNameCtrl.text.isEmpty ? 'Nombre del titular' : _cardNameCtrl.text.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('VENCE', style: TextStyle(color: Colors.white70, fontSize: 10)),
                    const SizedBox(height: 4),
                    Text(_expiryCtrl.text.isEmpty ? 'MM/AA' : _expiryCtrl.text, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Column(
      children: [
        TextField(
          controller: _cardNumberCtrl,
          decoration: const InputDecoration(
            labelText: 'Número de tarjeta',
            prefixIcon: Icon(Icons.credit_card, color: AppColors.verdeOliva),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
            _CardNumberFormatter(),
          ],
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _cardNameCtrl,
          decoration: const InputDecoration(
            labelText: 'Nombre del titular',
            prefixIcon: Icon(Icons.person, color: AppColors.verdeOliva),
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _expiryCtrl,
                decoration: const InputDecoration(
                  labelText: 'Vencimiento',
                  hintText: 'MM/AA',
                  prefixIcon: Icon(Icons.calendar_today, color: AppColors.verdeOliva, size: 20),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  _ExpiryFormatter(),
                ],
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _cvvCtrl,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  prefixIcon: Icon(Icons.lock_outline, color: AppColors.verdeOliva, size: 20),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll('/', '');
    if (digits.length >= 3) {
      return TextEditingValue(
        text: '${digits.substring(0, 2)}/${digits.substring(2)}',
        selection: TextSelection.collapsed(offset: digits.length + 1),
      );
    }
    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}
