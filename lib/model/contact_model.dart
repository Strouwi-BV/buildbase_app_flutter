class ContactModel {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final bool primaryContact;
  final String jobTitle;

  ContactModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.primaryContact,
    required this.jobTitle,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'], 
      firstName: json['firstName'], 
      lastName: json['lastName'], 
      phone: json['phone'], 
      email: json['email'], 
      primaryContact: json['primaryContact'], 
      jobTitle: json['jobTitle']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 
      'firstName': firstName, 
      'lastName': lastName, 
      'phone': phone, 
      'email': email, 
      'primaryContact': primaryContact, 
      'jobTitle': jobTitle
    };
  }
}