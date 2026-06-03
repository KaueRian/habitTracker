import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/leve_theme.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _acceptedTerms = false;

  Future<void> _openUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _submit() {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Você precisa aceitar os Termos de Uso e Política de Privacidade para continuar.'),
          backgroundColor: LeveTheme.primary,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final notifier = ref.read(authProvider.notifier);
      if (_isSignUp) {
        notifier.signUpWithEmail(_emailController.text.trim(), _passwordController.text.trim());
      } else {
        notifier.signInWithEmail(_emailController.text.trim(), _passwordController.text.trim());
      }
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
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // App Logo / Typography Header
              Center(
                child: Column(
                  children: [
                    Text(
                      'leve.',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 64,
                            color: LeveTheme.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hábitos & Diário',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 2.0,
                        color: LeveTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),

              // Sign-in Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.inter(color: LeveTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        labelStyle: GoogleFonts.inter(color: LeveTheme.textSecondary),
                        filled: true,
                        fillColor: LeveTheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty || !value.contains('@')) {
                          return 'Por favor, insira um e-mail válido.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: GoogleFonts.inter(color: LeveTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        labelStyle: GoogleFonts.inter(color: LeveTheme.textSecondary),
                        filled: true,
                        fillColor: LeveTheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'A senha deve ter pelo menos 6 caracteres.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              if (authState.errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  authState.errorMessage!,
                  style: GoogleFonts.inter(color: LeveTheme.primary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 24),

              // Consent Checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _acceptedTerms,
                    activeColor: LeveTheme.primary,
                    onChanged: (val) {
                      setState(() {
                        _acceptedTerms = val ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Wrap(
                        children: [
                          Text('Li e aceito os ', style: GoogleFonts.inter(fontSize: 12, color: LeveTheme.textSecondary)),
                          GestureDetector(
                            onTap: () => _openUrl('https://leve-app.web.app/terms.html'),
                            child: Text(
                              'Termos de Uso',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: LeveTheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          Text(' e a ', style: GoogleFonts.inter(fontSize: 12, color: LeveTheme.textSecondary)),
                          GestureDetector(
                            onTap: () => _openUrl('https://leve-app.web.app/privacy.html'),
                            child: Text(
                              'Política de Privacidade',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: LeveTheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: authState.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: LeveTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        _isSignUp ? 'Criar Conta' : 'Entrar',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
              ),

              const SizedBox(height: 16),

              // Toggle Sign Up / Log In
              TextButton(
                onPressed: () {
                  setState(() {
                    _isSignUp = !_isSignUp;
                  });
                },
                child: Text(
                  _isSignUp ? 'Já tem uma conta? Entrar' : 'Não tem conta? Cadastrar-se',
                  style: GoogleFonts.inter(color: LeveTheme.textSecondary),
                ),
              ),

              const Divider(height: 40, color: Color(0xFFE2DDD7)),

              // Guest Mode Button
              OutlinedButton(
                onPressed: authState.isLoading
                    ? null
                    : () {
                        if (!_acceptedTerms) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Você precisa aceitar os Termos de Uso e Política de Privacidade.'),
                              backgroundColor: LeveTheme.primary,
                            ),
                          );
                          return;
                        }
                        ref.read(authProvider.notifier).signInAnonymously();
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: LeveTheme.textPrimary,
                  side: const BorderSide(color: Color(0xFFC4785B), width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Entrar como Visitante',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
