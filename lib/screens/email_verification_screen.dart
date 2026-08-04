import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../repositories/auth_repository.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _resendLocked = false;

  Future<void> _checkEmail() async {
    try {
      await context.read<AuthProvider>().refreshEmailVerification();
      if (!mounted) return;
      if (!context.read<AuthProvider>().isEmailVerified) {
        _showMessage('Email ещё не подтверждён');
      }
    } catch (_) {
      if (mounted) {
        _showMessage(
          'Не удалось проверить подтверждение. Попробуйте ещё раз.',
          isError: true,
        );
      }
    }
  }

  Future<void> _resend() async {
    if (_resendLocked) return;
    setState(() => _resendLocked = true);
    try {
      await context.read<AuthProvider>().resendEmailVerification();
      if (mounted) _showMessage('Новое письмо отправлено');
      await Future<void>.delayed(const Duration(seconds: 30));
    } catch (_) {
      if (mounted) {
        _showMessage(
          'Не удалось отправить письмо. Попробуйте немного позже.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _resendLocked = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              AppColors.primary.withValues(alpha: 0.08),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.accent],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.24,
                                ),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.mark_email_unread_rounded,
                            size: 54,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Подтвердите email',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Мы отправили ссылку на ${auth.currentUser?.email ?? 'ваш email'}. Откройте письмо и нажмите ссылку.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: auth.isLoading ? null : _checkEmail,
                            icon: auth.isLoading
                                ? const SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.verified_outlined),
                            label: const Text('Я подтвердил email'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: auth.isLoading || _resendLocked
                              ? null
                              : _resend,
                          child: Text(
                            _resendLocked
                                ? 'Повторная отправка временно недоступна'
                                : 'Отправить письмо ещё раз',
                          ),
                        ),
                        TextButton.icon(
                          onPressed: auth.isLoading ? null : auth.signOut,
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: const Text(
                            'Выйти и использовать другой email',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
