
import 'package:flutter/material.dart';
import 'package:front_desk_app/model/values.dart';
import 'package:front_desk_app/provider/inventory_provider.dart';
import 'package:front_desk_app/provider/order_provider.dart' show OrderProvider;
import 'package:provider/provider.dart';

import 'provider/printer_provider.dart';
import 'util/db.dart';
import 'views/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DatabaseHandler handler = DatabaseHandler();
  // handler.resetDatabase();  // TODO: Don't leave this in!!
  await handler.initializeDB();

  InventoryProvider ip = InventoryProvider();
  await ip.loadItems();

  runApp(MyApp(ip));
}


class MyApp extends StatelessWidget {
  final InventoryProvider inventoryProvider;
  MyApp(this.inventoryProvider);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    ThemeData light =  ThemeData(
      // Define the default brightness and colors.
        brightness: Brightness.light,
        primaryColor: Colors.orange,
        primarySwatch: Colors.orange,
        appBarTheme: const AppBarTheme(
          backgroundColor: const Color(0xcc5500),
        ),
        colorScheme: ColorScheme.light(
          primary: Colors.orange,
          secondary: Colors.deepOrange,
        ) //4e5a72
    );

    ThemeData dark =  ThemeData(
      // Define the default brightness and colors.
        brightness: Brightness.dark,
        primaryColor: Colors.orange,
        primarySwatch: Colors.orange,
        appBarTheme: const AppBarTheme(
            backgroundColor: const Color(0xFFCC5500)
        ),
        colorScheme: ColorScheme.dark(
          primary: Colors.orange,
          secondary: Colors.deepOrange,
        )
    );



    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => PrinterProvider()),
          ChangeNotifierProvider(create: (context) => OrderProvider()),
          ChangeNotifierProvider(create: (context) => inventoryProvider),
        ],
        child: MaterialApp(
          home: HomeScreen(),
          navigatorKey: Values.navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: light,
          darkTheme: dark,
        )
    );

  }
}

