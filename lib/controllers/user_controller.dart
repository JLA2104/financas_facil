import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:financas_facil/models/user.dart';

class UserController {
  static const String _collectionName = 'users';

  // Use getters to obtain instances lazily. If Firebase não estiver inicializado
  // o erro será capturado nas chamadas e repassado com mensagem clara.
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Cria um usuário (documento no Firestore). Retorna o id do documento.
  Future<String> criar(UserModel user) async {
    try {
      final docRef = await _firestore.collection(_collectionName).add(user.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar usuário: $e');
    }
  }

  /// Registra usuário com FirebaseAuth e cria documento no Firestore com uid
  Future<UserModel> registerWithEmailAndPassword({
    required String nome,
    required String email,
    required String senha,
    String? telefone,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: senha);
      final user = cred.user;
      if (user == null) throw Exception('Erro ao criar usuário (sem UID)');

      final userModel = UserModel(
        id: user.uid,
        nome: nome,
        email: email,
        telefone: telefone,
        criadoEm: DateTime.now(),
        atualizadoEm: DateTime.now(),
      );

      await _firestore.collection(_collectionName).doc(user.uid).set(userModel.toMap());
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw Exception('FirebaseAuthException: ${e.code} ${e.message}');
    } catch (e) {
      throw Exception('Erro ao registrar usuário: $e');
    }
  }

  /// Obter usuário por ID
  Future<UserModel?> obterPorId(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao obter usuário: $e');
    }
  }

  /// Obter usuário por email
  Future<UserModel?> obterPorEmail(String email) async {
    try {
      final query = await _firestore
          .collection(_collectionName)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        return UserModel.fromMap(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao obter usuário por email: $e');
    }
  }

  /// Realiza login via FirebaseAuth e retorna UserModel (cria documento se não existir)
  Future<UserModel> signInWithEmailAndPassword(String email, String senha) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: senha);
      final user = cred.user;
      if (user == null) throw Exception('Erro ao efetuar login (sem UID)');

      final docRef = _firestore.collection(_collectionName).doc(user.uid);
      final doc = await docRef.get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      } else {
        // Cria documento básico caso não exista
        final userModel = UserModel(
          id: user.uid,
          nome: user.displayName ?? '',
          email: user.email ?? email,
          criadoEm: DateTime.now(),
          atualizadoEm: DateTime.now(),
        );
        await docRef.set(userModel.toMap());
        return userModel;
      }
    } on FirebaseAuthException catch (e) {
      throw Exception('FirebaseAuthException: ${e.code} ${e.message}');
    } catch (e) {
      throw Exception('Erro ao efetuar login: $e');
    }
  }

  /// Obter todos os usuários (use com cautela)
  Future<List<UserModel>> obterTodos() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      return snapshot.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList();
    } catch (e) {
      throw Exception('Erro ao obter todos os usuários: $e');
    }
  }

  /// Atualizar usuário por ID
  Future<void> atualizar(String id, UserModel user) async {
    try {
      await _firestore.collection(_collectionName).doc(id).update({
        'nome': user.nome,
        'email': user.email,
        'telefone': user.telefone,
        'senha': user.senha,
        'atualizadoEm': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar usuário: $e');
    }
  }

  /// Deletar usuário por ID
  Future<void> deletar(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar usuário: $e');
    }
  }

  /// Deletar vários usuários em batch
  Future<void> deletarMultiplos(List<String> ids) async {
    try {
      final batch = _firestore.batch();
      for (final id in ids) {
        batch.delete(_firestore.collection(_collectionName).doc(id));
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao deletar múltiplos usuários: $e');
    }
  }

  /// Stream de todos os usuários (em tempo real)
  Stream<List<UserModel>> obterStreamTodos() {
    try {
      return _firestore.collection(_collectionName).snapshots().map((snap) {
        return snap.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList();
      });
    } catch (e) {
      throw Exception('Erro ao obter stream de usuários: $e');
    }
  }
  /// Realiza sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Envia e-mail de recuperação usando FirebaseAuth
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception('FirebaseAuthException: ${e.code} ${e.message}');
    } catch (e) {
      throw Exception('Erro ao enviar e-mail de recuperação: $e');
    }
  }

  /// Valida credenciais usando FirebaseAuth (faz sign-in). Retorna true se sucesso.
  Future<bool> validateCredentials(String email, String senha) async {
    try {
      await signInWithEmailAndPassword(email, senha);
      return true;
    } catch (e) {
      return false;
    }
  }
}
