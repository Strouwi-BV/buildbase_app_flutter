

import 'package:buildbase_app_flutter/model/clocking_location.dart';
import 'package:buildbase_app_flutter/model/clocking_temp_work_response.dart';
import 'package:buildbase_app_flutter/model/temp_clocking_request_model.dart';
import 'package:buildbase_app_flutter/service/api_service.dart';
import 'package:buildbase_app_flutter/service/location_service.dart';
import 'package:buildbase_app_flutter/service/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'header_bar_screen.dart';
import '/service/timer_service.dart';
import 'dart:async';

class RegistrationOverviewScreen extends StatefulWidget {
  final String startDate;
  final String startTime;
  final String endDate;
  final String clientName;
  final String projectName;
  final String? date;

  const RegistrationOverviewScreen({
    Key? key,
    required this.startDate,
    required this.startTime,
    String? endDate,
    required this.clientName,
    required this.projectName,
    required this.date,
  }) : endDate = endDate ?? startDate, 
        super(key: key);
  

  @override
  _RegistrationOverviewScreenState createState() =>
      _RegistrationOverviewScreenState();
}

class _RegistrationOverviewScreenState extends State<RegistrationOverviewScreen> {
  final SecureStorageService secure = SecureStorageService();
  final LocationService location = LocationService();
  final apiService = ApiService();
  
  late String _currentTime;
  late Timer _timer;
  String selectedClientName = '';
  String selectedProjectName = '';
  String startTime = '';
  String day = '';

  @override
  void initState() {
    super.initState();
    getClientDetails();
    // Verplaats de Timer-logica naar didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentTime = TimeOfDay.now().format(context);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = TimeOfDay.now().format(context);
        });
      }
    });
  }

  Future<void> getClientDetails() async {
    String? selectedClient = await secure.readData('selectedClientName');
    String? selectedProject = await secure.readData('selectedProjectName');
    
    setState(() {
      selectedClientName = selectedClient ?? '';
      selectedProjectName = selectedProject ?? '';
    });
  }

  Future<void> getClockingDetails(TempClockingRequestModel tempwork) async {

    String? startTime = await secure.readData('startTime');
    String? day = await secure.readData('day');
  }

  Future<void> _clockOut() async {
    final String? posClient = await secure.readData('selectedClientName');
    final String? posProject = await secure.readData('selectedProjectName');

    if (posClient != null && posProject != null && posClient.isNotEmpty && posProject.isNotEmpty){

      try {

        final position = await location.getCurrentLocation();
        final List<Placemark> placemarks = await placemarkFromCoordinates(
          position!.latitude, 
          position.longitude
        );

        String? city = '';
        String? country = '';

        if (placemarks.isNotEmpty){
          final place = placemarks.first;
          city = place.locality ?? '';
          country = place.isoCountryCode ?? '';
        }

        final ClockingLocation clockingLocation = ClockingLocation(
          longitude: position.longitude, 
          latitude: position.latitude, 
          city: city, 
          countryCode: country
          );

        final TempClockingRequestModel clockingRequest = TempClockingRequestModel(
          clientId: selectedClientName, 
          projectId: selectedProjectName, 
          breakTime: false, 
          clockingLocation: clockingLocation, 
          comment: "Clocked out via mobileApp"
        );

        print('before clock out api call in screen');

        await apiService.postTempWork(clockingRequest);
          // print('Request: ${tempWorkResponse!.toJson()}');
      } catch (e) {
        throw Exception(e);
      }

      
    }
  }
  

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _stopTimer() {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    DateTime now = DateTime.now();
    DateTime startTime = DateTime.parse(widget.startDate).toUtc().subtract(const Duration(hours: 1));
    print('testing stop timer ${now.difference(startTime).inSeconds} verschil');
    if (now.difference(startTime).inSeconds < 60) {
      print('You need to clock in for more than a minute');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You need to clock in for more than a minute")),
      );
      timerProvider.stopTimer(); // Stop de timer
      timerProvider.resetTimer(); // Reset de timer
      _clockOut();
      context.go('/clock-in');
    } else if (now.difference(startTime).inSeconds > 60) {
      timerProvider.stopTimer(); // Stop de timer
      timerProvider.resetTimer(); // Reset de timer
      _clockOut(); 
      context.go('/clock-in');
    }

  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    return Scaffold(
      appBar: const HeaderBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Registratie',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Terug naar ${_formatDate(widget.startDate)}',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
              // const SizedBox(height: 24),
              // Row(
              //   children: [
              //     const Icon(Icons.arrow_back, size: 16, color: Colors.grey),
              //     const SizedBox(width: 4),
              //     Text('Terug naar ${widget.date}',
              //         style: const TextStyle(
              //             fontSize: 14, color: Colors.grey)),
              //   ],
              // ),
            // ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                      child: _buildUnderlinedField(
                          'Van Dag *',
                          _formatDate(widget.startDate),
                          Icons.calendar_today)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildUnderlinedField(
                          'Van Uur *', _formatTime(widget.startDate), Icons.access_time)), // Gebruik de opgeslagen starttijd
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildUnderlinedField(
                          'Tot Dag *',
                          _formatDate(widget.endDate),
                          Icons.calendar_today)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildUnderlinedField(
                          'Tot Uur *', _currentTime, Icons.access_time)),
                ],
              ),
              const SizedBox(height: 24),
              _buildDropdownField('Klantnaam *', selectedClientName,
                  showIcon: false),
              const SizedBox(height: 16),
              _buildDropdownField('Projectnaam *', selectedProjectName,
                  showIcon: false),
              const SizedBox(height: 16),
              _buildTextField('Opmerking'),
              const SizedBox(height: 16),
              const Text(
                'Minimaal 30 minuten werken om een pauze te nemen',
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _stopTimer();// Stop de timer wanneer de knop wordt ingedrukt
                    // context.go('/clock-in');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.stop, color: Colors.white),
                      SizedBox(width: 8),
                      Text('STOP', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatTime(String? dateTime) {
  if (dateTime == null || dateTime.isEmpty) return '';
  try {
    final parsedTime = DateTime.parse(dateTime);
    final formattableTime = parsedTime.subtract(const Duration(hours: 1));
    String formattedTime = DateFormat('hh:mm a').format(formattableTime);


    if (formattedTime.startsWith('0')) {
      formattedTime = formattedTime.substring(1);
    }

    return formattedTime;
  } catch (e) {
    return dateTime;
  }
}

String _formatDate(String date) {
  // Verwijder het tijdgedeelte (indien aanwezig) en behoud alleen de datum
  List<String> parts = date.split('T')[0].split('-');
  return "${parts[2]}/${parts[1]}/${parts[0]}"; // Format naar DD/MM/YYYY
}

Widget _buildUnderlinedField(
    String label, String value, IconData? icon) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
          if (icon != null) Icon(icon, size: 24, color: Colors.grey),
        ],
      ),
      const Divider(color: Colors.grey, thickness: 1),
    ],
  );
}

Widget _buildDropdownField(String label, String value,
    {bool showIcon = true}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
          if (showIcon)
            const Icon(Icons.arrow_drop_down, size: 24, color: Colors.grey),
        ],
      ),
      const Divider(color: Colors.grey, thickness: 1),
    ],
  );
}
 
Widget _buildTextField(String label) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      maxLines: 3,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        border: const OutlineInputBorder(),
      ),
    ),
  );
}


