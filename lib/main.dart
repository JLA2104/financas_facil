import 'package:financas_facil/firebase_options.dart';
import 'package:financas_facil/view/cadastro.dart';
import 'package:financas_facil/view/dashboard.dart';
import 'package:financas_facil/view/recuperar.dart';
import 'package:financas_facil/view/sobre.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import "view/login.dart";
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

runApp(DevicePreview(enabled: true, builder: (context) => MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finanças Fácil!',
      theme: ThemeData(
        primaryColor: Colors.blue[800], // Azul escuro
        colorScheme: ColorScheme.light(
          primary: Colors.blue[800]!, // Cor principal
          secondary: Colors.orange,   // Cor secundária (laranja)
        ),
      ),
      routes: {
        "/": (context) => LoginPage(),
        "/cadastro": (context) => CadastroPage(),
        "/recuperar": (context) => RecuperarSenhaPage(),
        "/sobre": (context) => SobrePage(),
        "/dashboard": (context) => DashboardPage(), // Temporário
      },
    );
  }
}
