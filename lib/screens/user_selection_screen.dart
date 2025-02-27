import 'package:flutter/material.dart';
import 'package:flutter_poc_reloaded/api/api_service.dart';
import 'package:flutter_poc_reloaded/models/user_model.dart';
import 'package:intl/date_symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart' as custom_widgets;

class UserSelectionScreen extends StatefulWidget {
  @override
  _UserSelectionScreenState createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  ApiService apiService = ApiService();
  List<UserModel> users = [];
  UserModel? selectedUser;

  @override
  void initState() {
    super.initState();
    fetchUsers();
    getSelectedUser();
  }

  Future<void> fetchUsers() async {
    try {
      List<UserModel> fetchedUsers = await apiService.fetchUsers();
      setState(() {
        users = fetchedUsers;
      });
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  Future<void> saveSelectedUserToPrefs(UserModel user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedUser', user.id);
    await prefs.setString('selectedUserName', "${user.firstName} ${user.lastName}");
    await prefs.setString('selectedFirstName', user.firstName);
    await prefs.setString('selectedLastName', user.lastName);
    await prefs.setString('selectedBirthDate', user.birthDate);
    await prefs.setString('selectedNationality', user.nationality);
    await prefs.setString('selectedSocialNumber', user.socialNumber);
    await prefs.setString('selectedBankAccount', user.bankAccount);
    await prefs.setString('selectedEmail', user.email);
    await prefs.setString('selectedWorkEmail', user.workEmail);
    await prefs.setString('selectedPhone', user.phone);
    await prefs.setString('selectedAddress', user.address);
    await prefs.setString('selectedEmergencyContact', user.emergencyContact);

    setState(() {
      selectedUser = user;
    });
    
  }

  Future<UserModel?> getSelectedUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int? userId = prefs.getInt('selectedUserId');
    String? userName = prefs.getString('selectedUsername');
    String? firstName = prefs.getString('selectedFirstName');
    String? lastName = prefs.getString('selectedLastName');
    String? birthDate = prefs.getString('selectedBirthDate');
    String? nationality = prefs.getString('selectedNationality');
    String? socialNumber = prefs.getString('selectedSocialNumber');
    String? bankAccount = prefs.getString('selectedBankAccount');
    String? email = prefs.getString('selectedEmail');
    String? workEmail = prefs.getString('selectedWorkEmail');
    String? phone = prefs.getString('selectedPhone');
    String? address = prefs.getString('selectedAddress');
    String? emergencyContact = prefs.getString('selectedEmergencyContact');
    

    if (userId != null && userName != null) {
      setState(() {
        UserModel(
          id: userId,
          firstName: firstName.toString(),
          lastName: lastName.toString(),
          birthDate: birthDate.toString(),
          nationality: nationality.toString(),
          socialNumber: socialNumber.toString(),
          bankAccount: bankAccount.toString(),
          email: email.toString(),
          workEmail: workEmail.toString(),
          phone: phone.toString(),
          address: address.toString(),
          emergencyContact: emergencyContact.toString(),
        );
      }); 
    }
  }

  Future<void> loadSelectedUser() async {
    UserModel? user = await ApiService.getSelectedUser();
    if (user != null) {
      setState(() {
        selectedUser = user;
      });
    }
  }

  Future<void> saveSelectedUser(UserModel user) async {
    await ApiService.saveSelectedUser(user);
    setState(() {
      selectedUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const custom_widgets.NavigationDrawer(),
      appBar: AppBar(title: Text("Selected user")),
      body: Column(children: [
        selectedUser != null
        ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Selected User: ${selectedUser!.firstName} ${selectedUser!.lastName}",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        )
        : SizedBox(),
        DropdownButton<UserModel>(
          value: selectedUser,
          hint: Text("Select User"),
          isExpanded: true,
          onChanged: (UserModel? newUser) {
            if (newUser != null) {
              saveSelectedUserToPrefs(newUser);
            }
          },
          items: users.map<DropdownMenuItem<UserModel>>((UserModel user) {
            return DropdownMenuItem<UserModel>(
              value: user,
              child: Text("${user.firstName} ${user.lastName}"),
            );
          }).toList(),
        ),
        // Expanded(
        //   child: users.isEmpty ? Center(
        //     child: CircularProgressIndicator()) : ListView.builder(
        //       itemCount: users.length,
        //       itemBuilder: (context, index) {
        //         UserModel user = users[index];
        //         return ListTile(
        //           title: Text("${user.firstName} ${user.lastName}"),
        //           onTap: () => saveSelectedUserToPrefs(user),
        //           trailing: selectedUser?.id == user.id ? Icon(Icons.check_circle, color: Colors.green) : null,
        //         );
        //       },
        //     ),
        //   ),
        ],
      ),
    );
  }


}