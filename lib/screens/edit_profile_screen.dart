import 'package:flutter/material.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:provider/provider.dart';

import '../core/auth/auth_validators.dart';
import '../models/app_user.dart';
import '../repositories/auth_repository.dart';
import '../widgets/international_phone_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  PhoneNumber _phone = PhoneNumber.parse('+992');

  _ProfileFormValue? _initialValue;
  bool _initialized = false;
  bool _removeAvatar = false;
  bool _allowPop = false;
  String? _saveError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _phone = InternationalPhoneField.parseOrDefault(user.phone);
    _countryController.text = user.country ?? '';
    _cityController.text = user.city ?? '';
    _initialValue = _currentValue;

    for (final controller in _controllers) {
      controller.addListener(_onFormChanged);
    }
  }

  List<TextEditingController> get _controllers => [
    _firstNameController,
    _lastNameController,
    _countryController,
    _cityController,
  ];

  _ProfileFormValue get _currentValue => _ProfileFormValue(
    firstName: _firstNameController.text.trim(),
    lastName: _lastNameController.text.trim(),
    phone: InternationalPhoneField.normalized(_phone),
    country: _countryController.text.trim(),
    city: _cityController.text.trim(),
    removeAvatar: _removeAvatar,
  );

  bool get _hasChanges =>
      _initialValue != null && _currentValue != _initialValue;

  void _onFormChanged() {
    if (mounted) setState(() => _saveError = null);
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller
        ..removeListener(_onFormChanged)
        ..dispose();
    }
    super.dispose();
  }

  Future<bool> _confirmDiscard() async {
    if (!_hasChanges) return true;
    final discard =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Отменить изменения?'),
            content: const Text(
              'Несохранённые изменения профиля будут потеряны.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Продолжить редактирование'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Отменить изменения'),
              ),
            ],
          ),
        ) ??
        false;
    return discard;
  }

  Future<void> _handlePop() async {
    if (await _confirmDiscard() && mounted) {
      setState(() => _allowPop = true);
      Navigator.pop(context);
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    if (user == null) {
      setState(() => _saveError = 'Сессия завершена. Войдите снова.');
      return;
    }

    final value = _currentValue;
    setState(() => _saveError = null);
    try {
      await authProvider.updateUser(
        user.copyWith(
          firstName: value.firstName,
          lastName: value.lastName,
          phone: value.phone,
          country: value.country,
          city: value.city,
          clearAvatar: value.removeAvatar,
        ),
      );
      if (!mounted) return;
      setState(() => _allowPop = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Профиль успешно обновлён'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saveError = error.toString());
    }
  }

  Future<void> _sendVerification() async {
    try {
      await context.read<AuthProvider>().resendEmailVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Письмо для подтверждения отправлено'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      _showError(error.toString());
    }
  }

  Future<void> _refreshVerification() async {
    try {
      await context.read<AuthProvider>().refreshUser();
      if (!mounted) return;
      final verified = context.read<AuthProvider>().isEmailVerified;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            verified
                ? 'Email подтверждён'
                : 'Email ещё не подтверждён. Проверьте почту.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      _showError(error.toString());
    }
  }

  Future<void> _sendPasswordReset() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null || user.email.trim().isEmpty) return;
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Изменить пароль'),
            content: Text(
              'Отправить безопасную ссылку для смены пароля на '
              '${user.email}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Отправить'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;

    try {
      await context.read<AuthProvider>().resetPassword(user.email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ссылка для смены пароля отправлена'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      _showError(error.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return PopScope(
      canPop: _allowPop || !_hasChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handlePop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Редактировать профиль'),
          leading: IconButton(
            onPressed: authProvider.isLoading ? null : _handlePop,
            tooltip: 'Назад',
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: user == null
            ? const _SignedOutState()
            : SafeArea(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    children: [
                      _AvatarEditor(
                        user: user,
                        removeAvatar: _removeAvatar,
                        onRemoveChanged: (remove) {
                          setState(() {
                            _removeAvatar = remove;
                            _saveError = null;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Личные данные',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _firstNameController,
                        enabled: !authProvider.isLoading,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.givenName],
                        maxLength: 60,
                        decoration: const InputDecoration(
                          labelText: 'Имя',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) => AuthValidators.name(value, 'имя'),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _lastNameController,
                        enabled: !authProvider.isLoading,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.familyName],
                        maxLength: 60,
                        decoration: const InputDecoration(
                          labelText: 'Фамилия',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (value) =>
                            AuthValidators.name(value, 'фамилию'),
                      ),
                      const SizedBox(height: 4),
                      InternationalPhoneField(
                        initialValue: _phone,
                        enabled: !authProvider.isLoading,
                        onChanged: (phone) {
                          if (phone == null) return;
                          setState(() {
                            _phone = phone;
                            _saveError = null;
                          });
                        },
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _countryController,
                        enabled: !authProvider.isLoading,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.countryName],
                        maxLength: 100,
                        decoration: const InputDecoration(
                          labelText: 'Страна',
                          prefixIcon: Icon(Icons.public),
                        ),
                        validator: (value) =>
                            AuthValidators.optionalPlace(value, 'Страна'),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _cityController,
                        enabled: !authProvider.isLoading,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.addressCity],
                        maxLength: 100,
                        onFieldSubmitted: (_) {
                          if (_hasChanges && !authProvider.isLoading) _save();
                        },
                        decoration: const InputDecoration(
                          labelText: 'Город',
                          prefixIcon: Icon(Icons.location_city_outlined),
                        ),
                        validator: (value) =>
                            AuthValidators.optionalPlace(value, 'Город'),
                      ),
                      const SizedBox(height: 12),
                      _AccountSecurityCard(
                        user: user,
                        isEmailVerified: authProvider.isEmailVerified,
                        isLoading: authProvider.isLoading,
                        onSendVerification: _sendVerification,
                        onRefreshVerification: _refreshVerification,
                        onPasswordReset: _sendPasswordReset,
                      ),
                      if (_saveError != null) ...[
                        const SizedBox(height: 16),
                        _InlineError(message: _saveError!),
                      ],
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: authProvider.isLoading || !_hasChanges
                            ? null
                            : _save,
                        icon: authProvider.isLoading
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          authProvider.isLoading
                              ? 'Сохранение…'
                              : 'Сохранить изменения',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _AvatarEditor extends StatelessWidget {
  final AppUser user;
  final bool removeAvatar;
  final ValueChanged<bool> onRemoveChanged;

  const _AvatarEditor({
    required this.user,
    required this.removeAvatar,
    required this.onRemoveChanged,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = removeAvatar ? null : user.avatar;
    return Column(
      children: [
        CircleAvatar(
          radius: 52,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundImage: avatar == null ? null : NetworkImage(avatar),
          onForegroundImageError: avatar == null ? null : (_, __) {},
          child: const Icon(Icons.person_outline, size: 48),
        ),
        if (user.avatar != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => onRemoveChanged(!removeAvatar),
            icon: Icon(removeAvatar ? Icons.undo : Icons.delete_outline),
            label: Text(removeAvatar ? 'Вернуть фото' : 'Удалить фото'),
          ),
        ],
        const Text(
          'Фото профиля из Google-аккаунта можно удалить здесь.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}

class _AccountSecurityCard extends StatelessWidget {
  final AppUser user;
  final bool isEmailVerified;
  final bool isLoading;
  final VoidCallback onSendVerification;
  final VoidCallback onRefreshVerification;
  final VoidCallback onPasswordReset;

  const _AccountSecurityCard({
    required this.user,
    required this.isEmailVerified,
    required this.isLoading,
    required this.onSendVerification,
    required this.onRefreshVerification,
    required this.onPasswordReset,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Безопасность аккаунта',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.email_outlined),
              title: Text(user.email),
              subtitle: Text(
                isEmailVerified ? 'Email подтверждён' : 'Email не подтверждён',
              ),
              trailing: Icon(
                isEmailVerified
                    ? Icons.verified_outlined
                    : Icons.warning_amber_outlined,
                color: isEmailVerified ? Colors.green : Colors.orange,
              ),
            ),
            if (!isEmailVerified)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: isLoading ? null : onSendVerification,
                    child: const Text('Отправить письмо'),
                  ),
                  TextButton(
                    onPressed: isLoading ? null : onRefreshVerification,
                    child: const Text('Я уже подтвердил'),
                  ),
                ],
              ),
            const Divider(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lock_reset_outlined),
              title: const Text('Изменить пароль'),
              subtitle: const Text('Ссылка будет отправлена на ваш email'),
              trailing: const Icon(Icons.chevron_right),
              enabled: !isLoading,
              onTap: isLoading ? null : onPasswordReset,
            ),
            const Text(
              'Email, роль и права доступа нельзя изменить на этом экране.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colors.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colors.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignedOutState extends StatelessWidget {
  const _SignedOutState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 48),
            SizedBox(height: 12),
            Text(
              'Сессия завершена. Войдите снова, чтобы изменить профиль.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileFormValue {
  final String firstName;
  final String lastName;
  final String phone;
  final String country;
  final String city;
  final bool removeAvatar;

  const _ProfileFormValue({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.country,
    required this.city,
    required this.removeAvatar,
  });

  @override
  bool operator ==(Object other) {
    return other is _ProfileFormValue &&
        firstName == other.firstName &&
        lastName == other.lastName &&
        phone == other.phone &&
        country == other.country &&
        city == other.city &&
        removeAvatar == other.removeAvatar;
  }

  @override
  int get hashCode =>
      Object.hash(firstName, lastName, phone, country, city, removeAvatar);
}
