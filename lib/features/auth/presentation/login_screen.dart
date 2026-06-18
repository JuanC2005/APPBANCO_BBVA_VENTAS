import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import 'login_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) return;
    ref.read(authViewModelProvider.notifier).login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go('/cartera');
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/bbva_logo.png', height: 100),
                const SizedBox(height: 16),
                Text(AppStrings.appTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: BBVAColors.primaryBlue,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(AppStrings.appSubtitle,
                    style: TextStyle(color: BBVAColors.mediumGray)),
                const SizedBox(height: 48),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon:
                        const Icon(Icons.email_outlined, color: BBVAColors.primaryBlue),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: AppStrings.password,
                    prefixIcon:
                        const Icon(Icons.lock_outline, color: BBVAColors.primaryBlue),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onSubmitted: (_) => _handleLogin(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authState.status == AuthStatus.loading
                        ? null
                        : _handleLogin,
                    child: authState.status == AuthStatus.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(AppStrings.ingresar),
                  ),
                ),
                if (authState.error != null) ...[
                  const SizedBox(height: 16),
                  Text(authState.error!,
                      style: const TextStyle(color: BBVAColors.errorRed)),
                ],
                if (authState.estaBloqueado) ...[
                  const SizedBox(height: 16),
                  Text('${AppStrings.bloqueoLogin} (${authState.intentosFallidos}/5)',
                      style: const TextStyle(color: BBVAColors.errorRed)),
                ],
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => context.push('/register'),
                  child: Text(AppStrings.crearCuenta,
                      style: const TextStyle(color: BBVAColors.accentBlue)),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(AppStrings.problemasIngreso,
                      style: const TextStyle(color: BBVAColors.accentBlue)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
