import 'package:flutter/material.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Controladores para los campos de texto
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  // Variables de estado
  int _step = 0; // 0 = email, 1 = código, 2 = nueva contraseña, 3 = éxito
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;
  String _email = '';
  String _restartCode = '';

  // Método para enviar el código de recuperación
  Future<void> _sendRecoveryCode() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showError("Por favor, ingresa un correo válido");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.postWithoutAuth(
        endpoint: '/api/v1/authentication/forgot-password',
        body: {'email': email},
      );

      if (response != null) {
        setState(() {
          _email = email;
          _step = 1; // Avanzar al paso de validación de código
        });
      }
    } catch (e) {
      _showError("Error: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Método para validar el código
  Future<void> _validateCode() async {
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      _showError("Por favor, ingresa el código");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.postWithoutAuth(
        endpoint: '/api/v1/authentication/forgot-password/validate',
        body: {'restartCode': code},
      );

      if (response != null) {
        setState(() {
          _restartCode = code;
          _step = 2; // Avanzar al paso de nueva contraseña
        });
      }
    } catch (e) {
      _showError("Error: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Método para cambiar la contraseña
  Future<void> _resetPassword() async {
    final password = _passwordController.text.trim();
    final repeatPassword = _repeatPasswordController.text.trim();

    if (password.isEmpty || repeatPassword.isEmpty) {
      _showError("Por favor, completa ambos campos");
      return;
    }

    if (password != repeatPassword) {
      _showError("Las contraseñas no coinciden");
      return;
    }

    if (password.length < 6) {
      _showError("La contraseña debe tener al menos 6 caracteres");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.postWithoutAuth(
        endpoint: '/api/v1/authentication/forgot-password/change-password',
        body: {
          'password': password,
          'repeatedPassword': repeatPassword,
          'restartCode': _restartCode,
        },
      );

      if (response != null) {
        setState(() => _step = 3); // Mostrar pantalla de éxito
      }
    } catch (e) {
      _showError("Error: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Método para mostrar errores
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Método para retroceder en el flujo
  void _goBack() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.pop(context);
    }
  }

  // Método para reenviar el código
  Future<void> _resendCode() async {
    setState(() => _isLoading = true);
    try {
      await ApiService.postWithoutAuth(
        endpoint: '/api/v1/authentication/forgot-password',
        body: {'email': _email},
      );
      _showError("Código reenviado con éxito");
    } catch (e) {
      _showError("Error al reenviar el código: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: _buildCurrentStep(),
        ),
      ),
    );
  }

  // Devuelve el título según el paso actual
  String _getAppBarTitle() {
    switch (_step) {
      case 0: return 'Recuperar contraseña';
      case 1: return 'Validar código';
      case 2: return 'Nueva contraseña';
      case 3: return 'Contraseña cambiada';
      default: return '';
    }
  }

  // Construye el contenido según el paso actual
  Widget _buildCurrentStep() {
    switch (_step) {
      case 0: return _buildEmailStep();
      case 1: return _buildCodeStep();
      case 2: return _buildPasswordStep();
      case 3: return _buildSuccessStep();
      default: return Container();
    }
  }

  // Paso 1: Ingreso de email
  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        const Text(
          'Ingresa tu correo electrónico para recibir un código de recuperación',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 60),
        CustomTextField(
          label: "Correo electrónico",
          hintText: "ejemplo@dominio.com",
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_outlined),
        ),
        const SizedBox(height: 40),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          CustomButton(
            text: "Enviar código",
            onPressed: _sendRecoveryCode,
          ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Volver al inicio de sesión"),
        ),
      ],
    );
  }

  // Paso 2: Validación de código
  Widget _buildCodeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        Text(
          'Se ha enviado un código a $_email. Por favor revisa tu correo e ingresa el código aquí',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 60),
        CustomTextField(
          label: "Código de verificación",
          hintText: "123456",
          controller: _codeController,
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Icons.lock_outline),
        ),
        const SizedBox(height: 40),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          CustomButton(
            text: "Validar código",
            onPressed: _validateCode,
          ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: _resendCode,
          child: const Text("Reenviar código"),
        ),
      ],
    );
  }

  // Paso 3: Nueva contraseña
  Widget _buildPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        const Text(
          'Crea una nueva contraseña para tu cuenta',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 60),
        CustomTextField(
          label: "Nueva contraseña",
          hintText: "Mínimo 6 caracteres",
          controller: _passwordController,
          obscureText: _obscurePassword,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
          ),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: "Repetir contraseña",
          hintText: "Repite tu contraseña",
          controller: _repeatPasswordController,
          obscureText: _obscureRepeatPassword,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureRepeatPassword ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() => _obscureRepeatPassword = !_obscureRepeatPassword);
            },
          ),
        ),
        const SizedBox(height: 40),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          CustomButton(
            text: "Cambiar contraseña",
            onPressed: _resetPassword,
          ),
      ],
    );
  }

  // Paso 4: Éxito
  Widget _buildSuccessStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 100),
        const SizedBox(height: 30),
        const Text(
          '¡Contraseña cambiada con éxito!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const Text(
          'Ahora puedes iniciar sesión con tu nueva contraseña',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: 'Volver al inicio de sesión',
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }
}