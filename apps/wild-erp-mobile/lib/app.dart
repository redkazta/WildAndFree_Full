import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/orders_screen.dart';
import 'ui/screens/order_detail_screen.dart';
import 'ui/screens/inventory_screen.dart';
import 'ui/screens/product_detail_screen.dart';
import 'ui/screens/content_screen.dart';
import 'ui/screens/users_screen.dart';
import 'ui/screens/user_detail_screen.dart';
import 'ui/screens/tags_screen.dart';
import 'ui/screens/events_screen.dart';
import 'ui/screens/versus_screen.dart';
import 'ui/screens/radio_screen.dart';
import 'ui/screens/settings_screen.dart';

class WildErpApp extends StatelessWidget {
  const WildErpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wild Gvng ERP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/orders': (_) => const OrdersScreen(),
        '/inventory': (_) => const InventoryScreen(),
        '/content': (_) => const ContentScreen(),
        '/users': (_) => const UsersScreen(),
        '/tags': (_) => const TagsScreen(),
        '/events': (_) => const EventsScreen(),
        '/versus': (_) => const VersusScreen(),
        '/radio': (_) => const RadioScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name?.startsWith('/order-detail') == true) {
          final orderId = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (_) => OrderDetailScreen(orderId: orderId ?? ''),
          );
        }
        if (settings.name?.startsWith('/product-detail') == true) {
          final productId = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: productId ?? ''),
          );
        }
        if (settings.name?.startsWith('/user-detail') == true) {
          final userId = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (_) => UserDetailScreen(userId: userId ?? ''),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        );
      },
    );
  }
}
