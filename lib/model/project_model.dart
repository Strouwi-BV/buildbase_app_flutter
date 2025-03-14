
import 'package:buildbase_app_flutter/model/address_model.dart';
import 'package:buildbase_app_flutter/model/contact_model.dart';
import 'package:buildbase_app_flutter/model/external_reference_model.dart';

class ProjectModel {
  final String id;
  final String projectName;
  final bool active;
  final String registrationDate;
  final String startDate;
  final String endDate;
  final bool archived;
  final AddressModel address;
  final List<ContactModel> contactList;
  final ExternalReferenceModel externalReference;
  final String functionalId;

  ProjectModel({
    required this.id,
    required this.projectName,
    required this.active,
    required this.registrationDate,
    required this.startDate,
    required this.endDate,
    required this.archived,
    required this.address,
    required this.contactList,
    required this.externalReference,
    required this.functionalId,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'], 
      projectName: json['projectName'], 
      active: json['active'], 
      registrationDate: json['registrationDate'], 
      startDate: json['startDate'], 
      endDate: json['endDate'], 
      archived: json['archived'],
      address: json['address'],
      contactList: (json['contactList'] as List<dynamic>)
                .map((contact) => ContactModel.fromJson(contact))
                .toList(), 
      externalReference: ExternalReferenceModel.fromJson(json['externalReference']), 
      functionalId: json['functionalId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectName': projectName,
      'active': active,
      'registrationDate': registrationDate,
      'startDate': startDate,
      'endDate': endDate,
      'archived': archived,
      'address': address.toJson(),
      'contactList': contactList
                .map((c) => c.toJson())
                .toList(),
      'externalReference': externalReference.toJson(),
      'functionalId': functionalId,
    };
  }


}