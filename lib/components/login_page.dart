import 'package:flutter/material.dart';
import 'package:login_signup/components/common/custom_input_field.dart';
import 'package:login_signup/components/common/page_header.dart';
import 'package:login_signup/components/forget_password_page.dart';
import 'package:login_signup/components/signup_page.dart';
import 'package:login_signup/components/verify_code_page.dart';
import 'package:email_validator/email_validator.dart';
import 'package:login_signup/components/common/page_heading.dart';
import 'package:login_signup/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:login_signup/components/common/custom_form_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //
  final _loginFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleGoogleLogin() async {
    final url = Uri.parse('http://localhost:8383/oauth2/authorization/google');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _loginFormKey,
                    child: Column(
                      children: [
                        const PageHeading(
                          title: 'Iniciar sesión',
                        ),
                        CustomInputField(
                            controller: _emailController,
                            labelText: 'Email',
                            hintText: 'Tu correo electrónico',
                            validator: (textValue) {
                              if (textValue == null || textValue.isEmpty) {
                                return 'El email es obligatorio';
                              }
                              if (!EmailValidator.validate(textValue)) {
                                return 'Por favor ingresa un email válido';
                              }
                              return null;
                            }),
                        const SizedBox(
                          height: 16,
                        ),
                        CustomInputField(
                          controller: _passwordController,
                          labelText: 'Contraseña',
                          hintText: 'Tu contraseña',
                          obscureText: true,
                          suffixIcon: true,
                          validator: (textValue) {
                            if (textValue == null || textValue.isEmpty) {
                              return 'La contraseña es obligatoria';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Container(
                          width: size.width * 0.80,
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgetPasswordPage()))
                            },
                            child: const Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(
                                color: Color(0xff939393),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : CustomFormButton(
                                innerText: 'Iniciar sesión',
                                onPressed: _handleLoginUser,
                              ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                                child: Divider(color: Colors.grey.shade300)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('o',
                                  style: TextStyle(color: Color(0xff939393))),
                            ),
                            Expanded(
                                child: Divider(color: Colors.grey.shade300)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: size.width * 0.8,
                          child: OutlinedButton.icon(
                            onPressed: _handleGoogleLogin,
                            icon: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Center(
                                child: Text('G', style: TextStyle(
                                  color: Color(0xff4285F4),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                )),
                              ),
                            ),
                            label: const Text(
                              'Continuar con Google',
                              style: TextStyle(
                                color: Color(0xff333333),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Color(0xffDDDDDD)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 18,
                        ),
                        SizedBox(
                          width: size.width * 0.8,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '¿No tienes cuenta? ',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xff939393),
                                    fontWeight: FontWeight.bold),
                              ),
                              GestureDetector(
                                onTap: () => {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SignupPage()))
                                },
                                child: const Text(
                                  'Regístrate',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Color(0xff748288),
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLoginUser() async {
    // Validate form
    if (!_loginFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Call login service
    final result = await AuthService.loginUser(
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (result['success']) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Credenciales verificadas'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to verification code page
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyCodePage(
                email: _emailController.text,
                purpose: 'LOGIN',
              ),
            ),
          );
        }
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Error en el login'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
