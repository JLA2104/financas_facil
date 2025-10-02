import 'package:flutter/material.dart';

class CadastroDespesaPage extends StatefulWidget {
  final Map<String, dynamic>? movimentacaoInicial;

  const CadastroDespesaPage({Key? key, this.movimentacaoInicial}) : super(key: key);

  @override
  _CadastroDespesaPageState createState() => _CadastroDespesaPageState();
}

class _CadastroDespesaPageState extends State<CadastroDespesaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  DateTime _data = DateTime.now();

  @override
  void dispose() {
    _nomeController.dispose();
    _categoriaController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final nome = _nomeController.text.trim();
      final categoria = _categoriaController.text.trim();
      final valor = double.tryParse(
              _valorController.text.replaceAll(',', '.').trim()) ??
          0.0;

      final movimento = {
        'data': _data,
        'nome': nome,
        'categoria': categoria.isEmpty ? 'Outros' : categoria,
        // despesas devem ser valores negativos
        'valor': -valor.abs(),
        'tipo': 'despesa',
      };

      // Retornar também uma flag 'acao' para o caller se quiser diferenciar (opcional)
      movimento['acao'] = widget.movimentacaoInicial == null ? 'adicao' : 'edicao';

      Navigator.of(context).pop(movimento);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _data = picked);
  }

  @override
  Widget build(BuildContext context) {
    // se vier uma movimentacao inicial (edição), preenche os campos
    if (widget.movimentacaoInicial != null) {
      final m = widget.movimentacaoInicial!;
      _nomeController.text = m['nome'] ?? '';
      _categoriaController.text = m['categoria'] ?? '';
      final v = m['valor'] as double? ?? 0.0;
      _valorController.text = v.abs().toStringAsFixed(2);
      _data = m['data'] ?? _data;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Despesa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Informe o nome da despesa'
                    : null,
              ),
              TextFormField(
                controller: _categoriaController,
                decoration: const InputDecoration(labelText: 'Categoria'),
              ),
              TextFormField(
                controller: _valorController,
                decoration: const InputDecoration(labelText: 'Valor (ex: 120.50)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o valor';
                  final parsed = double.tryParse(v.replaceAll(',', '.'));
                  if (parsed == null || parsed <= 0) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text('Data: ${_data.day.toString().padLeft(2, '0')}/${_data.month.toString().padLeft(2, '0')}/${_data.year}'),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Alterar'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Salvar Despesa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
