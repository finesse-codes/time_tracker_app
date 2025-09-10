import 'package:flutter/material.dart';
import 'package:time_tracker/screens/home_screen.dart';
import 'package:localstorage/localstorage.dart';
import 'provider/time_entry_provider.dart';
import 'package:provider/provider.dart';

late final ValueNotifier<int> notifier;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalStorage();
  runApp(MyApp(localStorage: localStorage));
}

class MyApp extends StatelessWidget {
  final LocalStorage localStorage;
  const MyApp({super.key, required this.localStorage});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // wrap the materialApp with the ChangeNotifierProvider
    return ChangeNotifierProvider<TimeEntryProvider>(
      create: (_) => TimeEntryProvider(storage: localStorage),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Time Tracker',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: HomeScreen(),
      ),
    );
  }
}
