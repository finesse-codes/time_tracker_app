import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:localstorage/localstorage.dart';

import 'provider/time_entry_provider.dart';
import 'provider/project_task_provider.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise storage once
  await initLocalStorage();
  final storage = localStorage; // ✅ this is the usable instance

  runApp(MyApp(localStorage: storage));
}

class MyApp extends StatelessWidget {
  final LocalStorage localStorage;
  const MyApp({super.key, required this.localStorage});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TimeEntryProvider(storage: localStorage),
        ),
        ChangeNotifierProvider(
          create: (_) => ProjectTaskProvider(storage: localStorage),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Time Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,

          scaffoldBackgroundColor: const Color.fromARGB(244, 246, 250, 254),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 30,

              fontWeight: FontWeight.bold,
            ),

            iconTheme: IconThemeData(color: Colors.white),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.blue, // whole nav bar background
            selectedItemColor: Colors.white, // selected icon/text colour
            unselectedItemColor: Colors.white70, // unselected icon/text
            showUnselectedLabels:
                true, // whether to show labels on inactive items
            type: BottomNavigationBarType.fixed, // keeps all items visible
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.blue, // FAB background
            foregroundColor: Colors.white, // Icon/text colour
            elevation: 6, // Shadow
            shape: CircleBorder(), // Rounded shape (default is circular anyway)
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
