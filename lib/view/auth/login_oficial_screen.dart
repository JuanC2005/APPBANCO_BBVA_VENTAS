import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodel/auth_oficial_viewmodel.dart';
import '../../ui/theme/colors.dart';
import '../../ui/theme/typography.dart';

class LoginOficialScreen extends StatelessWidget {
  const LoginOficialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthOficialViewModel>(context);
    final TextEditingController codeController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: BBVAColors.white, // ✅ FONDO BLANCO
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Image.asset('assets/images/bbva_logo.png', height: 120),
              const SizedBox(height: 20),
              Text(
                'BBVA',
                style: BBVATypography.titleLarge.copyWith(
                  color: BBVAColors.primaryBlue, // Azul BBVA para el título
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Portal Oficial de Crédito',
                style: BBVATypography.bodyLarge.copyWith(
                  color: BBVAColors.primaryBlue, // Azul BBVA para el subtítulo
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: codeController,
                style: BBVATypography.bodyLarge, // ✅ Texto negro
                decoration: InputDecoration(
                  labelText: 'Código de Empleado',
                  labelStyle: BBVATypography.bodySmall, // ✅ Label negro
                  fillColor: BBVAColors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: BBVAColors.primaryBlue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: BBVAColors.primaryBlue,
                      width: 2,
                    ),
                  ),
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: BBVATypography.bodyLarge, // ✅ Texto negro
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: BBVATypography.bodySmall, // ✅ Label negro
                  fillColor: BBVAColors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: BBVAColors.primaryBlue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: BBVAColors.primaryBlue,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              if (authViewModel.isLoading)
                const CircularProgressIndicator(
                  color: BBVAColors.primaryBlue, // ✅ Loading azul
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final currentContext = context;
                      bool success = await authViewModel.login(
                        codeController.text,
                        passwordController.text,
                      );
                      if (success && currentContext.mounted) {
                        GoRouter.of(currentContext).push('/cartera');
                      } else if (currentContext.mounted) {
                        ScaffoldMessenger.of(currentContext).showSnackBar(
                          SnackBar(
                            content: Text(
                              authViewModel.errorMessage,
                              style: BBVATypography.bodySmall.copyWith(
                                color: BBVAColors.white,
                              ),
                            ),
                            backgroundColor: BBVAColors.errorRed,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          BBVAColors.primaryBlue, // ✅ Botón azul BBVA
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Ingresar', style: BBVATypography.button),
                  ),
                ),
              if (authViewModel.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    authViewModel.errorMessage,
                    style: const TextStyle(color: BBVAColors.errorRed),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
