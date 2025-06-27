class SignUpRequest {
  final String firstName;
  final String lastName;
  final String dni;
  final String birthDate;
  final String email;
  final String password;
  final String name;
  final String creationDate;
  final String address;

  SignUpRequest({
    required this.firstName,
    required this.lastName,
    required this.dni,
    required this.birthDate,
    required this.email,
    required this.password,
    required this.name,
    required this.creationDate,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      "firstName": firstName,
      "lastName": lastName,
      "dni": dni,
      "birthDate": birthDate,
      "email": email,
      "password": password,
      "name": name,
      "creationDate": creationDate,
      "address": address,
    };
  }
}
