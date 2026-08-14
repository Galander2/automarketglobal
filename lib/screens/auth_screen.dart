import 'package:flutter/material.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:provider/provider.dart';
import '../core/auth/auth_validators.dart';
import '../core/theme/app_theme.dart';
import '../repositories/auth_repository.dart';
import '../widgets/app_hover_lift.dart';
import '../widgets/international_phone_field.dart';
import '../widgets/premium_car_illustration.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  PhoneNumber _registrationPhone = PhoneNumber.parse('+992');

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool? _darkAppearance;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _darkAppearance ??=
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();

      if (_isLogin) {
        await authProvider.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await authProvider.registerUser(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phone: InternationalPhoneField.normalized(_registrationPhone),
        );
      }

      // Навигация произойдёт автоматически через main.dart
      if (mounted) {
        // Очищаем форму после успешного входа/регистрации
        _formKey.currentState?.reset();
        _registrationPhone = PhoneNumber.parse('+992');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().signInWithGoogle();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Не удалось войти через Google. Проверьте подключение и настройки аккаунта.',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _switchMode(bool login) {
    if (_isLogin == login || _isLoading) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isLogin = login;
      _obscurePassword = true;
      _obscureConfirmPassword = true;
    });
    _formKey.currentState?.reset();
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Сброс пароля'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Введите ваш email для сброса пароля'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              final validation = AuthValidators.email(emailController.text);
              if (validation != null) {
                ScaffoldMessenger.of(
                  dialogContext,
                ).showSnackBar(SnackBar(content: Text(validation)));
                return;
              }

              try {
                final authProvider = dialogContext.read<AuthProvider>();
                await authProvider.resetPassword(emailController.text.trim());

                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Письмо для сброса пароля отправлено'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Отправить'),
          ),
        ],
      ),
    );
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkAppearance = _darkAppearance ?? true;
    return Theme(
      data: darkAppearance ? AppTheme.dark() : AppTheme.light(),
      child: Builder(
        builder: (themedContext) => _buildContent(themedContext),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final busy = _isLoading || authProvider.isLoading;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? const [
                          Color(0xFF090711),
                          Color(0xFF20103D),
                          Color(0xFF351425),
                        ]
                      : const [
                          Color(0xFFF7F3FF),
                          Color(0xFFECE2FF),
                          Color(0xFFFFE5D5),
                        ],
                ),
              ),
              child: CustomPaint(
                painter: _AuthBackdropPainter(
                  dark: Theme.of(context).brightness == Brightness.dark,
                ),
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 940;
                      return SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          wide ? 48 : 18,
                          wide ? 40 : 72,
                          wide ? 48 : 18,
                          wide ? 40 : 24,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight:
                                constraints.maxHeight - (wide ? 80 : 96) > 0
                                ? constraints.maxHeight - (wide ? 80 : 96)
                                : 0,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1180),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (wide) ...[
                                    const Expanded(child: _BrandPanel()),
                                    const SizedBox(width: 56),
                                  ],
                                  Expanded(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 520,
                                      ),
                                      child: Card(
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            28,
                                          ),
                                          side: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outlineVariant
                                                .withValues(alpha: 0.55),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(wide ? 34 : 22),
                                          child: AutofillGroup(
                                            child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          if (!wide) const _CompactBrand(),
                                          _AuthModeSelector(
                                            isLogin: _isLogin,
                                            enabled: !busy,
                                            onChanged: _switchMode,
                                          ),
                                          const SizedBox(height: 28),
                                          AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 220,
                                            ),
                                            child: Column(
                                              key: ValueKey(_isLogin),
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _isLogin
                                                      ? 'С возвращением'
                                                      : 'Создайте аккаунт',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        letterSpacing: -0.8,
                                                      ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  _isLogin
                                                      ? 'Войдите, чтобы продолжить работу с Auto Market Global.'
                                                      : 'Заполните данные — это займёт меньше минуты.',
                                                  style: const TextStyle(
                                                    color: AppColors.muted,
                                                    height: 1.45,
                                                  ),
                                                ),
                                                const SizedBox(height: 26),
                                                if (!_isLogin) ...[
                                                  _NameFields(
                                                    firstNameController:
                                                        _firstNameController,
                                                    lastNameController:
                                                        _lastNameController,
                                                    enabled: !busy,
                                                  ),
                                                  const SizedBox(height: 16),
                                                  InternationalPhoneField(
                                                    initialValue:
                                                        _registrationPhone,
                                                    enabled: !busy,
                                                    onChanged: (phone) {
                                                      if (phone != null) {
                                                        _registrationPhone =
                                                            phone;
                                                      }
                                                    },
                                                  ),
                                                  const SizedBox(height: 16),
                                                ],
                                                TextFormField(
                                                  controller: _emailController,
                                                  enabled: !busy,
                                                  decoration: const InputDecoration(
                                                    labelText: 'Email',
                                                    hintText:
                                                        'name@example.com',
                                                    prefixIcon: Icon(
                                                      Icons
                                                          .alternate_email_rounded,
                                                    ),
                                                  ),
                                                  keyboardType: TextInputType
                                                      .emailAddress,
                                                  autofillHints: const [
                                                    AutofillHints.email,
                                                  ],
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  validator:
                                                      AuthValidators.email,
                                                ),
                                                const SizedBox(height: 16),
                                                _PasswordField(
                                                  controller:
                                                      _passwordController,
                                                  label: 'Пароль',
                                                  obscure: _obscurePassword,
                                                  enabled: !busy,
                                                  autofillHint: _isLogin
                                                      ? AutofillHints.password
                                                      : AutofillHints
                                                            .newPassword,
                                                  onToggle: () => setState(
                                                    () => _obscurePassword =
                                                        !_obscurePassword,
                                                  ),
                                                  onSubmitted: _isLogin
                                                      ? _handleSubmit
                                                      : null,
                                                  validator: (value) => _isLogin
                                                      ? ((value == null ||
                                                                value.isEmpty)
                                                            ? 'Введите пароль'
                                                            : null)
                                                      : AuthValidators.password(
                                                          value,
                                                        ),
                                                ),
                                                if (!_isLogin) ...[
                                                  const SizedBox(height: 16),
                                                  _PasswordField(
                                                    controller:
                                                        _confirmPasswordController,
                                                    label: 'Повторите пароль',
                                                    obscure:
                                                        _obscureConfirmPassword,
                                                    enabled: !busy,
                                                    autofillHint: AutofillHints
                                                        .newPassword,
                                                    onToggle: () => setState(
                                                      () => _obscureConfirmPassword =
                                                          !_obscureConfirmPassword,
                                                    ),
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Подтвердите пароль';
                                                      }
                                                      if (value !=
                                                          _passwordController
                                                              .text) {
                                                        return 'Пароли не совпадают';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          if (_isLogin)
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: TextButton(
                                                onPressed: busy
                                                    ? null
                                                    : _showForgotPasswordDialog,
                                                child: const Text(
                                                  'Забыли пароль?',
                                                ),
                                              ),
                                            )
                                          else
                                            const SizedBox(height: 20),
                                          AppHoverLift(
                                            enabled: !busy,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            hoverScale: 1.018,
                                            child: FilledButton(
                                              onPressed: busy
                                                  ? null
                                                  : _handleSubmit,
                                              child: busy
                                                  ? const SizedBox.square(
                                                      dimension: 22,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2.4,
                                                            color: Colors.white,
                                                          ),
                                                    )
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          _isLogin
                                                              ? 'Войти'
                                                              : 'Создать аккаунт',
                                                        ),
                                                        const SizedBox(width: 8),
                                                        const Icon(
                                                          Icons
                                                              .arrow_forward_rounded,
                                                          size: 20,
                                                        ),
                                                      ],
                                                    ),
                                            ),
                                          ),
                                          const SizedBox(height: 22),
                                          const _DividerLabel(),
                                          const SizedBox(height: 18),
                                          AppHoverLift(
                                            enabled: !busy,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            hoverScale: 1.018,
                                            child: OutlinedButton(
                                              onPressed: busy
                                                  ? null
                                                  : _handleGoogleSignIn,
                                              child: const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  _GoogleMark(),
                                                  SizedBox(width: 12),
                                                  Text('Продолжить с Google'),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 18),
                                          const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.shield_outlined,
                                                size: 16,
                                                color: AppColors.success,
                                              ),
                                              SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  'Защищённая авторизация Firebase',
                                                  style: TextStyle(
                                                    color: AppColors.muted,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
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
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 14,
            right: 18,
            child: _AppearanceButton(
              dark: _darkAppearance ?? true,
              onPressed: busy
                  ? null
                  : () => setState(
                      () => _darkAppearance = !(_darkAppearance ?? true),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceButton extends StatelessWidget {
  const _AppearanceButton({required this.dark, required this.onPressed});

  final bool dark;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final foreground = Theme.of(context).colorScheme.onSurface;
    return AppHoverLift(
      enabled: onPressed != null,
      borderRadius: BorderRadius.circular(16),
      hoverScale: 1.06,
      child: Material(
        color: Theme.of(context).cardColor.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(16),
        elevation: 8,
        shadowColor: const Color(0xFF8D4DFF).withValues(alpha: 0.25),
        child: IconButton(
          tooltip: dark ? 'Включить светлую тему' : 'Включить тёмную тему',
          onPressed: onPressed,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) => RotationTransition(
              turns: Tween<double>(begin: 0.75, end: 1).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Icon(
              dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              key: ValueKey(dark),
              color: dark ? const Color(0xFFFFB15C) : foreground,
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthBackdropPainter extends CustomPainter {
  const _AuthBackdropPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = (dark ? Colors.white : const Color(0xFF472B75)).withValues(
        alpha: dark ? 0.045 : 0.07,
      )
      ..strokeWidth = 1;
    const gridSize = 56.0;
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    void drawGlow(Offset center, double radius, Color color) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ).createShader(rect),
      );
    }

    drawGlow(
      Offset(size.width * 0.12, size.height * 0.1),
      size.shortestSide * 0.42,
      const Color(0xFF8D4DFF).withValues(alpha: dark ? 0.22 : 0.18),
    );
    drawGlow(
      Offset(size.width * 0.88, size.height * 0.88),
      size.shortestSide * 0.5,
      const Color(0xFFFF814A).withValues(alpha: dark ? 0.18 : 0.2),
    );
  }

  @override
  bool shouldRepaint(covariant _AuthBackdropPainter oldDelegate) {
    return oldDelegate.dark != dark;
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 620),
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF100B1E), Color(0xFF35165C), Color(0xFF7B294C)],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8D4DFF).withValues(alpha: 0.28),
            blurRadius: 48,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: const Color(0xFFFF8A42).withValues(alpha: 0.16),
            blurRadius: 52,
            offset: const Offset(22, -10),
          ),
        ],
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BrandMark(dark: true),
          SizedBox(height: 42),
          PremiumCarIllustration(height: 250),
          SizedBox(height: 34),
          Text(
            'Ваш автомобиль.\nВаш рынок.\nВаш выбор.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 42,
              height: 1.08,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.5,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Покупайте, продавайте и общайтесь безопасно на единой международной платформе.',
            style: TextStyle(
              color: Color(0xFFDCE8FF),
              fontSize: 17,
              height: 1.55,
            ),
          ),
          SizedBox(height: 34),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _TrustBadge(icon: Icons.verified_outlined, label: 'Проверенные'),
              _TrustBadge(icon: Icons.public, label: 'Международные'),
              _TrustBadge(icon: Icons.lock_outline, label: 'Защищённые'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactBrand extends StatelessWidget {
  const _CompactBrand();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: _BrandMark(dark: false),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final foreground = dark
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: dark
                ? const LinearGradient(
                    colors: [Color(0xFF8D4DFF), Color(0xFFFF7A45)],
                  )
                : null,
            color: dark ? null : AppColors.primary,
            borderRadius: BorderRadius.circular(15),
            boxShadow: dark
                ? [
                    BoxShadow(
                      color: const Color(0xFFFF8A42).withValues(alpha: 0.26),
                      blurRadius: 18,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            Icons.directions_car_filled_rounded,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Auto Market Global',
          style: TextStyle(
            color: foreground,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}

class _TrustBadge extends StatelessWidget {
  const _TrustBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 17),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthModeSelector extends StatelessWidget {
  const _AuthModeSelector({
    required this.isLogin,
    required this.enabled,
    required this.onChanged,
  });

  final bool isLogin;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeButton(
              label: 'Вход',
              selected: isLogin,
              enabled: enabled,
              onTap: () => onChanged(true),
            ),
          ),
          Expanded(
            child: _ModeButton(
              label: 'Регистрация',
              selected: !isLogin,
              enabled: enabled,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppHoverLift(
      enabled: enabled,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).cardColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.muted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NameFields extends StatelessWidget {
  const _NameFields({
    required this.firstNameController,
    required this.lastNameController,
    required this.enabled,
  });

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final vertical = constraints.maxWidth < 390;
        final fields = [
          TextFormField(
            controller: firstNameController,
            enabled: enabled,
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.givenName],
            decoration: const InputDecoration(
              labelText: 'Имя',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            validator: (value) => AuthValidators.name(value, 'имя'),
          ),
          TextFormField(
            controller: lastNameController,
            enabled: enabled,
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.familyName],
            decoration: const InputDecoration(
              labelText: 'Фамилия',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            validator: (value) => AuthValidators.name(value, 'фамилию'),
          ),
        ];
        if (vertical) {
          return Column(
            children: [fields.first, const SizedBox(height: 16), fields.last],
          );
        }
        return Row(
          children: [
            Expanded(child: fields.first),
            const SizedBox(width: 12),
            Expanded(child: fields.last),
          ],
        );
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.enabled,
    required this.autofillHint,
    required this.onToggle,
    required this.validator,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final bool obscure;
  final bool enabled;
  final String autofillHint;
  final VoidCallback onToggle;
  final FormFieldValidator<String> validator;
  final Future<void> Function()? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscure,
      autofillHints: [autofillHint],
      textInputAction: onSubmitted == null
          ? TextInputAction.next
          : TextInputAction.done,
      onFieldSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          tooltip: obscure ? 'Показать пароль' : 'Скрыть пароль',
          onPressed: enabled ? onToggle : null,
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          ),
        ),
      ),
      validator: validator,
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'или',
            style: TextStyle(color: AppColors.muted, fontSize: 13),
          ),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Text(
        'G',
        style: TextStyle(
          color: Color(0xFF4285F4),
          fontSize: 17,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
