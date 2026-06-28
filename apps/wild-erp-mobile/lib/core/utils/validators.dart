class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email es requerido';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Email inválido';
    return null;
  }

  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Contraseña es requerida';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.length < min) {
      return '${fieldName ?? 'Este campo'} debe tener al menos $min caracteres';
    }
    return null;
  }

  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value != null && value.length > max) {
      return '${fieldName ?? 'Este campo'} debe tener máximo $max caracteres';
    }
    return null;
  }

  static String? number(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }
    if (double.tryParse(value) == null) return 'Debe ser un número válido';
    return null;
  }

  static String? positiveNumber(String? value, {String? fieldName}) {
    final numError = number(value, fieldName: fieldName);
    if (numError != null) return numError;
    if (double.parse(value!) <= 0) return 'Debe ser mayor a 0';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Teléfono es requerido';
    final regex = RegExp(r'^\+?[\d\s-]{8,15}$');
    if (!regex.hasMatch(value)) return 'Teléfono inválido';
    return null;
  }

  static String? url(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) return null; // optional
    final regex = RegExp(r'^https?:\/\/.+');
    if (!regex.hasMatch(value)) {
      return '${fieldName ?? 'URL'} inválida';
    }
    return null;
  }
}
