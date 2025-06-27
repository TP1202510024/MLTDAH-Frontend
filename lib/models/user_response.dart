class UserResponse {
  final int id;
  final String firstName;
  final String lastName;
  final String dni;
  final String email;

  UserResponse({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dni,
    required this.email,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dni: json['dni'],
      email: json['email'],
    );
  }
}
