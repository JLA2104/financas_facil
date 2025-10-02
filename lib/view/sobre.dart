import 'package:flutter/material.dart';

class SobrePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final corPrincipal = Colors.blue[800];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: corPrincipal,
        title: Row(
          children: [
            Icon(Icons.monetization_on, color: Colors.orange),
            SizedBox(width: 8),
            Text('Sobre', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 50, color: corPrincipal),
            SizedBox(height: 20),
            Text(
              'Esse app foi criado pelos alunos da FATEC Ribeirão Preto, Jefferson Amaral e Keyser Figueiredo para a disciplina de Programação de Aplicativos Móveis no curso de Análise e Desenvolvimento de Sistemas; com o intuito de ajudar no controle financeiro das despesas diárias.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 30),
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