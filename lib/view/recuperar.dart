import 'package:flutter/material.dart';

class RecuperarSenhaPage extends StatefulWidget {
  @override
  _RecuperarSenhaPageState createState() => _RecuperarSenhaPageState();
}

class _RecuperarSenhaPageState extends State<RecuperarSenhaPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final corPrincipal = Colors.blue[800];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.monetization_on, color: Colors.orange),
            SizedBox(width: 8),
            Text('Recuperar Senha', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: corPrincipal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campo de e-mail
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Digite seu e-mail',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: corPrincipal),
              ),
            ),
            SizedBox(height: 24),

            // Botão Enviar
            ElevatedButton(
              onPressed: () {
                // Simula envio de e-mail: apenas mostra um toast e retorna para a tela de login (/)
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('E-mail de recuperação enviado')));
                // Pequeno delay para o usuário ver o toast
                Future.delayed(Duration(milliseconds: 700), () {
                  Navigator.pushReplacementNamed(context, '/');
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: corPrincipal,
              ),
              child: Text(
                'Enviar e-mail de recuperação',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 16),

            // Botão Voltar
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: corPrincipal,
              ),
              child: Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}