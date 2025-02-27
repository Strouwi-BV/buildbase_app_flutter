

class UserModel{

  final int id;
  final String firstName;
  final String lastName;
  final String birthDate;
  final String nationality;
  final String socialNumber;
  final String bankAccount;
  final String email;
  final String workEmail;
  final String phone;
  final String address;
  final String emergencyContact;

  const UserModel({
  required this.id,
  required this.firstName, 
  required this.lastName,
  required this.birthDate,
  required this.nationality,
  required this.socialNumber,
  required this.bankAccount,
  required this.email,
  required this.workEmail,
  required this.phone,
  required this.address,
  required this.emergencyContact
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'id' : int id, 
      'firstName' : String firstName,
      'lastName' : String lastName,
      'birthDate' : String birthDate,
      'nationality': String nationality,
      'socialNumber' : String socialNumber,
      'bankAccount' : String bankAccount,
      'email' : String email,
      'workEmail' : String workEmail,
      'phone' : String phone,
      'address' : String address,
      'emergencyContact' : String emergencyContact
      } => UserModel(
      id: id, 
      firstName: firstName, 
      lastName: lastName, 
      birthDate: birthDate, 
      nationality: nationality, 
      socialNumber: socialNumber, 
      bankAccount: bankAccount, 
      email: email, 
      workEmail: workEmail, 
      phone: phone, 
      address: address, 
      emergencyContact: emergencyContact
      ),
      _ => throw const FormatException('Failed to load user.'),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id' : id, 
      'firstName' : firstName,
      'lastName' : lastName,
      'birthDate' : birthDate,
      'nationality': nationality,
      'socialNumber' : socialNumber,
      'bankAccount' : bankAccount,
      'email' : email,
      'workEmail' : workEmail,
      'phone' : phone,
      'address' : address,
      'emergencyContact' : emergencyContact
    };
  }

}
