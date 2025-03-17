import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'header_bar_screen.dart';
import '/service/timer_service.dart';
import 'package:buildbase_app_flutter/model/client_response.dart';
import 'package:buildbase_app_flutter/model/project_model.dart';
import 'package:buildbase_app_flutter/service/api_service.dart';
import 'package:buildbase_app_flutter/service/location_service.dart';
import 'package:buildbase_app_flutter/service/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'header_bar_screen.dart';
import 'package:go_router/go_router.dart';

class ClockInScreen extends StatefulWidget {
  const ClockInScreen({Key? key}) : super(key: key);

  @override
  _ClockInScreenState createState() => _ClockInScreenState();
}

class _ClockInScreenState extends State<ClockInScreen> {
  final SecureStorageService secure = SecureStorageService();
  final LocationService location = LocationService();
  final apiService = ApiService();
  
  late String _startTime;
  late String _endTime;
  List<ClientResponse> clients = [];
  List<ProjectModel> projects = [];

  ClientResponse? selectedClient;
  ProjectModel? selectedProject;
  bool isLoadingProjects = false;

  @override
  void initState() {
    super.initState();
    _loadClients();

  }

  Future<void> _loadClients() async {
    List<ClientResponse> fetchedClients = await apiService.getClients();
    setState(() {
      clients = fetchedClients;
    });
  }

  Future<void> _loadProjects(ClientResponse client) async {
    setState(() {
      isLoadingProjects = true;
      selectedProject = null;
      projects = [];
    });

    List<ProjectModel> fetchedProjects = await apiService.getProjects(client.id);

    setState(() {
      projects = fetchedProjects;
      isLoadingProjects = false;
    });
  }

  void _onClientSelected(ClientResponse? client) {
    if (client != null) {
      setState(() {
        selectedClient = client;
        secure.writeData('selectedClient', client.id);
        _loadProjects(client);
      });
    }
  }

  void _onProjectSelected(ProjectModel? project) {
    if (project != null) {
      setState(() {
        selectedProject = project;
      });
    }
  }

  void _startClockIn() {
    setState(() {
      _startTime = TimeOfDay.now().format(context);
      _endTime = TimeOfDay.now().format(context);
    });

    // Navigate to RegistrationOverviewScreen and pass the selected values
    context.go(
      '/registration-overview',
      extra: {
        'startTime': _startTime,
        // 'clientName': _selectedClient,
        // 'projectName': _selectedProject,
        'startDate': DateTime.now().toIso8601String(),
        'endDate': DateTime.now().toIso8601String(),
        'endTime': _endTime,
        'date': '27/02/2025' // You can make this dynamic
      },
    );

    // Future<void> _loadClients() async {
    //   List<ClientResponse> fetchedClients = await apiService.getClients();
    // }
  }

  @override
  Widget build(BuildContext context) {
    _startTime = TimeOfDay.now().format(context);

    return Scaffold(
      appBar: const HeaderBar(userName: "Test"),
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
                  DropdownButton<ClientResponse>(
                    isExpanded: true,
                    value: selectedClient,
                    items: clients.map((ClientResponse client) {
                      return DropdownMenuItem<ClientResponse>(
                        value: client,
                        child: Text(client.clientName),
                      );
                    }).toList(),
                    onChanged: _onClientSelected,
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
                  DropdownButton<ProjectModel>(
                    isExpanded: true,
                    value: selectedProject,
                    items: projects.map((ProjectModel project) {
                      return DropdownMenuItem<ProjectModel>(
                        value: project,
                        child: Text(project.projectName),
                      );
                    }).toList(),
                    onChanged: selectedClient == null ? null : _onProjectSelected,
                    disabledHint: Text('Select a client first'),
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