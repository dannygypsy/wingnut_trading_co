
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockroom/provider/inventory_provider.dart';
import 'config/config.dart';
import 'views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  MyApp();

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
          ChangeNotifierProvider<InventoryProvider>(create: (_) => InventoryProvider()),
        ],
        child: MaterialApp(
          home: HomeScreen(),
          navigatorKey: Config.navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: light,
          darkTheme: dark,
        )
    );

  }
}

