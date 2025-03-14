import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'header_bar_screen.dart';
import '/service/timer_service.dart';
import 'package:buildbase_app_flutter/model/client_response.dart';
import 'package:buildbase_app_flutter/model/project_model.dart';
import 'package:buildbase_app_flutter/service/api_service.dart';


class ClockInScreen extends StatefulWidget {
  const ClockInScreen({Key? key}) : super(key: key);

  @override
  _ClockInScreenState createState() => _ClockInScreenState();
}

class _ClockInScreenState extends State<ClockInScreen> {
  late String _startTime;
  late String _endTime;
  String _selectedClient = ''; // Standaardwaarden
  String _selectedProject = '';
  List<ClientResponse> _clients = [];
  List<ProjectModel> _projects = [];

  // Functie om de lijst van klanten op te halen
  Future<void> _fetchClients() async {
  try {
    ApiService apiService = ApiService();
    List<ClientResponse> clients = await apiService.getClients(); 
    print("Fetched clients: $clients");  // Voeg print toe
    setState(() {
      _clients = clients;
      if (_clients.isNotEmpty) {
        _selectedClient = _clients[0].clientName;
      }
    });
  } catch (e) {
    print("Error fetching clients: $e");
  }
}
  // Functie om de lijst van projecten op te halen
  Future<void> _fetchProjects(String clientId) async {
  try {
    ApiService apiService = ApiService();
    List<ProjectModel> projects = await apiService.getProjects(clientId); 
    print("Fetched projects: $projects");  // Voeg print toe
    setState(() {
      _projects = projects;
      if (_projects.isNotEmpty) {
        _selectedProject = _projects[0].projectName;
      }
    });
  } catch (e) {
    print("Error fetching projects: $e");
  }
}

  @override
  void initState() {
    super.initState();
    _fetchClients();
    _fetchProjects(_selectedClient);
  }

  

 void _startClockIn() {
  final timerProvider = Provider.of<TimerProvider>(context, listen: false);
  final startTime = TimeOfDay.now().format(context);

  timerProvider.setStartTime(startTime); // Sla de starttijd op
  timerProvider.startTimer(); // Start de timer

  setState(() {
    _startTime = startTime;
    _endTime = TimeOfDay.now().format(context);
  });

  // Navigeer naar RegistrationOverviewScreen en geef de benodigde data door
  context.go(
    '/registration-overview',
    extra: {
      'startDate': DateTime.now().toIso8601String(),
      'startTime': startTime, // Gebruik de opgeslagen starttijd
      'endDate': DateTime.now().toIso8601String(),
      'clientName': _selectedClient,
      'projectName': _selectedProject,
      'date': '27/02/2025', // Vervang dit door dynamische data
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);

    // Als de timer loopt, laat een bericht zien dat de gebruiker naar de overview moet gaan
    if (timerProvider.elapsedTime != "00:00:00") {
      return Scaffold(
        appBar: const HeaderBar(userName: 'Tom Peeters'),
        body: Center(
          child: Text(
            'Clock-in is al gestart. Ga naar de overview om te stoppen.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    _startTime = TimeOfDay.now().format(context);

    return Scaffold(
      appBar: const HeaderBar(userName: 'Tom Peeters'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Registratie',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Terug naar 27/02/2025',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              'Klantnaam *',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            DropdownButtonHideUnderline(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedClient,
                    items: _clients.map((ClientResponse client) {
                      return DropdownMenuItem<String>(
                        value: client.clientName,
                        child: Text(client.clientName),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedClient = newValue!;
                      });
                    },
                  ),
                  Container(height: 1, color: Colors.black54),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Projectnaam *',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            DropdownButtonHideUnderline(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedProject,
                    items: _projects.map((ProjectModel project) {
                      return DropdownMenuItem<String>(
                        value: project.projectName,
                        child: Text(project.projectName),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedProject = newValue!;
                      });
                    },
                  ),
                  Container(height: 1, color: Colors.black54),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _startClockIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.play_arrow, color: Colors.white),
                  SizedBox(width: 8),
                  Text('START', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}