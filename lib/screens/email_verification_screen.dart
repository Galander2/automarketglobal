import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    } catch (error) {
      if (mounted) _showMessage(error.toString(), isError: true);
    }
  }

  Future<void> _resend() async {
    if (_resendLocked) return;
    setState(() => _resendLocked = true);
    try {
      await context.read<AuthProvider>().resendEmailVerification();
      if (mounted) _showMessage('Новое письмо отправлено');
      await Future<void>.delayed(const Duration(seconds: 30));
    } catch (error) {
      if (mounted) _showMessage(error.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _resendLocked = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                children: [
                  const Icon(
                    Icons.mark_email_unread_outlined,
                    size: 96,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Подтвердите email',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Мы отправили ссылку на ${auth.currentUser?.email ?? 'ваш email'}. Откройте письмо и нажмите ссылку.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700], fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: auth.isLoading ? null : _checkEmail,
                      child: auth.isLoading
                          ? const CircularProgressIndicator(strokeWidth: 2)
                          : const Text('Я подтвердил email'),
                    ),
                  ),
                  TextButton(
                    onPressed: auth.isLoading || _resendLocked ? null : _resend,
                    child: Text(
                      _resendLocked
                          ? 'Повторная отправка временно недоступна'
                          : 'Отправить письмо ещё раз',
                    ),
                  ),
                  TextButton(
                    onPressed: auth.isLoading ? null : auth.signOut,
                    child: const Text('Выйти и использовать другой email'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
