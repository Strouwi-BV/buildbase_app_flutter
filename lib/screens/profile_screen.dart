import 'package:flutter/material.dart';
import 'package:buildbase_app_flutter/screens/header_bar_screen.dart';
import 'package:buildbase_app_flutter/service/secure_storage_service.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;

  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SecureStorageService secureStorage = SecureStorageService();

  String name = "Casper Moors";
  String birthDate = "16/02/2004";
  String birthPlace = "België";
  String gender = "Man";
  String maritalStatus = "Single";
  String nationality = "Belg";
  String address = "Molenstraat 3, 3850 Binderveld";
  String workEmail = "casper.moors@ucll.com";
  String personalEmail = "moorscasper@gmail.com";
  String phone = "+32 4 68305300";
  String emergencyContact = "+32 4 68193593";

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    name = await secureStorage.readData("name") ?? name;
    birthDate = await secureStorage.readData("birthDate") ?? birthDate;
    birthPlace = await secureStorage.readData("birthPlace") ?? birthPlace;
    gender = await secureStorage.readData("gender") ?? gender;
    maritalStatus = await secureStorage.readData("maritalStatus") ?? maritalStatus;
    nationality = await secureStorage.readData("nationality") ?? nationality;
    address = await secureStorage.readData("address") ?? address;
    workEmail = await secureStorage.readData("workEmail") ?? workEmail;
    personalEmail = await secureStorage.readData("personalEmail") ?? personalEmail;
    phone = await secureStorage.readData("phone") ?? phone;
    emergencyContact = await secureStorage.readData("emergencyContact") ?? emergencyContact;
    setState(() {});
  }

  Future<void> _saveProfileData(String key, String value) async {
    await secureStorage.writeData(key, value);
    setState(() {});
  }

  void _editInfo(String title, String field, Function(String) onSave, String key) {
    TextEditingController controller = TextEditingController(text: field);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $title"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Enter new $title"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              onSave(controller.text);
              _saveProfileData(key, controller.text);
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBlock(String title, Map<String, String> fields, Map<String, Function(String)> onSaveFunctions, Map<String, String> keys) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...fields.entries.map((entry) => ListTile(
                  title: Text("${entry.key}: ${entry.value}"),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _editInfo(entry.key, entry.value, onSaveFunctions[entry.key]!, keys[entry.key]!);
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderBar(),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            _buildInfoBlock(
              "Persoonlijke Informatie",
              {
                "Naam": name,
                "Geboortedatum": birthDate,
                "Geboorteplaats": birthPlace,
                "Geslacht": gender,
                "Burgerlijke Status": maritalStatus,
                "Nationaliteit": nationality,
              },
              {
                "Naam": (value) => setState(() => name = value),
                "Geboortedatum": (value) => setState(() => birthDate = value),
                "Geboorteplaats": (value) => setState(() => birthPlace = value),
                "Geslacht": (value) => setState(() => gender = value),
                "Burgerlijke Status": (value) => setState(() => maritalStatus = value),
                "Nationaliteit": (value) => setState(() => nationality = value),
              },
              {
                "Name": "name",
                "Geboortedatum": "birthDate",
                "Geboorteplaats": "birthPlace",
                "Geslacht": "gender",
                "Burgerlijke Status": "maritalStatus",
                "Nationaliteit": "nationality",
              },
            ),
            _buildInfoBlock(
              "Contact Informatie",
              {
                "Adres": address,
                "Werk Email": workEmail,
                "Persoonlijke Email": personalEmail,
                "Telefoon": phone,
                "Nood Contact": emergencyContact,
              },
              {
                "Adres": (value) => setState(() => address = value),
                "Werk Email": (value) => setState(() => workEmail = value),
                "Persoonlijke Email": (value) => setState(() => personalEmail = value),
                "Telefoon": (value) => setState(() => phone = value),
                "Nood Contact": (value) => setState(() => emergencyContact = value),
              },
              {
                "Adres": "address",
                "Werk Email": "workEmail",
                "Persoonlijke Email": "personalEmail",
                "Phone": "phone",
                "Nood Contact": "emergencyContact",
              },
            ),
          ],
        ),
      ),
    );
  }
}
