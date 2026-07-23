class CarFormValidators {
  const CarFormValidators._();

  static String? title(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Введите название';
    if (text.length < 3) return 'Название слишком короткое';
    if (text.length > 120) return 'Не более 120 символов';
    return null;
  }

  static String? price(String? value) {
    final number = _wholeNumber(value);
    if (number == null) return 'Введите корректную цену';
    if (number <= 0) return 'Цена должна быть больше нуля';
    return null;
  }

  static String? year(String? value, {int? currentYear}) {
    final number = int.tryParse(value?.trim() ?? '');
    if (number == null) return 'Введите корректный год';
    final maximum = (currentYear ?? DateTime.now().year) + 1;
    if (number < 1886 || number > maximum) {
      return 'Год должен быть от 1886 до $maximum';
    }
    return null;
  }

  static String? mileage(String? value) {
    final number = _wholeNumber(value);
    if (number == null) return 'Введите корректный пробег';
    if (number < 0) return 'Пробег не может быть отрицательным';
    return null;
  }

  static String? city(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Введите город';
    if (text.length < 2) return 'Название города слишком короткое';
    if (text.length > 100) return 'Не более 100 символов';
    return null;
  }

  static String? description(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Введите описание';
    if (text.length < 10) return 'Добавьте больше информации';
    if (text.length > 5000) return 'Не более 5000 символов';
    return null;
  }

  static String? vin(String? value) {
    final text = value?.trim().toUpperCase() ?? '';
    if (text.isEmpty) return null;
    if (!RegExp(r'^[A-HJ-NPR-Z0-9]{17}$').hasMatch(text)) {
      return 'VIN должен содержать 17 допустимых символов';
    }
    return null;
  }

  static int? _wholeNumber(String? value) {
    final normalized = value?.replaceAll(RegExp(r'[^0-9-]'), '') ?? '';
    return int.tryParse(normalized);
  }
}
