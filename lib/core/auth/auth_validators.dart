class AuthValidators {
  AuthValidators._();

  static final RegExp _emailPattern = RegExp(
    r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
    caseSensitive: false,
  );
  static final RegExp _phonePattern = RegExp(r'^\+?[0-9]{8,15}$');
  static final RegExp _namePattern = RegExp(
    r"^[\p{L}\p{M}][\p{L}\p{M} .'-]*$",
    unicode: true,
  );
  static final RegExp _placePattern = RegExp(
    r"^[\p{L}\p{M}][\p{L}\p{M} .,'()\-]*$",
    unicode: true,
  );

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
    if (name.length > 60) return 'Максимум 60 символов';
    if (!_namePattern.hasMatch(name)) {
      return 'Используйте только буквы, пробел, дефис или апостроф';
    }
    return null;
  }

  static String? phone(String? value) {
    final phone = normalizePhone(value ?? '');
    if (phone.isEmpty) return 'Введите телефон';
    if (!_phonePattern.hasMatch(phone)) return 'Введите корректный телефон';
    return null;
  }

  static String? optionalPlace(String? value, String label) {
    final place = value?.trim() ?? '';
    if (place.isEmpty) return null;
    if (place.length < 2) return '$label: минимум 2 символа';
    if (place.length > 100) return '$label: максимум 100 символов';
    if (!_placePattern.hasMatch(place)) {
      return '$label: используйте буквы и обычные знаки';
    }
    return null;
  }

  static String normalizePhone(String value) {
    return value.trim().replaceAll(RegExp(r'[\s()\-]'), '');
  }
}
