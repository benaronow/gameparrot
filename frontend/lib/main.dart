import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gameparrot/auth/auth.dart';
import 'package:gameparrot/providers/auth_provider.dart';
import 'package:gameparrot/home/home.dart';
import 'package:gameparrot/providers/users_provider.dart';
import 'package:gameparrot/theme.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
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
    ChangeNotifierProvider<FirebaseAuthProvider>(
      create: (context) => FirebaseAuthProvider(),
      child: App(),
    ),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _MyAppState();
}

class _MyAppState extends State<App> {
  late WebSocketChannel channel;

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
      home: authProvider.uid == null
          ? AuthScreen()
          : Builder(
              builder: (context) => ChangeNotifierProvider<UsersProvider>(
                create: (context) => UsersProvider(),
                child: Home(),
              ),
            ),
    );
  }
}
