import 'package:flutter/material.dart';

class MotivoExclusaoPage extends StatefulWidget {
  const MotivoExclusaoPage({Key? key}) : super(key: key);

  @override
  _MotivoExclusaoPageState createState() => _MotivoExclusaoPageState();
}

class _MotivoExclusaoPageState extends State<MotivoExclusaoPage> {
  final TextEditingController _motivoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(_motivoController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Motivo da exclusão'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _motivoController,
                decoration: const InputDecoration(
                  labelText: 'Informe o motivo da exclusão',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Motivo obrigatório para excluir'
                    : null,
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _confirmar,
                    child: const Text('Confirmar exclusão'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
