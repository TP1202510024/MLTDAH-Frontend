class RegisterData {
  String firstName;
  String lastName;
  String dni;
  String birthDate; // ISO 8601 string
  String email;
  String password;
  String name;
  String creationDate; // ISO 8601 string
  String address;

  RegisterData({
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

  Map<String, dynamic> toJson() => {
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
