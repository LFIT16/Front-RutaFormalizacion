import 'package:flutter/material.dart';
import 'package:login_signup/components/common/custom_form_button.dart';
import 'package:login_signup/components/common/custom_input_field.dart';
import 'package:login_signup/components/common/page_heading.dart';
import 'package:login_signup/components/common/page_header.dart';
import 'package:login_signup/services/auth_service.dart';
import 'package:login_signup/services/token_service.dart';

class VerifyCodePage extends StatefulWidget {
  final String email;
  final String purpose; // "REGISTRO" o "LOGIN"

  const VerifyCodePage({
    Key? key,
    required this.email,
    required this.purpose,
  }) : super(key: key);

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  final TextEditingController _codeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int _remainingAttempts = 3;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _handleVerifyCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.verifyCode(
      email: widget.email,
      codigo: _codeController.text,
      purpose: widget.purpose,
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (result['success']) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Código verificado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Navegar según el propósito
        if (widget.purpose == "REGISTRO") {
          // Redirigir a login
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        } else if (widget.purpose == "LOGIN") {
          // Guardar el token
          String? token = result['token'];
          if (token != null) {
            await TokenService.saveToken(token);
            await TokenService.saveUserInfo(email: widget.email, name: widget.email);
          }
          // Redirigir a home
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
          }
        }
      } else {
        // Mostrar error
        setState(() {
          _remainingAttempts = result['intentosRestantes'] ?? 3;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Error al verificar el código'),
            backgroundColor: Colors.red,
          ),
        );

        // Si se agotaron los intentos
        if (_remainingAttempts <= 0) {
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.pop(context);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffEEF1F3),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const PageHeader(),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const PageHeading(title: 'Verificar Código'),
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              'Se envió un código de verificación a:',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.email,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Ingresa el código de verificación:',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                      CustomInputField(
                        controller: _codeController,
                        labelText: 'Código de Verificación',
                        hintText: 'Ingresa el código',
                        isDense: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El código es obligatorio';
                          }
                          if (value.length < 6) {
                            return 'El código debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            if (_remainingAttempts > 0)
                              Text(
                                'Intentos restantes: $_remainingAttempts',
                                style: const TextStyle(
                                  color: Color(0xff939393),
                                  fontSize: 12,
                                ),
                              ),
                            if (_remainingAttempts <= 0)
                              const Text(
                                'Se agotaron los intentos. Por favor, intenta de nuevo más tarde.',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : CustomFormButton(
                              innerText: 'Verificar',
                              onPressed: _handleVerifyCode,
                            ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
