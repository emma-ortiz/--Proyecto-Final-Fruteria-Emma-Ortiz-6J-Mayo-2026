import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:olivos_verdes/providers/auth_provider.dart';
import 'package:olivos_verdes/features/splash/splash_screen.dart';
import 'package:olivos_verdes/features/welcome/welcome_screen.dart';
import 'package:olivos_verdes/features/products/public_menu_screen.dart';
import 'package:olivos_verdes/features/auth/login_screen.dart';
import 'package:olivos_verdes/features/auth/register_screen.dart';
import 'package:olivos_verdes/features/auth/forgot_password_screen.dart';
import 'package:olivos_verdes/features/home/home_screen.dart';
import 'package:olivos_verdes/features/products/products_screen.dart';
import 'package:olivos_verdes/features/products/product_detail_screen.dart';
import 'package:olivos_verdes/features/categories/categories_screen.dart';
import 'package:olivos_verdes/features/cart/cart_screen.dart';
import 'package:olivos_verdes/features/checkout/checkout_screen.dart';
import 'package:olivos_verdes/features/profile/profile_screen.dart';
import 'package:olivos_verdes/features/offers/offers_screen.dart';
import 'package:olivos_verdes/features/admin/admin_dashboard.dart';
import 'package:olivos_verdes/features/admin/manage_products.dart';
import 'package:olivos_verdes/features/admin/manage_categories.dart';
import 'package:olivos_verdes/features/admin/manage_offers.dart';
import 'package:olivos_verdes/features/admin/manage_orders.dart';

final GlobalKey<NavigatorState> _rootNavigator = GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigator,
  initialLocation: '/splash',
  redirect: (context, state) {
    final auth = context.read<AuthProvider>();
    final isLoggedIn = auth.user != null;
    final isAuthRoute = state.matchedLocation == '/welcome' ||
        state.matchedLocation == '/menu' ||
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/forgot-password' ||
        state.matchedLocation == '/splash';

    if (!isLoggedIn && !isAuthRoute) return '/welcome';
    if (isLoggedIn && isAuthRoute) return '/home';
    return null;
  },
  routes: [
    GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
    GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
    GoRoute(path: '/menu', builder: (_, _) => const PublicMenuScreen()),
    GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
    GoRoute(path: '/forgot-password', builder: (_, _) => const ForgotPasswordScreen()),
    GoRoute(
      path: '/home',
      builder: (_, _) => const HomeScreen(),
      routes: [
        GoRoute(path: 'productos', builder: (_, state) => ProductsScreen(categoriaId: state.extra as String?)),
        GoRoute(path: 'productos/:id', builder: (_, state) => ProductDetailScreen(id: state.pathParameters['id']!)),
        GoRoute(path: 'categorias', builder: (_, _) => const CategoriesScreen()),
        GoRoute(path: 'carrito', builder: (_, _) => const CartScreen()),
        GoRoute(path: 'checkout', builder: (_, _) => const CheckoutScreen()),
        GoRoute(path: 'perfil', builder: (_, _) => const ProfileScreen()),
        GoRoute(path: 'ofertas', builder: (_, _) => const OffersScreen()),
      ],
    ),
    GoRoute(
      path: '/admin',
      builder: (_, _) => const AdminDashboard(),
      routes: [
        GoRoute(path: 'productos', builder: (_, _) => const ManageProductsScreen()),
        GoRoute(path: 'categorias', builder: (_, _) => const ManageCategoriesScreen()),
        GoRoute(path: 'ofertas', builder: (_, _) => const ManageOffersScreen()),
        GoRoute(path: 'pedidos', builder: (_, _) => const ManageOrdersScreen()),
      ],
    ),
  ],
);
