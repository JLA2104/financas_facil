import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String nome;
  final String email;
  final String? telefone;
  final String? senha; // Opcional: não recomendado armazenar em texto puro
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  UserModel({
    this.id,
    required this.nome,
    required this.email,
    this.telefone,
    this.senha,
    this.criadoEm,
    this.atualizadoEm,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'senha': senha,
      'criadoEm': criadoEm ?? DateTime.now(),
      'atualizadoEm': atualizadoEm ?? DateTime.now(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      nome: map['nome'] as String? ?? '',
      email: map['email'] as String? ?? '',
      telefone: map['telefone'] as String?,
      senha: map['senha'] as String?,
      criadoEm: (map['criadoEm'] is Timestamp)
          ? (map['criadoEm'] as Timestamp).toDate()
          : (map['criadoEm'] as DateTime?),
      atualizadoEm: (map['atualizadoEm'] is Timestamp)
          ? (map['atualizadoEm'] as Timestamp).toDate()
          : (map['atualizadoEm'] as DateTime?),
    );
  }

  UserModel copyWith({
    String? id,
    String? nome,
    String? email,
    String? telefone,
    String? senha,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return UserModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      senha: senha ?? this.senha,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, nome: $nome, email: $email)';
  }
}
