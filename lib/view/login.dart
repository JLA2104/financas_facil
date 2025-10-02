import 'package:flutter/material.dart';
import '../data/users_list.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.monetization_on, color: Colors.orange), // Cifrão
            SizedBox(width: 8),
            Text('Finanças Fácil!', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Campo de usuário
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.blue[800]),
              ),
            ),
            SizedBox(height: 16),

            // Campo de senha
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.blue[800]),
              ),
            ),
            SizedBox(height: 16),

            // Botão Entrar
            ElevatedButton(
              onPressed: () {
                final email = _usernameController.text.trim();
                final senha = _passwordController.text;

                if (email.isEmpty || senha.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Preencha e-mail e senha')));
                  return;
                }

                final ok = validateCredentials(email, senha);
                if (ok) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login realizado com sucesso')));
                  Navigator.pushReplacementNamed(context, '/dashboard');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Credenciais inválidas')));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
              ),
              child: Text('Entrar', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 16),

            // Botão Novo Cadastro
            TextButton(
              onPressed: () {
                print('Novo Cadastro');
                Navigator.pushNamed(context, "/cadastro");
              },
              style: TextButton.styleFrom(foregroundColor: Colors.blue[800]),
              child: Text('Novo Cadastro'),
            ),
            SizedBox(height: 8),

            // Botão Recuperar Senha
            TextButton(
              onPressed: () {
                print('Recuperar Senha');
                Navigator.pushNamed(context, "/recuperar");
              },
              style: TextButton.styleFrom(foregroundColor: Colors.blue[800]),
              child: Text('Recuperar Senha'),
            ),

            // Botão Sobre
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/sobre");
              },
              style: TextButton.styleFrom(foregroundColor: Colors.blue[800]),
              child: Text('Sobre'),
            ),
          ],
        ),
      ),
    );
  }
}
