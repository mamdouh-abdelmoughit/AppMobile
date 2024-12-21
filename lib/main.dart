import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:moughit_app/firebase_options.dart';
import 'package:moughit_app/home_page.dart';
import 'package:moughit_app/login_page.dart';
import 'package:moughit_app/pages/home_page.dart';
import 'package:moughit_app/register_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase using the generated options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); 

  //initialize Supabase
  await dotenv.load();
  
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Mamdouh Abdelmoughit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 182, 121, 167)),
        useMaterial3: true,
      ),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/register': (context) => const RegisterPage(),
        '/pages/home_page': (context) => const FirstPage(),
      },
      initialRoute: '/login',
    );
  }
}
