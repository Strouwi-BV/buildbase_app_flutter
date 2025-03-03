import 'package:flutter/material.dart';
import 'package:buildbase_app_flutter/screens/header_bar_screen.dart';

class RegistrationOverviewScreen extends StatelessWidget {
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;
  final String clientName;
  final String projectName;

  const RegistrationOverviewScreen({
    Key? key,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.clientName,
    required this.projectName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderBar(userName: 'Tom Peeters'), // Gebruik je bestaande HeaderBar
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Registratie Overzicht',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Van Dag:',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  startDate,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Van Uur:',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  startTime,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tot Dag:',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  endDate,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tot Uur:',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  endTime,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Klantnaam:',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  clientName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Projectnaam:',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  projectName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Opmerking:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 4),
            const Text(
              'Minimaal 30 minuten werken om een pauze te nemen',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
          ],
        ),
      ),
    );
  }
}
