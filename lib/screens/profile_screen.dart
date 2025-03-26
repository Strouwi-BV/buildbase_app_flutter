import 'package:flutter/material.dart';
import 'package:buildbase_app_flutter/screens/header_bar_screen.dart';
import 'package:buildbase_app_flutter/service/api_service.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();

  Map<String, dynamic>? _personalInfo;
  Map<String, dynamic>? _contactInfo;
  bool _isEditingPersonal = false;
  bool _isEditingContact = false;
  bool _isLoading = true;

  // Personal Info Controllers
  late TextEditingController _fullNameController;
  late TextEditingController _birthDateController;
  late TextEditingController _genderController;
  late TextEditingController _civilStatusController;

  // Contact Info Controllers
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;

  @override
void initState() {
  super.initState();
  
  // Initialize all controllers with empty strings first
  _fullNameController = TextEditingController();
  _birthDateController = TextEditingController();
  _genderController = TextEditingController();
  _civilStatusController = TextEditingController();

  _emailController = TextEditingController();
  _phoneNumberController = TextEditingController();
  _addressController = TextEditingController();
  _cityController = TextEditingController();
  _postalCodeController = TextEditingController();
  _countryController = TextEditingController();

  // Load user info after initializing controllers
  _loadUserInfo();
}

  Future<void> _loadUserInfo() async {
    try {
      final personalInfo = await _apiService.getUserPersonalInformation();
      final contactInfo = await _apiService.getUserContactInformation();

      if (mounted) {
        setState(() {
          _personalInfo = personalInfo;
          _contactInfo = contactInfo;

          // Personal Info
          _fullNameController.text = _personalInfo?['fullName'] ?? '';
          _birthDateController.text = _personalInfo?['birthDate'] ?? '';
          _genderController.text = _personalInfo?['gender'] ?? '';
          _civilStatusController.text = _personalInfo?['civilStatus'] ?? '';

          // Contact Info
          _emailController.text = _contactInfo?['email'] ?? '';
          _phoneNumberController.text = _contactInfo?['phoneNumber'] ?? '';
          _addressController.text = _contactInfo?['address']?['street'] ?? '';
          _cityController.text = _contactInfo?['address']?['city'] ?? '';
          _postalCodeController.text = _contactInfo?['address']?['postalCode'] ?? '';
          _countryController.text = _contactInfo?['address']?['country'] ?? '';

          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user info: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load user information: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _savePersonalInformation() async {
    final updatedData = {
      'fullName': _fullNameController.text,
      'birthDate': _birthDateController.text,
      'gender': _genderController.text,
      'civilStatus': _civilStatusController.text,
    };

    final success = await _apiService.updateUserPersonalInformation(updatedData);

    if (success) {
      await _loadUserInfo();
      setState(() {
        _isEditingPersonal = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Personal information updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update personal information'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveContactInformation() async {
    final updatedData = {
      'email': _emailController.text,
      'phoneNumber': _phoneNumberController.text,
      'address': {
        'street': _addressController.text,
        'city': _cityController.text,
        'postalCode': _postalCodeController.text,
        'country': _countryController.text,
      }
    };

    final success = await _apiService.updateUserContactInformation(updatedData);

    if (success) {
      await _loadUserInfo();
      setState(() {
        _isEditingContact = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Contact information updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update contact information'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_personalInfo == null || _contactInfo == null)
              ? Center(
                  child: Text(
                    'Failed to load user information',
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Personal Information Section
                        _buildPersonalInfoSection(),
                        
                        const SizedBox(height: 20),
                        
                        // Contact Information Section
                        _buildContactInfoSection(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: Icon(_isEditingPersonal ? Icons.save : Icons.edit),
              onPressed: () {
                if (_isEditingPersonal) {
                  _savePersonalInformation();
                } else {
                  setState(() {
                    _isEditingPersonal = true;
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildPersonalInfoContent(),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: Icon(_isEditingContact ? Icons.save : Icons.edit),
              onPressed: () {
                if (_isEditingContact) {
                  _saveContactInformation();
                } else {
                  setState(() {
                    _isEditingContact = true;
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildContactInfoContent(),
      ],
    );
  }

  Widget _buildPersonalInfoContent() {
    if (_isEditingPersonal) {
      return Column(
        children: [
          TextField(
            controller: _fullNameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _birthDateController,
            decoration: InputDecoration(
              labelText: 'Birth Date',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _genderController,
            decoration: InputDecoration(
              labelText: 'Gender',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _civilStatusController,
            decoration: InputDecoration(
              labelText: 'Civil Status',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Name: ${_personalInfo?['fullName'] ?? 'N/A'}'),
          Text('Birth Date: ${_personalInfo?['birthDate'] ?? 'N/A'}'),
          Text('Gender: ${_personalInfo?['gender'] ?? 'N/A'}'),
          Text('Civil Status: ${_personalInfo?['civilStatus'] ?? 'N/A'}'),
        ],
      );
    }
  }

  Widget _buildContactInfoContent() {
    if (_isEditingContact) {
      return Column(
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _phoneNumberController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Street Address',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _cityController,
            decoration: InputDecoration(
              labelText: 'City',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _postalCodeController,
            decoration: InputDecoration(
              labelText: 'Postal Code',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _countryController,
            decoration: InputDecoration(
              labelText: 'Country',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Email: ${_contactInfo?['email'] ?? 'N/A'}'),
          Text('Phone: ${_contactInfo?['phoneNumber'] ?? 'N/A'}'),
          Text('Address: ${_contactInfo?['address']?['street'] ?? 'N/A'}'),
          Text('City: ${_contactInfo?['address']?['city'] ?? 'N/A'}'),
          Text('Postal Code: ${_contactInfo?['address']?['postalCode'] ?? 'N/A'}'),
          Text('Country: ${_contactInfo?['address']?['country'] ?? 'N/A'}'),
        ],
      );
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    _fullNameController.dispose();
    _birthDateController.dispose();
    _genderController.dispose();
    _civilStatusController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }
}