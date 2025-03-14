import 'package:buildbase_app_flutter/model/address_model.dart';
import 'package:buildbase_app_flutter/model/contact_model.dart';
import 'package:buildbase_app_flutter/model/project_model.dart';

class ClientResponse {
  final String id;
  final String organizationId;
  final String clientName;
  final List<ProjectModel> projects;
  final bool active;
  final String registrationDate;
  final String startDate;
  final String endDate;
  final bool archived;
  final AddressModel address;
  final List<ContactModel> contactList;
  final String vat;
  final String functionalId;

  ClientResponse({
    required this.id,
    required this.organizationId,
    required this.clientName,
    required this.projects,
    required this.active,
    required this.registrationDate,
    required this.startDate,
    required this.endDate,
    required this.archived,
    required this.address,
    required this.contactList,
    required this.vat,
    required this.functionalId
  });

  factory ClientResponse.fromJson(Map<String, dynamic> json) {
    return ClientResponse(
      id: json['id'], 
      organizationId: json['organizationId'], 
      clientName: json['clientName'], 
      projects: (json['projects'] as List<dynamic>)
                .map((project) => ProjectModel.fromJson(project))
                .toList(), 
      active: json['active'], 
      registrationDate: json['registrationDate'], 
      startDate: json['startDate'], 
      endDate: json['endDate'], 
      archived: json['archived'], 
      address: AddressModel.fromJson(json['address']), 
      contactList: (json['contactList'] as List<dynamic> )
                .map((contact) => ContactModel.fromJson(contact))
                .toList(), 
      vat: json['vat'], 
      functionalId: json['functionalId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'clientName': clientName,
      'projects': projects.map((p) => p.toJson()).toList(),
      'active': active,
      'registrationDate': registrationDate,
      'startDate': startDate,
      'endDate': endDate,
      'archived': archived,
      'address': address.toJson(),
      'contactList': contactList.map((c) => c.toJson()).toList(),
      'vat': vat,
      'functionalId': functionalId,
    };
  }
}