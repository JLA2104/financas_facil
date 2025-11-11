import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/user_controller.dart';
import '../models/user.dart';

class PerfilUsuarioPage extends StatefulWidget {
  @override
  _PerfilUsuarioPageState createState() => _PerfilUsuarioPageState();
}

class _PerfilUsuarioPageState extends State<PerfilUsuarioPage> {
  final UserController _controller = UserController();

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  bool _loading = true;
  UserModel? _user;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _telefoneCtrl = TextEditingController();
  final TextEditingController _senhaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = _uid;
    if (uid == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      final user = await _controller.obterPorId(uid);
      if (user != null) {
        _user = user;
        _nomeCtrl.text = user.nome;
        _emailCtrl.text = user.email;
        _telefoneCtrl.text = user.telefone ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar usuário: $e')));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_user == null) return;

    setState(() {
      _loading = true;
    });

    try {
      final updated = _user!.copyWith(
        nome: _nomeCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        telefone: _telefoneCtrl.text.trim().isEmpty ? null : _telefoneCtrl.text.trim(),
        senha: _senhaCtrl.text.trim().isEmpty ? _user!.senha : _senhaCtrl.text.trim(),
        atualizadoEm: DateTime.now(),
      );

      await _controller.atualizar(_user!.id!, updated);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dados atualizados com sucesso.')));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao atualizar dados: $e')));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _telefoneCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meu perfil'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _uid == null
              ? Center(child: Text('Usuário não autenticado'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        TextFormField(
                          controller: _nomeCtrl,
                          decoration: InputDecoration(labelText: 'Nome'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Nome é obrigatório' : null,
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _emailCtrl,
                          decoration: InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Email é obrigatório' : null,
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _telefoneCtrl,
                          decoration: InputDecoration(labelText: 'Telefone (opcional)'),
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _senhaCtrl,
                          decoration: InputDecoration(labelText: 'Senha (opcional)'),
                          obscureText: true,
                        ),
                        SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('Cancelar'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                            ),
                            ElevatedButton(
                              onPressed: _salvar,
                              child: Text('Salvar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
