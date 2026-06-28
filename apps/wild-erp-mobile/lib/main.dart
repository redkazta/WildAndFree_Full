import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'app.dart';
import 'ui/providers/auth_provider.dart';
import 'ui/providers/dashboard_provider.dart';
import 'ui/providers/orders_provider.dart';
import 'ui/providers/inventory_provider.dart';
import 'ui/providers/content_provider.dart';
import 'ui/providers/users_provider.dart';
// force rebuild: gradle.properties cleaned

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => ContentProvider()),
        ChangeNotifierProvider(create: (_) => UsersProvider()),
      ],
      child: const WildErpApp(),
    ),
  );
}
