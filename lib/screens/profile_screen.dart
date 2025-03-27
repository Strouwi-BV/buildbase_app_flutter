import 'package:flutter/material.dart';
import 'package:buildbase_app_flutter/screens/header_bar_screen.dart';
import 'package:buildbase_app_flutter/service/api_service.dart';
import 'package:country_picker/country_picker.dart';

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
  bool _isLoadingGenders = true;
  bool _isLoadingCivilStatuses = true;

  late TextEditingController _fullNameController;
  late TextEditingController _birthDateController;
  late TextEditingController _nationalityController;
  late TextEditingController _birthPlaceController;
  late TextEditingController _nationalRegistryNumberController;
  late TextEditingController _bankAccountController;
  late TextEditingController _dependentsController;

  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;

  List<String> _genderOptions = ['MALE', 'FEMALE', 'OTHER'];
  String? _selectedGender;

  List<String> _civilStatusOptions = [];
  String? _selectedCivilStatus;

  Country? _selectedCountry;

  @override
  void initState() {
    super.initState();

    // Initialize all controllers
    _fullNameController = TextEditingController();
    _birthDateController = TextEditingController();
    _nationalityController = TextEditingController();
    _birthPlaceController = TextEditingController();
    _nationalRegistryNumberController = TextEditingController();
    _bankAccountController = TextEditingController();
    _dependentsController = TextEditingController();

    _emailController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _postalCodeController = TextEditingController();
    _countryController = TextEditingController();

    // Load data in correct order
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserInfo().then((_) {
        _loadGenders();
        _loadCivilStatuses();
      });
    });
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    DateTime? initialDate = DateTime.now();
    // Try to parse existing date if available
    if (_birthDateController.text.isNotEmpty) {
      try {
        final parts = _birthDateController.text.split('/');
        if (parts.length == 3) {
          initialDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } catch (e) {
        print('Error parsing date: $e');
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      setState(() {
        _birthDateController.text = formattedDate;
      });
    }
  }

  Future<void> _loadGenders() async {
    try {
      print('Loading genders...');
      setState(() {
        _isLoadingGenders = true;
      });

      final genders = await _apiService.getGenders();
      print('Genders loaded: $genders');

      if (mounted) {
        setState(() {
          _genderOptions =
              genders.isNotEmpty ? genders : ['MALE', 'FEMALE', 'OTHER'];
          _isLoadingGenders = false;

          if (_selectedGender == null && _personalInfo?['gender'] != null) {
            _selectedGender = _personalInfo?['gender'];
          }
        });
      }
    } catch (e) {
      print('Error loading genders: $e');
      if (mounted) {
        setState(() {
          _isLoadingGenders = false;
          _genderOptions = ['MALE', 'FEMALE', 'OTHER'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kon geslachten niet laden: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadCivilStatuses() async {
    try {
      print('Loading civil statuses...');
      setState(() {
        _isLoadingCivilStatuses = true;
        _civilStatusOptions = [];
      });

      final statuses = await _apiService.getCivilStatuses().timeout(
        const Duration(seconds: 10),
      );
      print('Civil statuses loaded: $statuses');

      if (mounted) {
        setState(() {
          _civilStatusOptions = statuses;
          _isLoadingCivilStatuses = false;

          if (_personalInfo?['civilStatus'] != null) {
            _selectedCivilStatus = _personalInfo?['civilStatus'];
          } else if (_civilStatusOptions.isNotEmpty) {
            _selectedCivilStatus = _civilStatusOptions.first;
          }
        });
      }
    } catch (e) {
      print('Error loading civil statuses: $e');
      if (mounted) {
        setState(() {
          _isLoadingCivilStatuses = false;
          _civilStatusOptions = ['SINGLE', 'MARRIED', 'DIVORCED', 'OTHER'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Kon burgerlijke statussen niet laden: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      print('Loading user info...');
      setState(() {
        _isLoading = true;
      });

      final personalInfo = await _apiService.getUserPersonalInformation();
      final contactInfo = await _apiService.getUserContactInformation();
      print('User info loaded');

      if (mounted) {
        setState(() {
          _personalInfo = personalInfo;
          _contactInfo = contactInfo;

          // Set personal info values
          _fullNameController.text = _personalInfo?['fullName'] ?? '';

          // Parse birth date
          if (_personalInfo?['birthDate'] != null) {
            try {
              // Assuming API returns YYYY-MM-DD format
              final parts = _personalInfo!['birthDate'].split('-');
              if (parts.length == 3) {
                _birthDateController.text =
                    "${parts[2]}/${parts[1]}/${parts[0]}";
              } else {
                _birthDateController.text = _personalInfo!['birthDate'];
              }
            } catch (e) {
              _birthDateController.text = _personalInfo!['birthDate'];
            }
          } else {
            _birthDateController.text = '';
          }

          _selectedGender = _personalInfo?['gender'];
          _selectedCivilStatus = _personalInfo?['civilStatus'];

          // Handle country/nationality
          if (_personalInfo?['nationality'] != null) {
            try {
              _selectedCountry = Country.tryParse(
                _personalInfo!['nationality'],
              );
              _nationalityController.text = _personalInfo!['nationality'];
            } catch (e) {
              _nationalityController.text = _personalInfo!['nationality'];
            }
          } else {
            _nationalityController.text = '';
          }

          _birthPlaceController.text = _personalInfo?['birthPlace'] ?? '';
          _nationalRegistryNumberController.text =
              _personalInfo?['nationalRegistryNumber'] ?? '';
          _bankAccountController.text = _personalInfo?['bankAccount'] ?? '';
          _dependentsController.text =
              _personalInfo?['dependents']?.toString() ?? '';

          // Set contact info values
          _emailController.text = _contactInfo?['email'] ?? '';
          _phoneNumberController.text = _contactInfo?['phoneNumber'] ?? '';
          _addressController.text = _contactInfo?['address']?['street'] ?? '';
          _cityController.text = _contactInfo?['address']?['city'] ?? '';
          _postalCodeController.text =
              _contactInfo?['address']?['postalCode'] ?? '';
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
            content: Text('Kon gebruikersinformatie niet laden: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _savePersonalInformation() async {
    // Convert date to API format (YYYY-MM-DD)
    String apiFormattedDate = '';
    if (_birthDateController.text.isNotEmpty) {
      try {
        final parts = _birthDateController.text.split('/');
        if (parts.length == 3) {
          apiFormattedDate = "${parts[2]}-${parts[1]}-${parts[0]}";
        } else {
          apiFormattedDate = _birthDateController.text;
        }
      } catch (e) {
        apiFormattedDate = _birthDateController.text;
      }
    }

    final updatedData = {
      'fullName': _fullNameController.text,
      'birthDate': apiFormattedDate,
      'gender': _selectedGender,
      'civilStatus': _selectedCivilStatus,
      'nationality': _selectedCountry?.name ?? _nationalityController.text,
      'birthPlace': _birthPlaceController.text,
      'nationalRegistryNumber': _nationalRegistryNumberController.text,
      'bankAccount': _bankAccountController.text,
      'dependents':
          _dependentsController.text.isNotEmpty
              ? int.tryParse(_dependentsController.text)
              : 0,
    };

    try {
      setState(() {
        _isLoading = true;
      });

      final success = await _apiService.updateUserPersonalInformation(
        updatedData,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          await _loadUserInfo();
          setState(() {
            _isEditingPersonal = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Persoonlijke informatie succesvol opgeslagen'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opslaan van persoonlijke informatie mislukt'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fout bij opslaan persoonlijke informatie: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      },
    };

    try {
      setState(() {
        _isLoading = true;
      });

      final success = await _apiService.updateUserContactInformation(
        updatedData,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          await _loadUserInfo();
          setState(() {
            _isEditingContact = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contactgegevens succesvol opgeslagen'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opslaan van contactgegevens mislukt'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fout bij opslaan contactgegevens: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderBar(),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : (_personalInfo == null || _contactInfo == null)
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Kon gebruikersinformatie niet laden',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadUserInfo,
                      child: const Text('Opnieuw proberen'),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPersonalInfoSection(),
                    const SizedBox(height: 24),
                    _buildContactInfoSection(),
                  ],
                ),
              ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Persoonlijke Gegevens',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isEditingPersonal ? Icons.save : Icons.edit,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed:
                      _isEditingPersonal
                          ? _savePersonalInformation
                          : () {
                            setState(() {
                              _isEditingPersonal = true;
                            });
                          },
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            const SizedBox(height: 8),
            _buildPersonalInfoContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Contactgegevens',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isEditingContact ? Icons.save : Icons.edit,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed:
                      _isEditingContact
                          ? _saveContactInformation
                          : () {
                            setState(() {
                              _isEditingContact = true;
                            });
                          },
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            const SizedBox(height: 8),
            _buildContactInfoContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoContent() {
    if (_isEditingPersonal) {
      return Column(
        children: [
          _buildTextField(_fullNameController, 'Volledige naam'),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _selectBirthDate(context),
            child: AbsorbPointer(
              child: _buildTextField(
                _birthDateController,
                'Geboortedatum (DD/MM/YYYY)',
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildGenderDropdown(),
          const SizedBox(height: 12),
          _buildCivilStatusDropdown(),
          const SizedBox(height: 12),
          _buildCountryPicker(),
          const SizedBox(height: 12),
          _buildTextField(_birthPlaceController, 'Geboorteplaats'),
          const SizedBox(height: 12),
          _buildTextField(
            _nationalRegistryNumberController,
            'Rijksregisternummer',
            TextInputType.number,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            _bankAccountController,
            'Bankrekeningnummer',
            TextInputType.number,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            _dependentsController,
            'Aantal ten laste',
            TextInputType.number,
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Volledige naam', _personalInfo?['fullName']),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Geboortedatum',
            _birthDateController.text.isNotEmpty
                ? _birthDateController.text
                : _personalInfo?['birthDate'],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Geslacht',
            _mapApiGenderToDisplay(_personalInfo?['gender']),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Burgerlijke staat',
            _mapCivilStatusToDisplay(_personalInfo?['civilStatus']),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Nationaliteit',
            _selectedCountry?.name ?? _personalInfo?['nationality'],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Geboorteplaats', _personalInfo?['birthPlace']),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Rijksregisternummer',
            _personalInfo?['nationalRegistryNumber'],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Bankrekeningnummer', _personalInfo?['bankAccount']),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Aantal ten laste',
            _personalInfo?['dependents']?.toString(),
          ),
        ],
      );
    }
  }

  Widget _buildContactInfoContent() {
    if (_isEditingContact) {
      return Column(
        children: [
          _buildTextField(
            _emailController,
            'E-mailadres',
            TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            _phoneNumberController,
            'Telefoonnummer',
            TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _buildTextField(_addressController, 'Straat en huisnummer'),
          const SizedBox(height: 12),
          _buildTextField(_cityController, 'Gemeente'),
          const SizedBox(height: 12),
          _buildTextField(
            _postalCodeController,
            'Postcode',
            TextInputType.number,
          ),
          const SizedBox(height: 12),
          _buildTextField(_countryController, 'Land'),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('E-mailadres', _contactInfo?['email']),
          const SizedBox(height: 12),
          _buildInfoRow('Telefoonnummer', _contactInfo?['phoneNumber']),
          const SizedBox(height: 12),
          _buildInfoRow('Adres', _contactInfo?['address']?['street']),
          const SizedBox(height: 12),
          _buildInfoRow('Gemeente', _contactInfo?['address']?['city']),
          const SizedBox(height: 12),
          _buildInfoRow('Postcode', _contactInfo?['address']?['postalCode']),
          const SizedBox(height: 12),
          _buildInfoRow('Land', _contactInfo?['address']?['country']),
        ],
      );
    }
  }

  Widget _buildCountryPicker() {
    return InkWell(
      onTap: () {
        showCountryPicker(
          context: context,
          showPhoneCode: false,
          onSelect: (Country country) {
            setState(() {
              _selectedCountry = country;
              _nationalityController.text = country.name;
            });
          },
          countryListTheme: CountryListThemeData(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            inputDecoration: InputDecoration(
              hintText: 'Zoek land',
              border: const OutlineInputBorder(),
            ),
          ),
        );
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Nationaliteit',
          labelStyle: TextStyle(color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
        ),
        child: Row(
          children: [
            if (_selectedCountry != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  _selectedCountry!.flagEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            Text(
              _selectedCountry?.name ?? 'Selecteer een land',
              style: TextStyle(
                color: _selectedCountry != null ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    if (_isLoadingGenders && _genderOptions.isEmpty) {
      return const CircularProgressIndicator();
    }

    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Geslacht',
        labelStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGender,
          isDense: true,
          isExpanded: true,
          items:
              _genderOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(_mapApiGenderToDisplay(value)),
                );
              }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedGender = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildCivilStatusDropdown() {
    if (_isLoadingCivilStatuses && _civilStatusOptions.isEmpty) {
      return const CircularProgressIndicator();
    }

    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Burgerlijke staat',
        labelStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCivilStatus,
          isDense: true,
          isExpanded: true,
          items:
              _civilStatusOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(_mapCivilStatusToDisplay(value)),
                );
              }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCivilStatus = newValue;
            });
          },
        ),
      ),
    );
  }

  String _mapApiGenderToDisplay(String? apiValue) {
    if (apiValue == null) return 'Niet gespecificeerd';
    switch (apiValue) {
      case 'FEMALE':
        return 'Vrouw';
      case 'MALE':
        return 'Man';
      case 'OTHER':
        return 'Andere';
      default:
        return apiValue;
    }
  }

  String _mapCivilStatusToDisplay(String? apiValue) {
    if (apiValue == null) return 'Niet gespecificeerd';
    switch (apiValue) {
      case 'SINGLE':
        return 'Alleenstaand';
      case 'MARRIED':
        return 'Gehuwd';
      case 'DIVORCED':
        return 'Gescheiden';
      case 'LEGALLY_COHABITING':
        return 'Wettelijk samenwonend';
      case 'WIDOW':
        return 'Weduwe/weduwnaar';
      case 'OTHER':
        return 'Andere';
      default:
        return apiValue;
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, [
    TextInputType? keyboardType,
  ]) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.grey[800]),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value ?? 'Niet ingevuld',
            style: TextStyle(color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Dispose all controllers
    _fullNameController.dispose();
    _birthDateController.dispose();
    _nationalityController.dispose();
    _birthPlaceController.dispose();
    _nationalRegistryNumberController.dispose();
    _bankAccountController.dispose();
    _dependentsController.dispose();

    _emailController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }
}
