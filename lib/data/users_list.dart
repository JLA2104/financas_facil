// Lista simples em memória de usuários
final List<Map<String, String>> users = [
  {
    'nome': 'Teste',
    'email': 'teste@teste.com',
    'telefone': '000000000',
    'senha': '123456',
  }
];

Map<String, String>? findByEmail(String email) {
  try {
    return users.firstWhere((u) => u['email']!.toLowerCase() == email.toLowerCase());
  } catch (e) {
    return null;
  }
}

bool validateCredentials(String email, String senha) {
  final u = findByEmail(email);
  if (u == null) return false;
  return u['senha'] == senha;
}

void addUser(Map<String, String> user) {
  users.add(user);
}
