import 'package:flutter/material.dart'; // basic import
import 'package:flutter_riverpod/flutter_riverpod.dart'; // state manager riverpod
import 'models/database.dart'; // drift DB
import 'providers/report_provider.dart'; // custom riverpod provider
import 'services/database_service.dart'; // local DB service
import 'screens/home_screen.dart'; // main screen

// entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ensure Flutter has initialized

  final db = AppDatabase(); // open (or create) the SQLite database
  final dbService = DatabaseService(db);

  // start App core
  runApp(
    // Provide global storage
    ProviderScope(
      overrides: [
        databaseServiceProvider.overrideWithValue(dbService), // provide existing DB service instance
      ],
      child: const NotoryApp(), // connect main App class
    ),
  );
}


// main application container
class NotoryApp extends StatelessWidget {
  const NotoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notory',
      debugShowCheckedModeBanner: false, // off debug line
      themeMode: ThemeMode.dark, // darkmode
      darkTheme: ThemeData(
        useMaterial3: true, // new Google design
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
          surface: const Color(0xFF1E293B), // Slate 800
          primary: Colors.indigoAccent,
          secondary: Colors.tealAccent,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A), // background
        appBarTheme: const AppBarTheme( // top panel theme
          backgroundColor: Color(0xFF0F172A),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        cardTheme: const CardThemeData( // cards theme
          color: Color(0xFF1E293B),
          elevation: 4,
        ),
      ),
      home: const HomeScreen(), // first users screen
    );
  }
}
