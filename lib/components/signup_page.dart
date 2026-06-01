import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_signup/components/common/page_header.dart';
import 'package:login_signup/components/common/page_heading.dart';
import 'package:login_signup/components/login_page.dart';
import 'package:login_signup/components/verify_code_page.dart';
import 'package:login_signup/services/auth_service.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:login_signup/components/common/custom_form_button.dart';
import 'package:login_signup/components/common/custom_input_field.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  File? _profileImage;

  final _signupFormKey = GlobalKey<FormState>();

  // Controllers para obtener los valores
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  Future _pickProfileImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageTemporary = File(image.path);
      setState(() => _profileImage = imageTemporary);
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image error: $e');
    }
  }

  // Validador de contraseña
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    // Verificar mayúscula
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'La contraseña debe tener al menos una mayúscula';
    }
    // Verificar minúscula
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'La contraseña debe tener al menos una minúscula';
    }
    // Verificar número
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'La contraseña debe tener al menos un número';
    }
    // Verificar carácter especial
    if (!value.contains(RegExp(r'[@$!%*?&]'))) {
      return 'La contraseña debe tener al menos un carácter especial (@, \$, !, %, *, ?, &)';
    }
    return null;
  }

  // Validador de teléfono
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'El teléfono es obligatorio';
    }
    if (!RegExp(r'^[+]?[0-9]{7,15}$').hasMatch(value)) {
      return 'El teléfono debe tener entre 7 y 15 dígitos';
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffEEF1F3),
        body: SingleChildScrollView(
          child: Form(
            key: _signupFormKey,
            child: Column(
              children: [
                const PageHeader(),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      const PageHeading(
                        title: 'Registrarse',
                      ),
                      SizedBox(
                        width: 130,
                        height: 130,
                        child: CircleAvatar(
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                          child: Stack(
                            children: [
                              Positioned(
                                bottom: 5,
                                right: 5,
                                child: GestureDetector(
                                  onTap: _pickProfileImage,
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade400,
                                      border: Border.all(
                                          color: Colors.white, width: 3),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_sharp,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      CustomInputField(
                          controller: _nameController,
                          labelText: 'Nombre',
                          hintText: 'Tu nombre',
                          isDense: true,
                          validator: (textValue) {
                            if (textValue == null || textValue.isEmpty) {
                              return 'El nombre es obligatorio';
                            }
                            if (textValue.length < 2) {
                              return 'El nombre debe tener al menos 2 caracteres';
                            }
                            return null;
                          }),
                      const SizedBox(
                        height: 16,
                      ),
                      CustomInputField(
                          controller: _lastNameController,
                          labelText: 'Apellido',
                          hintText: 'Tu apellido',
                          isDense: true,
                          validator: (textValue) {
                            if (textValue == null || textValue.isEmpty) {
                              return 'El apellido es obligatorio';
                            }
                            if (textValue.length < 2) {
                              return 'El apellido debe tener al menos 2 caracteres';
                            }
                            return null;
                          }),
                      const SizedBox(
                        height: 16,
                      ),
                      CustomInputField(
                          controller: _emailController,
                          labelText: 'Email',
                          hintText: 'Tu correo electrónico',
                          isDense: true,
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
                        controller: _phoneController,
                        labelText: 'Teléfono',
                        hintText: 'Tu número de teléfono',
                        isDense: true,
                        validator: _validatePhone,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      CustomInputField(
                          controller: _addressController,
                          labelText: 'Dirección (Opcional)',
                          hintText: 'Tu dirección',
                          isDense: true,
                          validator: (textValue) {
                            if (textValue != null && textValue.length > 200) {
                              return 'La dirección no puede superar 200 caracteres';
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
                        isDense: true,
                        obscureText: true,
                        validator: _validatePassword,
                        suffixIcon: true,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      CustomInputField(
                        controller: _confirmPasswordController,
                        labelText: 'Confirmar Contraseña',
                        hintText: 'Confirma tu contraseña',
                        isDense: true,
                        obscureText: true,
                        validator: (textValue) {
                          if (textValue == null || textValue.isEmpty) {
                            return 'Debes confirmar tu contraseña';
                          }
                          if (textValue != _passwordController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                        suffixIcon: true,
                      ),
                      const SizedBox(
                        height: 22,
                      ),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : CustomFormButton(
                              innerText: 'Registrarse',
                              onPressed: _handleSignupUser,
                            ),
                      const SizedBox(
                        height: 18,
                      ),
                      SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              '¿Ya tienes cuenta? ',
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
                                            const LoginPage()))
                              },
                              child: const Text(
                                'Inicia sesión',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xff748288),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('o',
                                style: TextStyle(color: Color(0xff939393))),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: OutlinedButton.icon(
                          onPressed: _handleGoogleSignup,
                          icon: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Center(
                              child: Text('G',
                                  style: TextStyle(
                                    color: Color(0xff4285F4),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  )),
                            ),
                          ),
                          label: const Text(
                            'Registrarse con Google',
                            style: TextStyle(
                                color: Color(0xff333333),
                                fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Color(0xffDDDDDD)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSignupUser() async {
    // Validate form
    if (!_signupFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Call registration service
    final result = await AuthService.registerUser(
      name: _nameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      address: _addressController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (result['success']) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(result['message'] ?? 'Usuario registrado exitosamente'),
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
                purpose: 'REGISTRO',
              ),
            ),
          );
        }
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Error en el registro'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleGoogleSignup() {
    // Redirige la MISMA pestaña al backend de Google OAuth2.
    html.window.location.href = 'http://localhost:8383/oauth2/authorization/google';
  }
}