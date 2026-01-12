import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gameparrot/auth/auth.dart';
import 'package:gameparrot/providers/auth_provider.dart';
import 'package:gameparrot/home/home.dart';
import 'package:gameparrot/providers/users_provider.dart';
import 'package:gameparrot/providers/games_provider.dart';
import 'package:gameparrot/providers/ws_provider.dart';
import 'package:gameparrot/services/services.dart';
import 'package:gameparrot/theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyDLgYXSj6PN1ArQZM6zCWiNRtGN63knEoQ",
        authDomain: "gameparrot-42906.firebaseapp.com",
        projectId: "gameparrot-42906",
        storageBucket: "gameparrot-42906.firebasestorage.app",
        messagingSenderId: "374287975014",
        appId: "1:374287975014:web:782c0254421addeec1e3a7",
        measurementId: "G-N6V4Q493L6",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<FirebaseAuthProvider>(
          create: (_) => FirebaseAuthProvider(),
        ),
        // Provide a single WebSocketService instance
        Provider<WebSocketService>(
          create: (_) => WebSocketService(),
          dispose: (_, svc) => svc.closeWsChannel(),
        ),
        ChangeNotifierProxyProvider<WebSocketService, WebSocketProvider>(
          create: (ctx) => WebSocketProvider(ctx.read<WebSocketService>()),
          update: (ctx, svc, prev) => prev ?? WebSocketProvider(svc),
        ),
        ChangeNotifierProxyProvider<WebSocketService, UsersProvider>(
          create: (ctx) => UsersProvider(ctx.read<WebSocketService>()),
          update: (ctx, svc, prev) => prev ?? UsersProvider(svc),
        ),
        ChangeNotifierProxyProvider<WebSocketService, GamesProvider>(
          create: (ctx) => GamesProvider(ctx.read<WebSocketService>()),
          update: (ctx, svc, prev) => prev ?? GamesProvider(svc),
        ),
      ],
      child: const App(),
    ),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _MyAppState();
}

class _MyAppState extends State<App> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<FirebaseAuthProvider>(
        context,
        listen: false,
      );

      if (authProvider.uid == null) {
        authProvider.authUser();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<FirebaseAuthProvider>(context);

    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: authProvider.uid == null ? const AuthScreen() : const Home(),
    );
  }
}
