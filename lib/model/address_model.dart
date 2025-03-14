class AddressModel {

  final String city;
  final String postalCode;
  final String countryCode;
  final String region;
  final String street;
  final String number;
  final String bus;

  AddressModel({
    required this.city,
    required this.postalCode,
    required this.countryCode,
    required this.region,
    required this.street,
    required this.number,
    required this.bus,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      city: json['city'], 
      postalCode: json['postalCode'], 
      countryCode: json['countryCode'], 
      region: json['region'], 
      street: json['street'], 
      number: json['number'], 
      bus: json['bus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'postalCode': postalCode,
      'countryCode': countryCode,
      'region': region,
      'street': street,
      'number': number,
      'bus': bus,
    };
  }
}