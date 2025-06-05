class AuthService {
  // Simula una base de datos de usuarios
  static final Map<String, String> _mockUsers = {
    "example@gmail.com": "12345678",
    "profesor@colegio.edu": "claveSegura",
  };

  /// Simula el inicio de sesión.
  /// Devuelve `true` si las credenciales coinciden, `false` si no.
  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // Simula espera de red
    return _mockUsers[email] == password;
  }

/// Puedes agregar un método de registro simulado luego
}
