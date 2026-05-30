import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:login_signup/components/common/custom_form_button.dart';
import 'package:login_signup/components/common/page_header.dart';
import 'package:login_signup/components/common/page_heading.dart';
import 'package:login_signup/components/login_page.dart';
import 'package:login_signup/components/common/custom_input_field.dart';
import 'package:login_signup/services/password_recovery_service.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final _forgetPasswordFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _codeSent = false; // controla qué paso mostrar

  @override
  void dispose() {
    _emailController.dispose();
    _codigoController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Paso 1: enviar código al correo
  void _handleSendCode() async {
    if (!_forgetPasswordFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await PasswordRecoveryService.sendRecoveryCode(
      email: _emailController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      setState(() => _codeSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código enviado a tu correo'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Error al enviar el código'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Paso 2: restablecer contraseña con código
  void _handleResetPassword() async {
    if (!_resetFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await PasswordRecoveryService.resetPassword(
      email: _emailController.text,
      codigo: _codigoController.text,
      newPassword: _newPasswordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contraseña restablecida exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Error al restablecer la contraseña'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es obligatoria';
    if (value.length < 8) return 'Mínimo 8 caracteres';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Debe tener al menos una mayúscula';
    if (!value.contains(RegExp(r'[a-z]'))) return 'Debe tener al menos una minúscula';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Debe tener al menos un número';
    if (!value.contains(RegExp(r'[@$!%*?&]'))) return 'Debe tener al menos un carácter especial';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffEEF1F3),
        body: Column(
          children: [
            const PageHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const PageHeading(title: 'Recuperar contraseña'),

                      // PASO 1: ingresar email
                      if (!_codeSent) Form(
                        key: _forgetPasswordFormKey,
                        child: Column(
                          children: [
                            CustomInputField(
                              controller: _emailController,
                              labelText: 'Correo electrónico',
                              hintText: 'Tu correo electrónico',
                              isDense: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'El correo es obligatorio';
                                if (!EmailValidator.validate(value)) return 'Ingresa un correo válido';
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            _isLoading
                                ? const CircularProgressIndicator()
                                : CustomFormButton(
                              innerText: 'Enviar código',
                              onPressed: _handleSendCode,
                            ),
                          ],
                        ),
                      ),

                      // PASO 2: ingresar código y nueva contraseña
                      if (_codeSent) Form(
                        key: _resetFormKey,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              child: Text(
                                'Ingresa el código enviado a ${_emailController.text}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Color(0xff939393)),
                              ),
                            ),
                            CustomInputField(
                              controller: _codigoController,
                              labelText: 'Código de verificación',
                              hintText: 'Código de 6 dígitos',
                              isDense: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'El código es obligatorio';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomInputField(
                              controller: _newPasswordController,
                              labelText: 'Nueva contraseña',
                              hintText: 'Tu nueva contraseña',
                              isDense: true,
                              obscureText: true,
                              suffixIcon: true,
                              validator: _validatePassword,
                            ),
                            const SizedBox(height: 16),
                            CustomInputField(
                              controller: _confirmPasswordController,
                              labelText: 'Confirmar contraseña',
                              hintText: 'Repite tu nueva contraseña',
                              isDense: true,
                              obscureText: true,
                              suffixIcon: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Confirma tu contraseña';
                                if (value != _newPasswordController.text) return 'Las contraseñas no coinciden';
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            _isLoading
                                ? const CircularProgressIndicator()
                                : CustomFormButton(
                              innerText: 'Restablecer contraseña',
                              onPressed: _handleResetPassword,
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => setState(() => _codeSent = false),
                              child: const Text('¿No recibiste el código? Reenviar'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        ),
                        child: const Text(
                          'Volver al inicio de sesión',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xff939393),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}