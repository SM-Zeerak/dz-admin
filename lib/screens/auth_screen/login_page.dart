import 'package:dz_admin_panel/widgets/Buttons/custom_button.dart';
import 'package:dz_admin_panel/widgets/Text/customText.dart';
import 'package:dz_admin_panel/widgets/TextField/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    FocusScope.of(context).unfocus(); // hide keyboard
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        context.go('/dashboard');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 1024;
    final bool isDesktop = width >= 1024;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      body: Row(
        children: [
          if (!isMobile)
            Expanded(
              flex: isDesktop ? 2 : 1,
              child: Container(
                color: Colors.blueGrey.shade100,
                child: const Center(
                  child: Text(
                    'Image Container\n(put your image here)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, color: Colors.black45),
                  ),
                ),
              ),
            ),
          Expanded(
            flex: isDesktop ? 1 : 2,
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  width:
                      isMobile
                          ? double.infinity
                          : isTablet
                          ? width * 0.6
                          : width * 0.4,
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    color: const Color.fromARGB(207, 28, 28, 39),
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CustomText(
                            text: 'Admin Login',
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(height: 20),

                          /// Email Field
                          CustomTextField(
                            controller: _emailController,
                            hintText: 'Type your email..',
                            focusNode: _emailFocusNode,
                            keyboardType: TextInputType.emailAddress,
                            onChanged:
                                (_) => setState(() => _errorMessage = null),
                            ontap: () => setState(() => _errorMessage = null),
                            // On enter, move to password field
                            onSubmitted: (_) {
                              FocusScope.of(
                                context,
                              ).requestFocus(_passwordFocusNode);
                            },
                          ),

                          const SizedBox(height: 16),

                          /// Password Field
                          CustomTextField(
                            controller: _passwordController,
                            hintText: 'Type your pass..',
                            isPassword: true,
                            focusNode: _passwordFocusNode,
                            onChanged:
                                (_) => setState(() => _errorMessage = null),
                            onSubmitted: (_) => _login(), // Hit login on Enter
                          ),

                          const SizedBox(height: 16),
                          if (_errorMessage != null)
                            Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          const SizedBox(height: 24),
                          _isLoading
                              ? const CircularProgressIndicator()
                              : CustomButton(text: 'Login', onPressed: _login),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
