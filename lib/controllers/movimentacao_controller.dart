import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financas_facil/models/movimentacao.dart';

class MovimentacaoController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'movimentacoes';

  /// Criar uma nova movimentação
  Future<String> criar(Movimentacao movimentacao) async {
    try {
      final docRef = await _firestore
          .collection(_collectionName)
          .add(movimentacao.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar movimentação: $e');
    }
  }

  /// Obter uma movimentação pelo ID
  Future<Movimentacao?> obterPorId(String id) async {
    try {
      final doc =
          await _firestore.collection(_collectionName).doc(id).get();
      if (doc.exists) {
        return Movimentacao.fromMap(doc.data() as Map<String, dynamic>, id);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao obter movimentação: $e');
    }
  }

  /// Obter todas as movimentações do usuário
  Future<List<Movimentacao>> obterTodasDoUsuario(String usuarioId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('usuarioId', isEqualTo: usuarioId)
          .orderBy('data', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Movimentacao.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erro ao obter movimentações: $e');
    }
  }

  /// Obter movimentações com filtros (data, categoria, tipo)
  Future<List<Movimentacao>> obterComFiltros({
    required String usuarioId,
    DateTime? dataInicio,
    DateTime? dataFim,
    String? categoria,
    String? tipo,
  }) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .where('usuarioId', isEqualTo: usuarioId);

      if (categoria != null && categoria.isNotEmpty) {
        query = query.where('categoria', isEqualTo: categoria);
      }

      if (tipo != null && tipo.isNotEmpty) {
        query = query.where('tipo', isEqualTo: tipo);
      }

      if (dataInicio != null) {
        query = query.where('data', isGreaterThanOrEqualTo: dataInicio);
      }

      if (dataFim != null) {
        query = query.where('data', isLessThanOrEqualTo: dataFim);
      }

      final querySnapshot =
          await (query as Query<Map<String, dynamic>>).orderBy('data', descending: true).get();

      return querySnapshot.docs
          .map((doc) => Movimentacao.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erro ao obter movimentações com filtros: $e');
    }
  }

  /// Atualizar uma movimentação
  Future<void> atualizar(String id, Movimentacao movimentacao) async {
    try {
      await _firestore.collection(_collectionName).doc(id).update({
        'data': movimentacao.data,
        'nome': movimentacao.nome,
        'categoria': movimentacao.categoria,
        'valor': movimentacao.valor,
        'tipo': movimentacao.tipo,
        'descricao': movimentacao.descricao,
        'usuarioId': movimentacao.usuarioId,
        'atualizadoEm': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar movimentação: $e');
    }
  }

  /// Deletar uma movimentação
  Future<void> deletar(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar movimentação: $e');
    }
  }

  /// Deletar múltiplas movimentações
  Future<void> deletarMultiplas(List<String> ids) async {
    try {
      final batch = _firestore.batch();
      for (final id in ids) {
        batch.delete(_firestore.collection(_collectionName).doc(id));
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao deletar movimentações: $e');
    }
  }

  /// Obter stream de movimentações em tempo real do usuário
  Stream<List<Movimentacao>> obterStreamDoUsuario(String usuarioId) {
    try {
      return _firestore
          .collection(_collectionName)
          .where('usuarioId', isEqualTo: usuarioId)
          .orderBy('data', descending: true)
          .snapshots()
          .map((querySnapshot) {
        return querySnapshot.docs
            .map((doc) => Movimentacao.fromMap(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      throw Exception('Erro ao obter stream de movimentações: $e');
    }
  }

  /// Obter stream com filtros em tempo real
  Stream<List<Movimentacao>> obterStreamComFiltros({
    required String usuarioId,
    String? categoria,
    String? tipo,
  }) {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .where('usuarioId', isEqualTo: usuarioId);

      if (categoria != null && categoria.isNotEmpty) {
        query = query.where('categoria', isEqualTo: categoria);
      }

      if (tipo != null && tipo.isNotEmpty) {
        query = query.where('tipo', isEqualTo: tipo);
      }

      return (query as Query<Map<String, dynamic>>)
          .orderBy('data', descending: true)
          .snapshots()
          .map((querySnapshot) {
        return querySnapshot.docs
            .map((doc) => Movimentacao.fromMap(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      throw Exception('Erro ao obter stream com filtros: $e');
    }
  }

  /// Obter estatísticas de movimentações do usuário
  Future<Map<String, dynamic>> obterEstatisticas(String usuarioId) async {
    try {
      final movimentacoes = await obterTodasDoUsuario(usuarioId);

      double totalEntradas = 0;
      double totalDespesas = 0;

      for (final mov in movimentacoes) {
        if (mov.tipo == 'entrada') {
          totalEntradas += mov.valor;
        } else if (mov.tipo == 'despesa') {
          totalDespesas += mov.valor.abs();
        }
      }

      final saldo = totalEntradas - totalDespesas;

      return {
        'totalEntradas': totalEntradas,
        'totalDespesas': totalDespesas,
        'saldo': saldo,
        'totalMovimentacoes': movimentacoes.length,
      };
    } catch (e) {
      throw Exception('Erro ao obter estatísticas: $e');
    }
  }

  /// Obter movimentações do mês atual
  Future<List<Movimentacao>> obterMovimentacoesMesAtual(
      String usuarioId) async {
    try {
      final agora = DateTime.now();
      final primeiroDiaMes = DateTime(agora.year, agora.month, 1);
      final ultimoDiaMes = DateTime(agora.year, agora.month + 1, 0);

      return obterComFiltros(
        usuarioId: usuarioId,
        dataInicio: primeiroDiaMes,
        dataFim: ultimoDiaMes,
      );
    } catch (e) {
      throw Exception('Erro ao obter movimentações do mês: $e');
    }
  }

  /// Limpar todos os dados de movimentações do usuário (cuidado!)
  Future<void> limparDadosDoUsuario(String usuarioId) async {
    try {
      final movimentacoes = await obterTodasDoUsuario(usuarioId);
      final ids = movimentacoes.map((m) => m.id!).toList();
      if (ids.isNotEmpty) {
        await deletarMultiplas(ids);
      }
    } catch (e) {
      throw Exception('Erro ao limpar dados do usuário: $e');
    }
  }
}
