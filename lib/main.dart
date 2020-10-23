import './models/data_model.dart';
import './models/fcm_provider.dart';
import './screens/notifications_screen.dart';

import './screens/admin_screen.dart';
import './screens/user_profile_screen.dart';

import './models/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import './screens/signup_screen.dart';

import 'screens/login_screen.dart';
import './screens/welcome_screen.dart';

import './screens/product_category_screen.dart';
import './screens/edit_user_product_screen.dart';

import './screens/user_products_screen.dart';

import './screens/orders_screen.dart';

import './models/orders_provider.dart';

import './models/cart_provider.dart';
import './screens/cart_screen.dart';

import './screens/home_page_tabs_screen.dart';
import './models/product_provider.dart';
import './screens/product_desc_screen.dart';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //  multiprovider with several childs change notifier for changes in
    //  ->  ProdutsProvider(list of products)
    //  -> CartProvider (list of cart-items)

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrdersProvider(),
        ),
        Provider<AuthProvider>(
          create: (_) => AuthProvider(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (ctx) => ctx.read<AuthProvider>().authStateChanges,
        ),
        ChangeNotifierProvider(
          create: (_) => FcmProvider(),
        ),
      ],
      child: MaterialApp(
        title: "Kirana Mart",
        theme: ThemeData(
          primarySwatch: Colors.teal,
          brightness: Brightness.dark,
          accentColor: Colors.blue,
          primaryColor: Colors.teal[900],
          fontFamily: "QuickSand",
          highlightColor: Colors.white,
          textTheme: TextTheme(headline6: TextStyle(color: Colors.black)),
        ),
        themeMode: ThemeMode.dark,
        home: AuthenticationWrapper(),
        routes: {
          HomePageTabsScreen.routeName: (ctx) => HomePageTabsScreen(),
          ProductDescription.routeName: (ctx) => ProductDescription(),
          CartScreen.routeName: (ctx) => CartScreen(),
          OrdersScreen.routeName: (ctx) => OrdersScreen(),
          UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
          EditUserProductScreen.routeName: (ctx) => EditUserProductScreen(),
          ProductsByCategoryScreen.routeName: (ctx) =>
              ProductsByCategoryScreen(),
          LoginScreen.routeName: (ctx) => LoginScreen(),
          SignUpScreen.routeName: (ctx) => SignUpScreen(),
          WelcomeScreen.routeName: (ctx) => WelcomeScreen(),
          AdminScreen.routeName: (ctx) => AdminScreen(),
          UserProfileScreen.routeName: (ctx) => UserProfileScreen(),
          NotificationsScreen.routeName: (ctx) => NotificationsScreen(),
        },
      ),
    );
  }
}

//  Wrapper to check whether user is authenticated while splash screen is shown
//  Admin screen is visible only for admin
class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //  initialize the fcm provider
    Provider.of<FcmProvider>(context, listen: false).initialize();
    //  To check whether user is logged in before or not
    final _firebaseUser = context.watch<User>();
    if (_firebaseUser == null)
      return WelcomeScreen();
    else if (_firebaseUser.email == DataModel.adminEmail)
      return AdminScreen();
    else
      return HomePageTabsScreen();
  }
}
