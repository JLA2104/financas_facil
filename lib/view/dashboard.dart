import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/movimentacao_controller.dart';
import '../models/movimentacao.dart';
import 'cadastro_despesa.dart';
import 'cadastro_entrada.dart';
import 'motivo_exclusao.dart';
import 'grafico_despesas.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final corPrincipal = Colors.blue[800];
  final MovimentacaoController _controller = MovimentacaoController();

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // Saldo será calculado a partir do snapshot das movimentações

  //  Formatando a data manualmente como dd/mm/yyyy
  String formatarData(DateTime data) {
    String dia = data.day.toString().padLeft(2, '0');
    String mes = data.month.toString().padLeft(2, '0');
    String ano = data.year.toString();
    return '$dia/$mes/$ano';
  }

  //  Formatando valores manualmente como "R$ 1000.00"
  String formatarValor(double valor) {
    String valorFormatado = valor.abs().toStringAsFixed(2).replaceAll('.', ',');
    return (valor < 0 ? '- ' : '') + 'R\$ $valorFormatado';
  }

  Color corValor(double valor) {
    return valor >= 0 ? Colors.green : Colors.red;
  }

  Future<void> _excluirMovimentacaoPorId(String id, String motivo) async {
    try {
      await _controller.deletar(id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Movimentação removida: $motivo'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao remover movimentação: $e'),
      ));
    }
  }

  void _editarMovimentacao(Movimentacao mov) {
    final tipo = mov.tipo;
    final initial = {
      'data': mov.data,
      'nome': mov.nome,
      'categoria': mov.categoria,
      'valor': mov.valor,
      'tipo': mov.tipo,
    };

    final route = tipo == 'entrada'
        ? CadastroEntradaPage(movimentacaoInicial: initial)
        : CadastroDespesaPage(movimentacaoInicial: initial);

    Navigator.of(context)
        .push<Map<String, dynamic>>(MaterialPageRoute(builder: (_) => route))
        .then((res) async {
      if (res != null) {
        try {
          final updated = Movimentacao(
            id: mov.id,
            data: res['data'] as DateTime,
            nome: res['nome'] as String,
            categoria: res['categoria'] as String,
            valor: (res['valor'] as num).toDouble(),
            tipo: res['tipo'] as String,
            usuarioId: mov.usuarioId,
            atualizadoEm: DateTime.now(),
          );
          await _controller.atualizar(mov.id!, updated);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Movimentação atualizada com sucesso.'),
          ));
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro ao atualizar movimentação: $e'),
          ));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: corPrincipal,
        title: Row(
          children: [
            Icon(Icons.monetization_on, color: Colors.orange),
            SizedBox(width: 8),
            Text('Finanças Fácil!', style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Gráfico de despesas',
            icon: Icon(Icons.pie_chart),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => GraficoDespesasPage()));
            },
          ),
          IconButton(
            tooltip: 'Logout',
            icon: Icon(Icons.logout),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logout realizado')));
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: _uid == null
          ? Center(child: Text('Usuário não autenticado'))
          : StreamBuilder<List<Movimentacao>>(
              stream: _controller.obterStreamDoUsuario(_uid!),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  final errorMsg = snapshot.error.toString();
                  // Se for erro de índice, mostre mensagem amigável
                  if (errorMsg.contains('FAILED_PRECONDITION') || errorMsg.contains('requires an index')) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warning, color: Colors.orange, size: 48),
                            SizedBox(height: 16),
                            Text(
                              'Índice sendo criado...',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Por favor, aguarde alguns minutos e recarregue a página.',
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {});
                              },
                              child: Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Center(child: Text('Erro: $errorMsg'));
                }
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final movimentacoes = snapshot.data!;
                final saldo = movimentacoes.fold<double>(0.0, (s, m) => s + m.valor);

                return Column(
                  children: [
                    Container(
                      color: corPrincipal,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          Text(
                            'Saldo Disponível',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'R\$ ${saldo.toStringAsFixed(2).replaceAll('.', ',')}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Botões de entrada e despesa
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context)
                                  .push<Map<String, dynamic>>(MaterialPageRoute(
                                builder: (_) => CadastroEntradaPage(),
                              )).then((mov) async {
                                if (mov != null) {
                                  try {
                                    final nova = Movimentacao(
                                      data: mov['data'] as DateTime,
                                      nome: mov['nome'] as String,
                                      categoria: mov['categoria'] as String,
                                      valor: (mov['valor'] as num).toDouble(),
                                      tipo: mov['tipo'] as String,
                                      usuarioId: _uid,
                                    );
                                    await _controller.criar(nova);
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text('Entrada adicionada com sucesso.'),
                                    ));
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text('Erro ao adicionar entrada: $e'),
                                    ));
                                  }
                                }
                              });
                            },
                            icon: Icon(Icons.add, color: Colors.white),
                            label: Text('Entrada', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context)
                                  .push<Map<String, dynamic>>(MaterialPageRoute(
                                builder: (_) => CadastroDespesaPage(),
                              )).then((mov) async {
                                if (mov != null) {
                                  try {
                                    final nova = Movimentacao(
                                      data: mov['data'] as DateTime,
                                      nome: mov['nome'] as String,
                                      categoria: mov['categoria'] as String,
                                      valor: (mov['valor'] as num).toDouble(),
                                      tipo: mov['tipo'] as String,
                                      usuarioId: _uid,
                                    );
                                    await _controller.criar(nova);
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text('Despesa adicionada com sucesso.'),
                                    ));
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text('Erro ao adicionar despesa: $e'),
                                    ));
                                  }
                                }
                              });
                            },
                            icon: Icon(Icons.remove, color: Colors.white,),
                            label: Text('Despesa', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          ),
                        ],
                      ),
                    ),

                    // Lista de movimentações
                    Expanded(
                      child: movimentacoes.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inbox, color: Colors.grey, size: 48),
                                  SizedBox(height: 16),
                                  Text(
                                    'Nenhuma movimentação cadastrada',
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Comece adicionando uma entrada ou despesa',
                                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                        itemCount: movimentacoes.length,
                        itemBuilder: (context, index) {
                          final mov = movimentacoes[index];
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: ListTile(
                              leading: Icon(
                                mov.tipo == 'entrada' ? Icons.arrow_downward : Icons.arrow_upward,
                                color: corValor(mov.valor),
                              ),
                              title: Text(mov.nome),
                              subtitle: Text('${mov.categoria} • ${formatarData(mov.data)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    formatarValor(mov.valor),
                                    style: TextStyle(
                                      color: corValor(mov.valor),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.grey[700]),
                                    onPressed: () => _editarMovimentacao(mov),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      final motivo = await Navigator.of(context).push<String?>(
                                        MaterialPageRoute(builder: (_) => MotivoExclusaoPage()),
                                      );
                                      if (motivo != null && motivo.trim().isNotEmpty) {
                                        await _excluirMovimentacaoPorId(mov.id!, motivo);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
