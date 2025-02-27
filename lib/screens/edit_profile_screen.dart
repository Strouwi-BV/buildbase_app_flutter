import 'package:flutter/material.dart';
import 'home_screen.dart' as custom_widgets;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget{
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController birthDateController = TextEditingController();
  TextEditingController nationalityController = TextEditingController();
  TextEditingController socialNumberController = TextEditingController();
  TextEditingController bankAccountController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController workEmailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController emergencyContactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedFirstName', firstNameController.text);
    await prefs.setString('selectedLastName', lastNameController.text);
    await prefs.setString('selectedBirthDate', birthDateController.text);
    await prefs.setString('selectedNationality', nationalityController.text);
    await prefs.setString('selectedSocialNumber', socialNumberController.text);
    await prefs.setString('selectedBankAccount', bankAccountController.text);
    await prefs.setString('selectedEmail', emailController.text);
    await prefs.setString('selectedWorkEmail', workEmailController.text);
    await prefs.setString('selectedPhone', phoneController.text);
    await prefs.setString('selectedAddress', addressController.text);
    await prefs.setString('selectedEmergencyContact', emergencyContactController.text);

    Navigator.pop(context);
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      firstNameController.text = prefs.getString('selectedFirstName') ?? "";
      lastNameController.text = prefs.getString('selectedLastName') ?? "";
      birthDateController.text = prefs.getString('selectedBirthDate') ?? "";
      nationalityController.text = prefs.getString('selectedNationality') ?? "";
      socialNumberController.text = prefs.getString('selectedSocialNumber') ?? "";
      bankAccountController.text = prefs.getString('selectedBankAccount') ?? "";
      emailController.text = prefs.getString('selectedEmail') ?? "";
      workEmailController.text = prefs.getString('selectedWorkEmail') ?? "";
      phoneController.text = prefs.getString('selectedPhone') ?? "";
      addressController.text = prefs.getString('selectedAddress') ?? "";
      emergencyContactController.text = prefs.getString('selectedFirstName') ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const custom_widgets.NavigationDrawer(),
      appBar: AppBar(
        title: Text("Edit Profile")
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 1,
            minChildSize: 0.5,
            maxChildSize: 1,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [BoxShadow(color: Colors.black, blurRadius: 5)],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        buildTextField("First Name", firstNameController),
                        buildTextField("Last Name", lastNameController),
                        buildTextField("Birth Date", birthDateController),
                        buildTextField("Nationality", nationalityController),
                        buildTextField("Social Number", socialNumberController),
                        buildTextField("Bank Account", bankAccountController),
                        buildTextField("Email", emailController),
                        buildTextField("Work Email", workEmailController),
                        buildTextField("Phone", phoneController),
                        buildTextField("Address", addressController),
                        buildTextField("Emergency Contact", emergencyContactController),
                        SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: saveUserData, 
                          child: Text("Save"),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }
}