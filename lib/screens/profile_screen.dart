import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:buildbase_app_flutter/service/api_service.dart';
import 'package:buildbase_app_flutter/service/secure_storage_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  ProfileScreen({required this.userId});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final SecureStorageService secureStorage = SecureStorageService();

  String birthDate = "2004-02-16";
  String gender = "MALE";
  String bankAccountNumber = "Not Provided";
  String nationalities = "BE";
  String civilStatus = "SINGLE";
  String dependents = "0";
  String birthPlace = "Leuven";
  String taxIdentificationNumber = "123";

  String city = "Nieuwerkerken";
  String postalCode = "3850";
  String countryCode = "BE";
  String region = "Limburg";
  String street = "molenstraat";
  String number = "3";
  String bus = "Not Provided";
  String phoneNumber = "04 68 350300";
  String email = "moorscasper@gmail.com";
  String personalEmail = "Not Provided";
  String primaryContactFirstName = "Not Provided";
  String primaryContactLastName = "Not Provided";
  String primaryContactPhoneNumber = "Not Provided";
  String primaryContactEmail = "Not Provided";
  String primaryContactRelation = "Not Provided";

  @override
  void initState() {
    super.initState();
    _loadProfileData();  // Hier roep je de functie aan om gegevens te laden
  }

  Future<void> _loadProfileData() async {
    // Controleer of gegevens al beschikbaar zijn in Secure Storage
    String? storedBirthDate = await secureStorage.readData("birthDate");

    if (storedBirthDate == null) {
      // Gegevens niet gevonden in Secure Storage, haal ze op van de API
      var userData = await ApiService().fetchUserProfile(widget.userId);
      if (userData != null) {
        // Sla de verkregen gegevens op in Secure Storage
        await secureStorage.writeData("birthDate", userData["birthDate"] ?? birthDate);
        await secureStorage.writeData("gender", userData["gender"] ?? gender);
        await secureStorage.writeData("bankAccountNumber", userData["bankAccountNumber"] ?? bankAccountNumber);
        await secureStorage.writeData("nationalities", userData["nationalities"] ?? nationalities);
        await secureStorage.writeData("civilStatus", userData["civilStatus"] ?? civilStatus);
        await secureStorage.writeData("dependents", userData["dependents"].toString() ?? dependents);
        await secureStorage.writeData("birthPlace", userData["birthPlace"] ?? birthPlace);
        await secureStorage.writeData("taxIdentificationNumber", userData["taxIdentificationNumber"] ?? taxIdentificationNumber);
        await secureStorage.writeData("city", userData["city"] ?? city);
        await secureStorage.writeData("postalCode", userData["postalCode"] ?? postalCode);
        await secureStorage.writeData("countryCode", userData["countryCode"] ?? countryCode);
        await secureStorage.writeData("region", userData["region"] ?? region);
        await secureStorage.writeData("street", userData["street"] ?? street);
        await secureStorage.writeData("number", userData["number"] ?? number);
        await secureStorage.writeData("bus", userData["bus"] ?? bus);
        await secureStorage.writeData("phoneNumber", userData["phoneNumber"] ?? phoneNumber);
        await secureStorage.writeData("email", userData["email"] ?? email);
        await secureStorage.writeData("personalEmail", userData["personalEmail"] ?? personalEmail);
        await secureStorage.writeData("primaryContactFirstName", userData["primaryContactFirstName"] ?? primaryContactFirstName);
        await secureStorage.writeData("primaryContactLastName", userData["primaryContactLastName"] ?? primaryContactLastName);
        await secureStorage.writeData("primaryContactPhoneNumber", userData["primaryContactPhoneNumber"] ?? primaryContactPhoneNumber);
        await secureStorage.writeData("primaryContactEmail", userData["primaryContactEmail"] ?? primaryContactEmail);
        await secureStorage.writeData("primaryContactRelation", userData["primaryContactRelation"] ?? primaryContactRelation);
      }
    }

    // Lees de gegevens opnieuw uit Secure Storage (zowel bij init als na API call)
    birthDate = await secureStorage.readData("birthDate") ?? birthDate;
    gender = await secureStorage.readData("gender") ?? gender;
    bankAccountNumber = await secureStorage.readData("bankAccountNumber") ?? bankAccountNumber;
    nationalities = await secureStorage.readData("nationalities") ?? nationalities;
    civilStatus = await secureStorage.readData("civilStatus") ?? civilStatus;
    dependents = await secureStorage.readData("dependents") ?? dependents;
    birthPlace = await secureStorage.readData("birthPlace") ?? birthPlace;
    taxIdentificationNumber = await secureStorage.readData("taxIdentificationNumber") ?? taxIdentificationNumber;
    city = await secureStorage.readData("city") ?? city;
    postalCode = await secureStorage.readData("postalCode") ?? postalCode;
    countryCode = await secureStorage.readData("countryCode") ?? countryCode;
    region = await secureStorage.readData("region") ?? region;
    street = await secureStorage.readData("street") ?? street;
    number = await secureStorage.readData("number") ?? number;
    bus = await secureStorage.readData("bus") ?? bus;
    phoneNumber = await secureStorage.readData("phoneNumber") ?? phoneNumber;
    email = await secureStorage.readData("email") ?? email;
    personalEmail = await secureStorage.readData("personalEmail") ?? personalEmail;
    primaryContactFirstName = await secureStorage.readData("primaryContactFirstName") ?? primaryContactFirstName;
    primaryContactLastName = await secureStorage.readData("primaryContactLastName") ?? primaryContactLastName;
    primaryContactPhoneNumber = await secureStorage.readData("primaryContactPhoneNumber") ?? primaryContactPhoneNumber;
    primaryContactEmail = await secureStorage.readData("primaryContactEmail") ?? primaryContactEmail;
    primaryContactRelation = await secureStorage.readData("primaryContactRelation") ?? primaryContactRelation;

    setState(() {});  // Herlaad de UI met de nieuwe gegevens
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: Text('Birth Date'),
              subtitle: Text(birthDate),
            ),
            ListTile(
              title: Text('Gender'),
              subtitle: Text(gender),
            ),
            ListTile(
              title: Text('Bank Account Number'),
              subtitle: Text(bankAccountNumber),
            ),
            ListTile(
              title: Text('Nationalities'),
              subtitle: Text(nationalities),
            ),
            ListTile(
              title: Text('Civil Status'),
              subtitle: Text(civilStatus),
            ),
            ListTile(
              title: Text('Dependents'),
              subtitle: Text(dependents),
            ),
            ListTile(
              title: Text('Birth Place'),
              subtitle: Text(birthPlace),
            ),
            ListTile(
              title: Text('Tax ID'),
              subtitle: Text(taxIdentificationNumber),
            ),
            // Voeg meer ListTile widgets toe om andere profielgegevens weer te geven
          ],
        ),
      ),
    );
  }
}
