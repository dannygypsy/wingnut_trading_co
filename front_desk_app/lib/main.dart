
import 'package:flutter/material.dart';
import 'package:front_desk_app/model/values.dart';
import 'package:provider/provider.dart';

import 'provider/printer_provider.dart';
import 'util/db.dart';
import 'views/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DatabaseHandler handler = DatabaseHandler();
  await handler.initializeDB();

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
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

