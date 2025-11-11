import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../controllers/movimentacao_controller.dart';
import '../models/movimentacao.dart';
import 'cadastro_despesa.dart';
import 'cadastro_entrada.dart';
import 'motivo_exclusao.dart';

// Enum para opções de ordenação
enum OrdenacaoOpcoes { data, valor, alfabetica }

class BuscaMovimentacoesPage extends StatefulWidget {
  @override
  _BuscaMovimentacoesPageState createState() => _BuscaMovimentacoesPageState();
}

class _BuscaMovimentacoesPageState extends State<BuscaMovimentacoesPage> {
  final corPrincipal = Colors.blue[800];
  final MovimentacaoController _controller = MovimentacaoController();
  final TextEditingController _searchController = TextEditingController();
  
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  
  OrdenacaoOpcoes _ordenacao = OrdenacaoOpcoes.data;

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
  }

  Future<void> _initializeDateFormatting() async {
    try {
      await initializeDateFormatting('pt_BR');
    } catch (e) {
      // A inicialização pode falhar em alguns casos, mas continuamos
      print('Erro ao inicializar formatação de data: $e');
    }
  }

  String formatarData(DateTime data) {
    final DateFormat formatador = DateFormat('dd/MM/yyyy', 'pt_BR');
    return formatador.format(data);
  }

  String formatarValor(double valor) {
    final NumberFormat formatador = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$ ',
      decimalDigits: 2,
    );
    String valorFormatado = formatador.format(valor.abs());
    return (valor < 0 ? '- ' : '') + valorFormatado;
  }

  Color corValor(double valor) {
    return valor >= 0 ? Colors.green : Colors.red;
  }

  // Filtra as movimentações baseado no termo de busca (case insensitive)
  List<Movimentacao> _filtrarMovimentacoes(List<Movimentacao> movimentacoes) {
    final termo = _searchController.text.toLowerCase().trim();
    
    if (termo.isEmpty) {
      return movimentacoes;
    }

    return movimentacoes.where((mov) {
      return mov.nome.toLowerCase().contains(termo) ||
             mov.categoria.toLowerCase().contains(termo);
    }).toList();
  }

  // Ordena as movimentações
  List<Movimentacao> _ordenarMovimentacoes(List<Movimentacao> movimentacoes) {
    List<Movimentacao> resultado = List.from(movimentacoes);

    switch (_ordenacao) {
      case OrdenacaoOpcoes.data:
        resultado.sort((a, b) => b.data.compareTo(a.data)); // Mais recentes primeiro
        break;
      case OrdenacaoOpcoes.valor:
        resultado.sort((a, b) => b.valor.abs().compareTo(a.valor.abs())); // Maiores valores primeiro
        break;
      case OrdenacaoOpcoes.alfabetica:
        resultado.sort((a, b) => a.nome.compareTo(b.nome)); // A-Z
        break;
    }

    return resultado;
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: corPrincipal,
        title: Text('Buscar Movimentações', style: TextStyle(color: Colors.white)),
      ),
      body: _uid == null
          ? Center(child: Text('Usuário não autenticado'))
          : StreamBuilder<List<Movimentacao>>(
              stream: _controller.obterStreamDoUsuario(_uid!),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final movimentacoes = snapshot.data!;
                final movimentacoesFiltradas = _filtrarMovimentacoes(movimentacoes);
                final movimentacoesOrdenadas = _ordenarMovimentacoes(movimentacoesFiltradas);

                return Column(
                  children: [
                    // Campo de busca
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar por nome ou categoria...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),

                    // Opções de ordenação
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ordenar por:',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                FilterChip(
                                  label: Text('Data'),
                                  selected: _ordenacao == OrdenacaoOpcoes.data,
                                  onSelected: (selected) {
                                    setState(() {
                                      _ordenacao = OrdenacaoOpcoes.data;
                                    });
                                  },
                                ),
                                SizedBox(width: 8),
                                FilterChip(
                                  label: Text('Valor'),
                                  selected: _ordenacao == OrdenacaoOpcoes.valor,
                                  onSelected: (selected) {
                                    setState(() {
                                      _ordenacao = OrdenacaoOpcoes.valor;
                                    });
                                  },
                                ),
                                SizedBox(width: 8),
                                FilterChip(
                                  label: Text('Alfabética'),
                                  selected: _ordenacao == OrdenacaoOpcoes.alfabetica,
                                  onSelected: (selected) {
                                    setState(() {
                                      _ordenacao = OrdenacaoOpcoes.alfabetica;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    // Lista de resultados
                    Expanded(
                      child: movimentacoesOrdenadas.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search, color: Colors.grey, size: 48),
                                  SizedBox(height: 16),
                                  Text(
                                    _searchController.text.isEmpty
                                        ? 'Nenhuma movimentação cadastrada'
                                        : 'Nenhuma movimentação encontrada',
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: movimentacoesOrdenadas.length,
                              itemBuilder: (context, index) {
                                final mov = movimentacoesOrdenadas[index];
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
