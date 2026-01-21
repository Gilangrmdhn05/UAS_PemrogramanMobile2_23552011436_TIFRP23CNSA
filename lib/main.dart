import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warungku_mobile/providers/auth_provider.dart';
import 'package:warungku_mobile/providers/cart_provider.dart';
import 'package:warungku_mobile/providers/checkout_provider.dart';
import 'package:warungku_mobile/providers/product_provider.dart';
import 'package:warungku_mobile/providers/order_provider.dart'; // Import OrderProvider
import 'package:warungku_mobile/screens/auth/login_screen.dart';
import 'package:warungku_mobile/screens/auth/register_screen.dart';
import 'package:warungku_mobile/screens/cart_screen.dart';
import 'package:warungku_mobile/screens/checkout_screen.dart';
import 'package:warungku_mobile/screens/edit_profile_screen.dart';
import 'package:warungku_mobile/screens/home_screen.dart';
import 'package:warungku_mobile/screens/profile_screen.dart';
import 'package:warungku_mobile/screens/splash_screen.dart';
import 'package:warungku_mobile/screens/order_screen.dart'; // Import OrderHistoryScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ProductProvider>(
          create: (_) => ProductProvider(),
          update: (ctx, auth, previousProducts) =>
              (previousProducts ?? ProductProvider())..update(auth.token, auth.userId),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CheckoutProvider()),
        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
          create: (_) => OrderProvider(),
          update: (ctx, auth, previousOrders) =>
              (previousOrders ?? OrderProvider())..update(auth.token, auth.userId),
        ),
      ],
      child: MaterialApp(
        title: 'Warungku',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          scaffoldBackgroundColor: Colors.grey[100],
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            elevation: 1,
            centerTitle: true,
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          CartScreen.routeName: (context) => const CartScreen(),
          CheckoutScreen.routeName: (context) => const CheckoutScreen(),
          OrderScreen.routeName: (context) => const OrderScreen(), // Add OrderHistoryScreen route
          ProfileScreen.routeName: (context) => const ProfileScreen(),
          EditProfileScreen.routeName: (context) => const EditProfileScreen(),
        },
      ),
    );
  }
}
