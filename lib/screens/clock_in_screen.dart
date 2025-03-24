import 'package:buildbase_app_flutter/model/client_response.dart';
import 'package:buildbase_app_flutter/model/clocking_location.dart';
import 'package:buildbase_app_flutter/model/project_model.dart';
import 'package:buildbase_app_flutter/model/temp_clocking_request_model.dart';
import 'package:buildbase_app_flutter/service/api_service.dart';
import 'package:buildbase_app_flutter/service/location_service.dart';
import 'package:buildbase_app_flutter/service/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'header_bar_screen.dart';

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
      projects = client.projects;
      isLoadingProjects = false;
    });

    // List<ProjectModel> fetchedProjects = await apiService.getProjects(client.id);
    // final filteredProjects = fetchedProjects.where((p) => p.clientId == client.id).toList();
    // setState(() {
    //   projects = fetchedProjects;
    // });
  }

  void _onClientSelected(ClientResponse? client) {
    if (client != null) {
      setState(() {
        selectedClient = client;
        secure.writeData('selectedClient', client.id);
        secure.writeData('selectedClientName', client.clientName);
        print(secure.readData('selectedClientName').toString());
        _loadProjects(client);
      });
    }
  }

  void _onProjectSelected(ProjectModel? project) {
    if (project != null) {
      setState(() {
        selectedProject = project;
        secure.writeData('selectedProjectId', project.id);
        secure.writeData('selectedProjectName', project.projectName);
        print(secure.readData('selectedProjectName').toString());
      });
    }
  }

  Future<void> _startClockIn() async {
    final predictedEndTime = TimeOfDay.fromDateTime(DateTime.now().add(Duration(hours: 8)));
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
          clientId: selectedClient!.id, 
          projectId: selectedProject!.id, 
          breakTime: false, 
          clockingLocation: clockingLocation, 
          comment: "Clocked in via mobileApp"
        );

        print('before clock in api call in screen');

        await apiService.postTempWork(clockingRequest);

        final tempWorkResponse = await apiService.getTempWork();
          // print('Request: ${tempWorkResponse!.toJson()}');

        if (tempWorkResponse != null){
          String startTime = tempWorkResponse.startTime.toString();
          String? endTime = tempWorkResponse.endTime.toString();
          String clientName = tempWorkResponse.clientId;
          String projectName = tempWorkResponse.projectId;
          String? day = tempWorkResponse.day;

          String startDate = tempWorkResponse.startTime.getUtcTimeIso();
          String? endDate = tempWorkResponse.endTime?.getUtcTimeIso();

          context.go(
            '/registration-overview',
            extra: {
              'startTime': startTime,
              'startDate': startDate,
              'endDate': endDate,
              'endTime': endTime,
              'clientName': clientName,
              'projectName': projectName,
              'date': day,
            },
          );
        }
      } catch (e) {
        throw Exception(e);
      }

      setState(() {
        _startTime = TimeOfDay.now().format(context);
        _endTime = predictedEndTime.format(context);
        
        // _endTime = predictedEndTime.format(context);
      });

      
    }
  }

  @override
  Widget build(BuildContext context) {
    _startTime = TimeOfDay.now().format(context);

    return Scaffold(
      appBar: const HeaderBar(),
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