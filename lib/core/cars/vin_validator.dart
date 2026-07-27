class VinValidator {
  VinValidator._();

  static final RegExp _validCharacters = RegExp(r'^[A-HJ-NPR-Z0-9]{17}$');

  static String normalize(String value) =>
      value.replaceAll(RegExp(r'\s+'), '').toUpperCase();

  static bool isValid(String value) =>
      _validCharacters.hasMatch(normalize(value));
}
