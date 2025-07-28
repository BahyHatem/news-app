class AuthValidator {
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return "Email cannot be empty.";
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) {
      return "Invalid email format.";
    }

    return null; 
  }

  
  static String? validatePassword(String? password) {
    if (password == null || password.trim().isEmpty) {
      return "Password cannot be empty.";
    }

    if (password.length < 8) {
      return "Password must be at least 8 characters.";
    }

    final upperCase = RegExp(r'[A-Z]');
    final number = RegExp(r'\d');
    final specialChar = RegExp(r'[!@#\$&*~]');

    if (!upperCase.hasMatch(password)) {
      return "Password must contain an uppercase letter.";
    }
    if (!number.hasMatch(password)) {
      return "Password must contain a number.";
    }
    if (!specialChar.hasMatch(password)) {
      return "Password must contain a special character.";
    }

    return null; 
  }


  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return "Name cannot be empty.";
    }

    final nameRegex = RegExp(r"^[a-zA-Z\s]{2,}$");
    if (!nameRegex.hasMatch(name.trim())) {
      return "Name must be at least 2 characters with letters only.";
    }

    return null; 
  }

  
  static String? validatePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return null; 
    }

    final phoneRegex = RegExp(r'^\+?\d{10,15}$');
    if (!phoneRegex.hasMatch(phone.trim())) {
      return "Invalid phone number format.";
    }

    return null; 
  }

  
  static String? validateAge(DateTime? birthDate) {
    if (birthDate == null) return "Birth date is required.";

    final today = DateTime.now();
    final age = today.year - birthDate.year - ((today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) ? 1 : 0);

    if (age < 13) {
      return "You must be at least 13 years old.";
    }

    return null;
  }
}
