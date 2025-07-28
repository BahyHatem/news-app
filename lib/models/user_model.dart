class UserModel {
   String id;
   String firstName;
   String lastName;
   String email;
   String passwordHash;
   String? phoneNumber;
   DateTime? dateOfBirth;
   String? profileImage;
   DateTime createdAt;
   DateTime? lastLoginAt;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.passwordHash,
    this.phoneNumber,
    this.dateOfBirth,
    this.profileImage,
    required this.createdAt,
    this.lastLoginAt,
  });
}
