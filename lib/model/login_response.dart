class LoginResponse {
  final List<String> roles;
  final String token;
  final String type;
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String organizationId;

  LoginResponse({
    required this.roles,
    required this.token,
    required this.type,
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.organizationId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      roles: List<String>.from(json['roles'] ?? []),
      token: json['token'] ?? '',
      type: json['type'] ?? '',
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      organizationId: json['organizationId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roles': roles,
      'token': token,
      'type': type,
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'organizationId': organizationId,
    };
  }
}
