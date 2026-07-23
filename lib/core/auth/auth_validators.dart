class AuthValidators {
  AuthValidators._();

  static final RegExp _emailPattern = RegExp(
    r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
    caseSensitive: false,
  );
  static final RegExp _phonePattern = RegExp(r'^\+?[0-9]{8,15}$');

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Введите email';
    if (!_emailPattern.hasMatch(email)) return 'Введите корректный email';
    return null;
  }

  static String? password(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Введите пароль';
    if (password.length < 8) return 'Минимум 8 символов';
    if (!password.contains(RegExp(r'[A-Za-z]')) ||
        !password.contains(RegExp(r'[0-9]'))) {
      return 'Добавьте буквы и цифры';
    }
    return null;
  }

  static String? name(String? value, String label) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Введите $label';
    if (name.length < 2) return 'Минимум 2 символа';
    return null;
  }

  static String? phone(String? value) {
    final phone = (value ?? '').replaceAll(RegExp(r'[\s()\-]'), '');
    if (phone.isEmpty) return 'Введите телефон';
    if (!_phonePattern.hasMatch(phone)) return 'Введите корректный телефон';
    return null;
  }
}
