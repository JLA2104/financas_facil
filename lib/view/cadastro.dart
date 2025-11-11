import 'package:flutter/material.dart';
import '../controllers/user_controller.dart';

class CadastroPage extends StatefulWidget {
  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final corPrincipal = Colors.blue[800];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.monetization_on, color: Colors.orange),
            SizedBox(width: 8),
            Text('Cadastro', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: corPrincipal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Para evitar overflow em telas pequenas
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nome
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: corPrincipal),
                ),
              ),
              SizedBox(height: 16),

              // E-mail
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: corPrincipal),
                ),
              ),
              SizedBox(height: 16),

              // Telefone
              TextField(
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: corPrincipal),
                ),
              ),
              SizedBox(height: 16),

              // Senha
              TextField(
                controller: _senhaController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: corPrincipal),
                ),
              ),
              SizedBox(height: 16),

              // Confirmar senha
              TextField(
                controller: _confirmarSenhaController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirmar Senha',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: corPrincipal),
                ),
              ),
              SizedBox(height: 24),

              // Botão Cadastrar
              ElevatedButton(
                onPressed: () async {
                  final nome = _nomeController.text.trim();
                  final email = _emailController.text.trim();
                  final telefone = _telefoneController.text.trim();
                  final senha = _senhaController.text;
                  final confirmar = _confirmarSenhaController.text;
                  final controller = UserController();

                  if (nome.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Informe o nome')));
                    return;
                  }
                  if (!email.contains('@') || email.length < 5) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('E-mail inválido')));
                    return;
                  }
                  if (senha.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('A senha deve ter ao menos 6 caracteres')));
                    return;
                  }
                  if (senha != confirmar) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Senhas não coincidem')));
                    return;
                  }

                  try {
                    // Registra com FirebaseAuth e cria o documento no Firestore
                    await controller.registerWithEmailAndPassword(
                      nome: nome,
                      email: email,
                      senha: senha,
                      telefone: telefone.isEmpty ? null : telefone,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cadastro realizado com sucesso')));
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao cadastrar: $e')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: corPrincipal,
                ),
                child: Text('Cadastrar', style: TextStyle(color: Colors.white)),
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
      ),
    );
  }
}
