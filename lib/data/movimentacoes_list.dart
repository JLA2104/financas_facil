// Lista simples em memória de movimentações

final List<Map<String, dynamic>> movimentacoes = [
  {
    'data': DateTime.now(),
    'nome': 'Salário',
    'categoria': 'Renda',
    'valor': 3000.00,
    'tipo': 'entrada',
  },
  {
    'data': DateTime.now().subtract(Duration(days: 1)),
    'nome': 'Mercado',
    'categoria': 'Alimentação',
    'valor': -120.50,
    'tipo': 'despesa',
  },
  {
    'data': DateTime.now().subtract(Duration(days: 2)),
    'nome': 'Internet',
    'categoria': 'Serviços',
    'valor': -99.90,
    'tipo': 'despesa',
  },
];

Map<String, dynamic>? findMovimentacao(int index) {
  if (index < 0 || index >= movimentacoes.length) return null;
  return movimentacoes[index];
}

void addMovimentacao(Map<String, dynamic> m) {
  movimentacoes.insert(0, m);
}

void updateMovimentacao(int index, Map<String, dynamic> m) {
  if (index < 0 || index >= movimentacoes.length) return;
  movimentacoes[index] = m;
}

void removeMovimentacaoAt(int index) {
  if (index < 0 || index >= movimentacoes.length) return;
  movimentacoes.removeAt(index);
}
