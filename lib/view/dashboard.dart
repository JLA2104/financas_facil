import 'package:flutter/material.dart';
import 'cadastro_despesa.dart';
import 'cadastro_entrada.dart';
import 'motivo_exclusao.dart';
import '../data/movimentacoes_list.dart' as mov_list;
import 'grafico_despesas.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final corPrincipal = Colors.blue[800];

  // Lista de movimentações agora está em `lib/data/movimentacoes_list.dart`

  // saldo agora é um getter para sempre refletir o estado atual de `movimentacoes`
  double get saldo =>
    mov_list.movimentacoes.fold(0.0, (sum, item) => sum + (item['valor'] as double));

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

  void excluirMovimentacao(int index) {
    setState(() {
      mov_list.removeMovimentacaoAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Movimentação removida com sucesso.'),
    ));
  }

  void editarMovimentacao(int index) {
    // abre a tela apropriada de edição dependendo do tipo
  final mov = mov_list.movimentacoes[index];
    final tipo = mov['tipo'] as String? ?? 'despesa';
    final route = tipo == 'entrada'
        ? CadastroEntradaPage(movimentacaoInicial: mov)
        : CadastroDespesaPage(movimentacaoInicial: mov);

    Navigator.of(context)
        .push<Map<String, dynamic>>(MaterialPageRoute(builder: (_) => route))
        .then((res) {
      if (res != null) {
        setState(() {
          mov_list.updateMovimentacao(index, res);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Movimentação atualizada com sucesso.'),
        ));
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
      body: Column(
        children: [
          // Saldo no topo
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
                    // Navega para a tela de cadastro de entrada e aguarda o resultado
                    Navigator.of(context)
                        .push<Map<String, dynamic>>(MaterialPageRoute(
                      builder: (_) => CadastroEntradaPage(),
                    )).then((mov) {
                        if (mov != null) {
                        setState(() {
                          mov_list.addMovimentacao(mov);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Entrada adicionada com sucesso.'),
                        ));
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
                    // Navega para a tela de cadastro de despesa e aguarda o resultado
                    Navigator.of(context)
                        .push<Map<String, dynamic>>(MaterialPageRoute(
                      builder: (_) => CadastroDespesaPage(),
                    )).then((mov) {
                        if (mov != null) {
                        setState(() {
                          mov_list.addMovimentacao(mov);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Despesa adicionada com sucesso.'),
                        ));
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
            child: ListView.builder(
              itemCount: mov_list.movimentacoes.length,
              itemBuilder: (context, index) {
                final mov = mov_list.movimentacoes[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: Icon(
                      mov['tipo'] == 'entrada'
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: corValor(mov['valor']),
                    ),
                    title: Text(mov['nome']),
                    subtitle: Text(
                      '${mov['categoria']} • ${formatarData(mov['data'])}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatarValor(mov['valor']),
                          style: TextStyle(
                            color: corValor(mov['valor']),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 12),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.grey[700]),
                          onPressed: () => editarMovimentacao(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            // pede motivo antes de excluir
                            final motivo = await Navigator.of(context).push<String?>(
                              MaterialPageRoute(builder: (_) => MotivoExclusaoPage()),
                            );
                            if (motivo != null && motivo.trim().isNotEmpty) {
                              setState(() {
                                mov_list.removeMovimentacaoAt(index);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Movimentação removida: $motivo'),
                              ));
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
      ),
    );
  }
}
