import 'package:flutter/material.dart';
import 'package:buildbase_app_flutter/screens/header_bar_screen.dart';
import 'package:intl/intl.dart';

class RegistrationOverviewScreen extends StatelessWidget {
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;
  final String clientName;
  final String projectName;
  final String date;

  const RegistrationOverviewScreen({
    Key? key,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.clientName,
    required this.projectName,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderBar(userName: 'Tom Peeters'),
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
                    const Icon(Icons.arrow_back,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Terug naar $date',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                      child: _buildUnderlinedField(
                          'Van Dag *',
                          _formatDate(startDate),
                          Icons.calendar_today)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildUnderlinedField(
                          'Van Uur *', startTime, Icons.access_time)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildUnderlinedField(
                          'Tot Dag *',
                          _formatDate(endDate),
                          Icons.calendar_today)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildUnderlinedField(
                          'Tot Uur *', endTime, Icons.access_time)),
                ],
              ),
              const SizedBox(height: 24),
              _buildDropdownField('Klantnaam *', clientName),
              const SizedBox(height: 16),
              _buildDropdownField('Projectnaam *', projectName),
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
                  onPressed: () {},
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

  String _formatDate(String date) {
    // Remove the time part (if any) and only keep the date part
    List<String> parts = date.split('T')[0].split('-');
    return "${parts[2]}/${parts[1]}/${parts[0]}"; // Format to DD/MM/YYYY
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

  Widget _buildDropdownField(String label, String value) {
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
}