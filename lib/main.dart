import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:startup_namer/providers/auth.dart';
import 'package:startup_namer/providers/favorites.dart';
import 'package:startup_namer/screens/favorites.dart';
import 'package:startup_namer/screens/login.dart';
import 'package:startup_namer/screens/startup_names.dart';

void main() {
  // runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<Auth>(
              create: (_) => Auth.instance()),
          ChangeNotifierProvider<Favorites>(
              create: (_) => Favorites.instance)
        ],
        child: MaterialApp(
          title: 'Startup Name Generator',
          theme: ThemeData(
            // Add the 5 lines from here...
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.deepPurple,
            ),
          ), // ... to here.
          initialRoute: '/',
          routes: {
            '/': (context) => const StartupNames(),
            '/login': (context) => const LoginScreen(),
            '/favorites': (context) => const FavoritesScreen(),
          },
        ));
  }
}

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return const MyApp();
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}


