import 'package:cloud_firestore/cloud_firestore.dart';

class Movimentacao {
  final String? id;
  final DateTime data;
  final String nome;
  final String categoria;
  final double valor;
  final String tipo; // 'entrada' ou 'despesa'
  final String? descricao;
  final String? usuarioId;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  Movimentacao({
    this.id,
    required this.data,
    required this.nome,
    required this.categoria,
    required this.valor,
    required this.tipo,
    this.descricao,
    this.usuarioId,
    this.criadoEm,
    this.atualizadoEm,
  });

  // Converter Movimentacao para Map (para enviar ao Firestore)
  Map<String, dynamic> toMap() {
    return {
      'data': data,
      'nome': nome,
      'categoria': categoria,
      'valor': valor,
      'tipo': tipo,
      'descricao': descricao,
      'usuarioId': usuarioId,
      'criadoEm': criadoEm ?? DateTime.now(),
      'atualizadoEm': atualizadoEm ?? DateTime.now(),
    };
  }

  // Converter Map para Movimentacao (quando recebe do Firestore)
  factory Movimentacao.fromMap(Map<String, dynamic> map, String documentId) {
    return Movimentacao(
      id: documentId,
      data: (map['data'] as Timestamp?)?.toDate() ?? DateTime.now(),
      nome: map['nome'] as String? ?? '',
      categoria: map['categoria'] as String? ?? '',
      valor: (map['valor'] as num?)?.toDouble() ?? 0.0,
      tipo: map['tipo'] as String? ?? 'despesa',
      descricao: map['descricao'] as String?,
      usuarioId: map['usuarioId'] as String?,
      criadoEm: (map['criadoEm'] as Timestamp?)?.toDate(),
      atualizadoEm: (map['atualizadoEm'] as Timestamp?)?.toDate(),
    );
  }

  // Criar uma cópia com valores atualizados
  Movimentacao copyWith({
    String? id,
    DateTime? data,
    String? nome,
    String? categoria,
    double? valor,
    String? tipo,
    String? descricao,
    String? usuarioId,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return Movimentacao(
      id: id ?? this.id,
      data: data ?? this.data,
      nome: nome ?? this.nome,
      categoria: categoria ?? this.categoria,
      valor: valor ?? this.valor,
      tipo: tipo ?? this.tipo,
      descricao: descricao ?? this.descricao,
      usuarioId: usuarioId ?? this.usuarioId,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  @override
  String toString() {
    return 'Movimentacao(id: $id, data: $data, nome: $nome, categoria: $categoria, valor: $valor, tipo: $tipo)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Movimentacao &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nome == other.nome &&
          valor == other.valor;

  @override
  int get hashCode => id.hashCode ^ nome.hashCode ^ valor.hashCode;
}
