import 'dart:async';
import 'package:flutter/material.dart';
import 'package:buildbase_app_flutter/screens/header_bar_screen.dart';
import 'package:go_router/go_router.dart';

class RegistrationOverviewScreen extends StatefulWidget {
  final String startDate;
  final String startTime;
  final String endDate;
  final String clientName;
  final String projectName;
  final String date;

  const RegistrationOverviewScreen({
    Key? key,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.clientName,
    required this.projectName,
    required this.date,
  }) : super(key: key);

  @override
  _RegistrationOverviewScreenState createState() =>
      _RegistrationOverviewScreenState();
}

class _RegistrationOverviewScreenState
    extends State<RegistrationOverviewScreen> {
  late String _currentTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Now we only set an initial value, we will update this later.
    _currentTime = "00:00";

    // Start a timer that updates the time every second.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = TimeOfDay.now().format(context);
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Now it is safe to use context here.
    _currentTime = TimeOfDay.now().format(context);
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed to prevent memory leaks.
    _timer.cancel();
    super.dispose();
  }

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
                    const Icon(Icons.arrow_back, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Terug naar ${widget.date}',
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
                          _formatDate(widget.startDate),
                          Icons.calendar_today)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildUnderlinedField(
                          'Van Uur *', widget.startTime, Icons.access_time)),
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
              _buildDropdownField('Klantnaam *', widget.clientName,
                  showIcon: false),
              const SizedBox(height: 16),
              _buildDropdownField('Projectnaam *', widget.projectName,
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
                    // Navigate to ClockingDetailsScreen when the button is pressed
                    context.go('/clocking-details');
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
}